---@module 'nvim-colorpicker.filetypes.adapters.csharp'
---@brief C# adapter for Unity and WPF/XAML

local base = require('nvim-colorpicker.filetypes.base')
local patterns = require('nvim-colorpicker.filetypes.patterns')

---@class CSharpAdapter : BaseAdapter
local CSharpAdapter = base.BaseAdapter.new({
  filetypes = { "cs" },
  default_format = "color32",
  value_range = "0-255",
  patterns = patterns.combine(
    -- Unity Color patterns
    {
      -- new Color32(r, g, b, a) - bytes 0-255
      { pattern = "new%s+Color32%s*%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*,%s*%d+%s*%)", format = "color32", priority = 100 },
      -- new Color(r, g, b, a) - floats 0-1
      { pattern = "new%s+Color%s*%(%s*[%d%.]+f?%s*,%s*[%d%.]+f?%s*,%s*[%d%.]+f?%s*,%s*[%d%.]+f?%s*%)", format = "color_rgba", priority = 95 },
      -- new Color(r, g, b) - floats 0-1
      { pattern = "new%s+Color%s*%(%s*[%d%.]+f?%s*,%s*[%d%.]+f?%s*,%s*[%d%.]+f?%s*%)", format = "color_rgb", priority = 90 },
      -- Color.FromArgb(a, r, g, b) - WPF style
      { pattern = "Color%.FromArgb%s*%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*,%s*%d+%s*%)", format = "from_argb", priority = 95 },
      -- Color.FromRgb(r, g, b) - WPF style
      { pattern = "Color%.FromRgb%s*%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*%)", format = "from_rgb", priority = 90 },
    },
    -- Standard hex patterns
    patterns.universal
  ),
})

---Format a hex color to C# format
---@param hex string The hex color
---@param format string Target format
---@param alpha number? Alpha value 0-100
---@return string formatted The formatted color string
function CSharpAdapter:format_color(hex, format, alpha)
  local r, g, b = self:hex_to_rgb(hex)
  local a = alpha and self:alpha_to_byte(alpha) or 255
  local rf, gf, bf = self:rgb_to_float(r, g, b)
  local af = alpha and self:alpha_to_decimal(alpha) or 1.0

  if format == "color32" then
    -- new Color32(r, g, b, a)
    return string.format("new Color32(%d, %d, %d, %d)", r, g, b, a)
  elseif format == "color_rgba" then
    -- new Color(r, g, b, a) with f suffix
    return string.format("new Color(%.3ff, %.3ff, %.3ff, %.2ff)", rf, gf, bf, af)
  elseif format == "color_rgb" then
    -- new Color(r, g, b)
    if alpha and alpha < 100 then
      -- Upgrade to rgba if alpha needed
      return string.format("new Color(%.3ff, %.3ff, %.3ff, %.2ff)", rf, gf, bf, af)
    end
    return string.format("new Color(%.3ff, %.3ff, %.3ff)", rf, gf, bf)
  elseif format == "from_argb" then
    -- Color.FromArgb(a, r, g, b)
    return string.format("Color.FromArgb(%d, %d, %d, %d)", a, r, g, b)
  elseif format == "from_rgb" then
    -- Color.FromRgb(r, g, b)
    if alpha and alpha < 100 then
      return string.format("Color.FromArgb(%d, %d, %d, %d)", a, r, g, b)
    end
    return string.format("Color.FromRgb(%d, %d, %d)", r, g, b)
  elseif format == "hex" or format == "hex8" then
    if alpha and alpha < 100 then
      return hex .. string.format("%02X", a)
    end
    return hex
  end

  return hex
end

---Parse a C# color string to hex
---@param match string The matched string
---@param format string The format type
---@return string? hex Hex color
---@return number? alpha Alpha value 0-100
function CSharpAdapter:parse_color(match, format)
  if format == "color32" then
    -- new Color32(r, g, b, a)
    local r, g, b, a = match:match("new%s+Color32%s*%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%)")
    if r and g and b and a then
      local alpha = self:byte_to_alpha(tonumber(a))
      return self:rgb_to_hex(tonumber(r), tonumber(g), tonumber(b)), alpha
    end
  elseif format == "color_rgba" then
    -- new Color(r, g, b, a)
    local rf, gf, bf, af = match:match("new%s+Color%s*%(%s*([%d%.]+)f?%s*,%s*([%d%.]+)f?%s*,%s*([%d%.]+)f?%s*,%s*([%d%.]+)f?%s*%)")
    if rf and gf and bf and af then
      local r, g, b = self:float_to_rgb(tonumber(rf), tonumber(gf), tonumber(bf))
      local alpha = self:decimal_to_alpha(tonumber(af))
      return self:rgb_to_hex(r, g, b), alpha
    end
  elseif format == "color_rgb" then
    -- new Color(r, g, b)
    local rf, gf, bf = match:match("new%s+Color%s*%(%s*([%d%.]+)f?%s*,%s*([%d%.]+)f?%s*,%s*([%d%.]+)f?%s*%)")
    if rf and gf and bf then
      local r, g, b = self:float_to_rgb(tonumber(rf), tonumber(gf), tonumber(bf))
      return self:rgb_to_hex(r, g, b), nil
    end
  elseif format == "from_argb" then
    -- Color.FromArgb(a, r, g, b)
    local a, r, g, b = match:match("Color%.FromArgb%s*%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%)")
    if a and r and g and b then
      local alpha = self:byte_to_alpha(tonumber(a))
      return self:rgb_to_hex(tonumber(r), tonumber(g), tonumber(b)), alpha
    end
  elseif format == "from_rgb" then
    -- Color.FromRgb(r, g, b)
    local r, g, b = match:match("Color%.FromRgb%s*%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%)")
    if r and g and b then
      return self:rgb_to_hex(tonumber(r), tonumber(g), tonumber(b)), nil
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

return CSharpAdapter
