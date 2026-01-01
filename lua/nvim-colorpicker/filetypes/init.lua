---@module 'nvim-colorpicker.filetypes'
---@brief Filetype adapter registry for file-aware color formatting

local M = {}

---@type table<string, FiletypeAdapter> Registry of adapters by filetype
M.adapters = {}

---@type table<string, table<string, NvimColorPickerCustomPattern>> Custom patterns indexed by filetype then format
M._custom_patterns_cache = {}

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

---Get custom pattern definition by format (for parse/format callbacks)
---@param filetype string The filetype
---@param format string The format identifier
---@return NvimColorPickerCustomPattern? pattern The custom pattern or nil
function M.get_custom_pattern(filetype, format)
  -- Build cache if not present
  if not M._custom_patterns_cache[filetype] then
    M._custom_patterns_cache[filetype] = {}
    local Config = require('nvim-colorpicker.config')
    local custom = Config.get_custom_patterns(filetype)
    for _, p in ipairs(custom) do
      M._custom_patterns_cache[filetype][p.format] = p
    end
  end
  return M._custom_patterns_cache[filetype][format]
end

---Clear custom patterns cache (call after config changes)
function M.clear_custom_patterns_cache()
  M._custom_patterns_cache = {}
end

---Get patterns for a filetype (adapter patterns + custom patterns)
---@param filetype string? Filetype (defaults to current buffer filetype)
---@return PatternDef[] patterns Detection patterns sorted by priority
function M.get_patterns(filetype)
  filetype = filetype or vim.bo.filetype
  local patterns = {}

  -- Get adapter patterns
  local adapter = M.get_adapter(filetype)
  if adapter and adapter.patterns then
    for _, p in ipairs(adapter.patterns) do
      table.insert(patterns, p)
    end
  end

  -- Get custom patterns from config
  local Config = require('nvim-colorpicker.config')
  local custom = Config.get_custom_patterns(filetype)
  for _, p in ipairs(custom) do
    table.insert(patterns, {
      pattern = p.pattern,
      format = p.format,
      priority = p.priority or 100,
      _custom = true,  -- Mark as custom for parse/format lookup
    })
  end

  -- Sort by priority (higher first)
  table.sort(patterns, function(a, b)
    return (a.priority or 0) > (b.priority or 0)
  end)

  return patterns
end

---Format a color for a specific filetype
---@param hex string Hex color
---@param filetype string? Target filetype
---@param format string? Target format (uses adapter default if nil)
---@param alpha number? Alpha value 0-100
---@return string formatted Formatted color string
function M.format_color(hex, filetype, format, alpha)
  filetype = filetype or vim.bo.filetype
  local target_format = format

  -- Check for custom pattern first
  if target_format then
    local custom = M.get_custom_pattern(filetype, target_format)
    if custom and custom.format_color then
      local ok, result = pcall(custom.format_color, hex, alpha)
      if ok and result then
        return result
      end
    end
  end

  -- Fall back to adapter
  local adapter = M.get_adapter(filetype)
  if adapter then
    target_format = target_format or adapter.default_format
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
  filetype = filetype or vim.bo.filetype

  -- Check for custom pattern first
  local custom = M.get_custom_pattern(filetype, format)
  if custom and custom.parse then
    local ok, hex, alpha = pcall(custom.parse, match)
    if ok and hex then
      return hex, alpha
    end
  end

  -- Fall back to adapter
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

-- List of built-in adapters to load
local BUILTIN_ADAPTERS = {
  'nvim-colorpicker.filetypes.adapters.default',
  -- Web
  'nvim-colorpicker.filetypes.adapters.css',
  'nvim-colorpicker.filetypes.adapters.javascript',
  -- Scripting
  'nvim-colorpicker.filetypes.adapters.python',
  'nvim-colorpicker.filetypes.adapters.lua',
  -- Mobile/Game
  'nvim-colorpicker.filetypes.adapters.kotlin',
  'nvim-colorpicker.filetypes.adapters.swift',
  'nvim-colorpicker.filetypes.adapters.dart',
  'nvim-colorpicker.filetypes.adapters.csharp',
  -- Systems/Shaders
  'nvim-colorpicker.filetypes.adapters.shader',
  'nvim-colorpicker.filetypes.adapters.rust',
  'nvim-colorpicker.filetypes.adapters.cpp',
  'nvim-colorpicker.filetypes.adapters.go',
}

-- Auto-register all built-in adapters on module load
-- Note: Adapters do NOT self-register to avoid circular dependencies
local function setup()
  for _, adapter_module in ipairs(BUILTIN_ADAPTERS) do
    local ok, adapter = pcall(require, adapter_module)
    if ok and adapter and adapter.filetypes then
      M.register(adapter)
    elseif not ok then
      -- Log error for debugging
      vim.schedule(function()
        vim.notify('[nvim-colorpicker] Failed to load adapter: ' .. adapter_module .. '\n' .. tostring(adapter), vim.log.levels.DEBUG)
      end)
    end
  end
end

setup()

return M
