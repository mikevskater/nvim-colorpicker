---@module 'nvim-colorpicker.filetypes'
---@brief Filetype adapter registry for file-aware color formatting

local M = {}

---@type table<string, FiletypeAdapter> Registry of adapters by filetype
M.adapters = {}

---@class FiletypeAdapter
---@field filetypes string[] File types this adapter handles
---@field patterns PatternDef[] Detection patterns (ordered by priority)
---@field default_format string Default output format for this filetype
---@field format_color fun(self: FiletypeAdapter, hex: string, format: string, alpha: number?): string
---@field parse_color fun(self: FiletypeAdapter, match: string, format: string): string?, number?
---@field value_range "0-255"|"0-1" Value range for this adapter

---@class PatternDef
---@field pattern string Lua pattern for detection
---@field format string Format identifier for this pattern
---@field priority number Higher priority patterns are checked first

---Register an adapter for its filetypes
---@param adapter FiletypeAdapter
function M.register(adapter)
  if not adapter or not adapter.filetypes then return end
  for _, ft in ipairs(adapter.filetypes) do
    M.adapters[ft] = adapter
  end
end

---Get adapter for a filetype
---@param filetype string? Filetype (defaults to current buffer filetype)
---@return FiletypeAdapter? adapter The adapter or nil
function M.get_adapter(filetype)
  filetype = filetype or vim.bo.filetype
  return M.adapters[filetype] or M.adapters["_default"]
end

---Get patterns for a filetype
---@param filetype string? Filetype (defaults to current buffer filetype)
---@return PatternDef[] patterns Detection patterns
function M.get_patterns(filetype)
  local adapter = M.get_adapter(filetype)
  return adapter and adapter.patterns or {}
end

---Format a color for a specific filetype
---@param hex string Hex color
---@param filetype string? Target filetype
---@param format string? Target format (uses adapter default if nil)
---@param alpha number? Alpha value 0-100
---@return string formatted Formatted color string
function M.format_color(hex, filetype, format, alpha)
  local adapter = M.get_adapter(filetype)
  if adapter then
    local target_format = format or adapter.default_format
    return adapter:format_color(hex, target_format, alpha)
  end
  -- Fallback to current format.lua behavior
  local color_format = require('nvim-colorpicker.color.format')
  return color_format.convert_format(hex, format or "hex", alpha) or hex
end

---Parse a matched color string
---@param match string The matched color string
---@param format string The format identifier
---@param filetype string? The filetype context
---@return string? hex Parsed hex color
---@return number? alpha Alpha value 0-100
function M.parse_color(match, format, filetype)
  local adapter = M.get_adapter(filetype)
  if adapter and adapter.parse_color then
    return adapter:parse_color(match, format)
  end
  -- Fallback to current format.lua behavior
  local color_format = require('nvim-colorpicker.color.format')
  return color_format.parse_color_string(match)
end

---Get default format for a filetype
---@param filetype string? Filetype
---@return string format Default format
function M.get_default_format(filetype)
  local adapter = M.get_adapter(filetype)
  return adapter and adapter.default_format or "hex"
end

---Check if a filetype has a registered adapter
---@param filetype string Filetype to check
---@return boolean has_adapter
function M.has_adapter(filetype)
  return M.adapters[filetype] ~= nil
end

---Get list of all registered filetypes
---@return string[] filetypes
function M.get_registered_filetypes()
  local filetypes = {}
  for ft, _ in pairs(M.adapters) do
    if ft ~= "_default" then
      table.insert(filetypes, ft)
    end
  end
  table.sort(filetypes)
  return filetypes
end

-- Auto-register default adapter on module load
local function setup()
  local ok, default_adapter = pcall(require, 'nvim-colorpicker.filetypes.adapters.default')
  if ok and default_adapter then
    M.register(default_adapter)
  end
end

setup()

return M
