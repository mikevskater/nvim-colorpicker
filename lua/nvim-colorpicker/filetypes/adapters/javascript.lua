---@module 'nvim-colorpicker.filetypes.adapters.javascript'
---@brief JavaScript/TypeScript adapter for hex strings and CSS-in-JS

local base = require('nvim-colorpicker.filetypes.base')
local patterns = require('nvim-colorpicker.filetypes.patterns')

---@class JavaScriptAdapter : BaseAdapter
local JavaScriptAdapter = base.BaseAdapter.new({
  filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "json", "jsonc" },
  default_format = "hex",
  value_range = "0-255",
  patterns = patterns.combine(
    -- CSS-in-JS patterns (styled-components, emotion, etc.)
    {
      { pattern = "rgba%s*%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*[,/]%s*[%d%.]+%s*%)", format = "rgba", priority = 100 },
      { pattern = "rgb%s*%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*%)", format = "rgb", priority = 95 },
      { pattern = "hsla%s*%(%s*%d+%s*,%s*%d+%%%s*,%s*%d+%%%s*[,/]%s*[%d%.]+%s*%)", format = "hsla", priority = 100 },
      { pattern = "hsl%s*%(%s*%d+%s*,%s*%d+%%%s*,%s*%d+%%%s*%)", format = "hsl", priority = 95 },
    },
    -- Numeric hex (0xRRGGBB) - common in some JS contexts
    patterns.numeric_hex,
    -- Standard hex patterns
    patterns.universal
  ),
})

---Format a hex color to JavaScript format
---@param hex string The hex color
---@param format string Target format
---@param alpha number? Alpha value 0-100
---@return string formatted The formatted color string
function JavaScriptAdapter:format_color(hex, format, alpha)
  local r, g, b = self:hex_to_rgb(hex)
  local has_alpha = alpha and alpha < 100

  if format == "hex" or format == "hex3" or format == "hex8" then
    if has_alpha then
      return hex .. string.format("%02X", self:alpha_to_byte(alpha))
    end
    return hex
  elseif format == "hex_numeric" then
    -- 0xRRGGBB format
    return "0x" .. hex:sub(2):upper()
  elseif format == "hex_numeric_argb" then
    -- 0xAARRGGBB format
    local a = has_alpha and self:alpha_to_byte(alpha) or 255
    return string.format("0x%02X%s", a, hex:sub(2):upper())
  elseif format == "rgb" then
    if has_alpha then
      return string.format("rgba(%d, %d, %d, %.2f)", r, g, b, self:alpha_to_decimal(alpha))
    end
    return string.format("rgb(%d, %d, %d)", r, g, b)
  elseif format == "rgba" then
    local a = has_alpha and self:alpha_to_decimal(alpha) or 1
    return string.format("rgba(%d, %d, %d, %.2f)", r, g, b, a)
  elseif format == "hsl" then
    local h, s, l = self:hex_to_hsl(hex)
    if has_alpha then
      return string.format("hsla(%d, %d%%, %d%%, %.2f)", h, s, l, self:alpha_to_decimal(alpha))
    end
    return string.format("hsl(%d, %d%%, %d%%)", h, s, l)
  elseif format == "hsla" then
    local h, s, l = self:hex_to_hsl(hex)
    local a = has_alpha and self:alpha_to_decimal(alpha) or 1
    return string.format("hsla(%d, %d%%, %d%%, %.2f)", h, s, l, a)
  end

  return hex
end

---Parse a JavaScript color string to hex
---@param match string The matched string
---@param format string The format type
---@return string? hex Hex color
---@return number? alpha Alpha value 0-100
function JavaScriptAdapter:parse_color(match, format)
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
  elseif format == "hex_numeric" then
    -- 0xRRGGBB
    local hex_str = match:match("0x(%x%x%x%x%x%x)")
    if hex_str then
      return "#" .. hex_str:upper(), nil
    end
  elseif format == "hex_numeric_argb" then
    -- 0xAARRGGBB
    local hex_str = match:match("0x(%x%x%x%x%x%x%x%x)")
    if hex_str then
      local alpha_int = tonumber(hex_str:sub(1, 2), 16)
      local alpha = alpha_int and self:byte_to_alpha(alpha_int) or nil
      return "#" .. hex_str:sub(3, 8):upper(), alpha
    end
  elseif format == "rgb" then
    local r, g, b = match:match("rgb%s*%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
    if r and g and b then
      return self:rgb_to_hex(tonumber(r), tonumber(g), tonumber(b)), nil
    end
  elseif format == "rgba" then
    local r, g, b, a = match:match("rgba%s*%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*[,/]%s*([%d%.]+)")
    if r and g and b and a then
      local alpha = self:decimal_to_alpha(tonumber(a))
      return self:rgb_to_hex(tonumber(r), tonumber(g), tonumber(b)), alpha
    end
  elseif format == "hsl" then
    local h, s, l = match:match("hsl%s*%(%s*(%d+)%s*,%s*(%d+)%%%s*,%s*(%d+)%%")
    if h and s and l then
      return self:hsl_to_hex(tonumber(h), tonumber(s), tonumber(l)), nil
    end
  elseif format == "hsla" then
    local h, s, l, a = match:match("hsla%s*%(%s*(%d+)%s*,%s*(%d+)%%%s*,%s*(%d+)%%%s*[,/]%s*([%d%.]+)")
    if h and s and l and a then
      local alpha = self:decimal_to_alpha(tonumber(a))
      return self:hsl_to_hex(tonumber(h), tonumber(s), tonumber(l)), alpha
    end
  end

  -- Fallback to base parsing
  local color_format = require('nvim-colorpicker.color.format')
  return color_format.parse_color_string(match)
end

return JavaScriptAdapter
