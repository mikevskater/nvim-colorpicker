---@module 'nvim-colorpicker.filetypes.adapters.lua'
---@brief Lua adapter for Neovim configs, Love2D, and general Lua

local base = require('nvim-colorpicker.filetypes.base')
local patterns = require('nvim-colorpicker.filetypes.patterns')

---@class LuaAdapter : BaseAdapter
local LuaAdapter = base.BaseAdapter.new({
  filetypes = { "lua" },
  default_format = "hex",
  value_range = "0-255",  -- Can also be 0-1 for Love2D
  patterns = patterns.combine(
    -- Vim highlight patterns (common in Neovim configs)
    patterns.vim_highlight,
    -- Love2D float table patterns {r, g, b} or {r, g, b, a} with 0-1 values
    {
      { pattern = "%{%s*[01]?%.?%d*%s*,%s*[01]?%.?%d*%s*,%s*[01]?%.?%d*%s*,%s*[01]?%.?%d*%s*%}", format = "float_table_alpha", priority = 95 },
      { pattern = "%{%s*[01]?%.?%d*%s*,%s*[01]?%.?%d*%s*,%s*[01]?%.?%d*%s*%}", format = "float_table", priority = 90 },
    },
    -- Standard hex patterns
    patterns.universal
  ),
})

---Format a hex color to Lua format
---@param hex string The hex color
---@param format string Target format
---@param alpha number? Alpha value 0-100
---@return string formatted The formatted color string
function LuaAdapter:format_color(hex, format, alpha)
  local r, g, b = self:hex_to_rgb(hex)
  local has_alpha = alpha and alpha < 100

  if format == "hex" or format == "hex3" or format == "hex8" then
    if has_alpha then
      return hex .. string.format("%02X", self:alpha_to_byte(alpha))
    end
    return hex
  elseif format == "vim" then
    -- Just return hex (the guifg=/guibg= prefix is preserved during replacement)
    return hex
  elseif format == "float_table" then
    -- Love2D style: {r, g, b} with 0-1 values
    local rf, gf, bf = self:rgb_to_float(r, g, b)
    if has_alpha then
      return string.format("{%.3f, %.3f, %.3f, %.3f}", rf, gf, bf, self:alpha_to_decimal(alpha))
    end
    return string.format("{%.3f, %.3f, %.3f}", rf, gf, bf)
  elseif format == "float_table_alpha" then
    local rf, gf, bf = self:rgb_to_float(r, g, b)
    local af = has_alpha and self:alpha_to_decimal(alpha) or 1.0
    return string.format("{%.3f, %.3f, %.3f, %.3f}", rf, gf, bf, af)
  end

  return hex
end

---Parse a Lua color string to hex
---@param match string The matched string
---@param format string The format type
---@return string? hex Hex color
---@return number? alpha Alpha value 0-100
function LuaAdapter:parse_color(match, format)
  if format == "hex" then
    return self:normalize_hex(match), nil
  elseif format == "hex3" then
    local short = match:gsub("^#", "")
    if #short == 3 then
      local expanded = short:sub(1, 1):rep(2) .. short:sub(2, 2):rep(2) .. short:sub(3, 3):rep(2)
      return "#" .. expanded:upper(), nil
    end
  elseif format == "hex8" then
    local alpha_hex = match:sub(8, 9)
    local alpha_int = tonumber(alpha_hex, 16)
    local alpha = alpha_int and self:byte_to_alpha(alpha_int) or nil
    return "#" .. match:sub(2, 7):upper(), alpha
  elseif format == "vim" then
    local hex_str = match:match("#(%x%x%x%x%x%x)")
    if hex_str then
      return "#" .. hex_str:upper(), nil
    end
  elseif format == "float_table" then
    local rf, gf, bf = match:match("%{%s*([%d%.]+)%s*,%s*([%d%.]+)%s*,%s*([%d%.]+)%s*%}")
    if rf and gf and bf then
      local r, g, b = self:float_to_rgb(tonumber(rf), tonumber(gf), tonumber(bf))
      return self:rgb_to_hex(r, g, b), nil
    end
  elseif format == "float_table_alpha" then
    local rf, gf, bf, af = match:match("%{%s*([%d%.]+)%s*,%s*([%d%.]+)%s*,%s*([%d%.]+)%s*,%s*([%d%.]+)%s*%}")
    if rf and gf and bf and af then
      local r, g, b = self:float_to_rgb(tonumber(rf), tonumber(gf), tonumber(bf))
      local alpha = self:decimal_to_alpha(tonumber(af))
      return self:rgb_to_hex(r, g, b), alpha
    end
  end

  -- Fallback to base parsing
  local color_format = require('nvim-colorpicker.color.format')
  return color_format.parse_color_string(match)
end

return LuaAdapter
