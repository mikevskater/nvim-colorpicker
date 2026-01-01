---@module 'nvim-colorpicker.filetypes.adapters.dart'
---@brief Dart adapter for Flutter

local base = require('nvim-colorpicker.filetypes.base')
local patterns = require('nvim-colorpicker.filetypes.patterns')

---@class DartAdapter : BaseAdapter
local DartAdapter = base.BaseAdapter.new({
  filetypes = { "dart" },
  default_format = "color_constructor",
  value_range = "0-255",
  patterns = patterns.combine(
    -- Flutter Color patterns
    {
      -- Color(0xAARRGGBB) - most common
      { pattern = "Color%s*%(%s*0x%x%x%x%x%x%x%x%x%s*%)", format = "color_constructor", priority = 100 },
      -- Color.fromARGB(a, r, g, b)
      { pattern = "Color%.fromARGB%s*%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*,%s*%d+%s*%)", format = "from_argb", priority = 95 },
      -- Color.fromRGBO(r, g, b, opacity)
      { pattern = "Color%.fromRGBO%s*%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*,%s*[%d%.]+%s*%)", format = "from_rgbo", priority = 95 },
    },
    -- Standard hex patterns (in string literals)
    patterns.universal
  ),
})

---Format a hex color to Dart/Flutter format
---@param hex string The hex color
---@param format string Target format
---@param alpha number? Alpha value 0-100
---@return string formatted The formatted color string
function DartAdapter:format_color(hex, format, alpha)
  local r, g, b = self:hex_to_rgb(hex)
  local a = alpha and self:alpha_to_byte(alpha) or 255

  if format == "color_constructor" then
    -- Color(0xAARRGGBB)
    return string.format("Color(0x%02X%02X%02X%02X)", a, r, g, b)
  elseif format == "from_argb" then
    -- Color.fromARGB(a, r, g, b)
    return string.format("Color.fromARGB(%d, %d, %d, %d)", a, r, g, b)
  elseif format == "from_rgbo" then
    -- Color.fromRGBO(r, g, b, opacity)
    local opacity = alpha and self:alpha_to_decimal(alpha) or 1.0
    return string.format("Color.fromRGBO(%d, %d, %d, %.2f)", r, g, b, opacity)
  elseif format == "hex" or format == "hex8" then
    if alpha and alpha < 100 then
      return hex .. string.format("%02X", a)
    end
    return hex
  end

  return hex
end

---Parse a Dart color string to hex
---@param match string The matched string
---@param format string The format type
---@return string? hex Hex color
---@return number? alpha Alpha value 0-100
function DartAdapter:parse_color(match, format)
  if format == "color_constructor" then
    -- Color(0xAARRGGBB)
    local hex_str = match:match("Color%s*%(%s*0x(%x%x%x%x%x%x%x%x)%s*%)")
    if hex_str then
      local a = tonumber(hex_str:sub(1, 2), 16)
      local alpha = self:byte_to_alpha(a)
      return "#" .. hex_str:sub(3, 8):upper(), alpha
    end
  elseif format == "from_argb" then
    -- Color.fromARGB(a, r, g, b)
    local a, r, g, b = match:match("Color%.fromARGB%s*%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%)")
    if a and r and g and b then
      local alpha = self:byte_to_alpha(tonumber(a))
      return self:rgb_to_hex(tonumber(r), tonumber(g), tonumber(b)), alpha
    end
  elseif format == "from_rgbo" then
    -- Color.fromRGBO(r, g, b, opacity)
    local r, g, b, o = match:match("Color%.fromRGBO%s*%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*,%s*([%d%.]+)%s*%)")
    if r and g and b and o then
      local alpha = self:decimal_to_alpha(tonumber(o))
      return self:rgb_to_hex(tonumber(r), tonumber(g), tonumber(b)), alpha
    end
  elseif format == "hex" then
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
  end

  -- Fallback
  local color_format = require('nvim-colorpicker.color.format')
  return color_format.parse_color_string(match)
end

return DartAdapter
