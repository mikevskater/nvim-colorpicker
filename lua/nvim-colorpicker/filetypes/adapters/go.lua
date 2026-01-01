---@module 'nvim-colorpicker.filetypes.adapters.go'
---@brief Go adapter for image/color and general Go

local base = require('nvim-colorpicker.filetypes.base')
local patterns = require('nvim-colorpicker.filetypes.patterns')

---@class GoAdapter : BaseAdapter
local GoAdapter = base.BaseAdapter.new({
  filetypes = { "go" },
  default_format = "color_rgba",
  value_range = "0-255",
  patterns = patterns.combine(
    -- Go color patterns
    {
      -- color.RGBA{R: r, G: g, B: b, A: a} - named fields
      { pattern = "color%.RGBA%s*%{%s*R%s*:%s*%d+%s*,%s*G%s*:%s*%d+%s*,%s*B%s*:%s*%d+%s*,%s*A%s*:%s*%d+%s*%}", format = "color_rgba_named", priority = 100 },
      -- color.RGBA{r, g, b, a} - positional
      { pattern = "color%.RGBA%s*%{%s*%d+%s*,%s*%d+%s*,%s*%d+%s*,%s*%d+%s*%}", format = "color_rgba", priority = 95 },
      -- color.NRGBA{...} - non-premultiplied
      { pattern = "color%.NRGBA%s*%{%s*R%s*:%s*%d+%s*,%s*G%s*:%s*%d+%s*,%s*B%s*:%s*%d+%s*,%s*A%s*:%s*%d+%s*%}", format = "color_nrgba_named", priority = 100 },
      { pattern = "color%.NRGBA%s*%{%s*%d+%s*,%s*%d+%s*,%s*%d+%s*,%s*%d+%s*%}", format = "color_nrgba", priority = 95 },
      -- Bare struct literal {r, g, b, a} - used in array slices []color.RGBA{{r,g,b,a}, ...}
      { pattern = "%{%s*%d+%s*,%s*%d+%s*,%s*%d+%s*,%s*%d+%s*%}", format = "struct_rgba", priority = 85 },
    },
    -- Numeric hex (0xRRGGBB, 0xAARRGGBB)
    patterns.numeric_hex,
    -- Standard hex patterns (in strings)
    patterns.universal
  ),
})

---Format a hex color to Go format
---@param hex string The hex color
---@param format string Target format
---@param alpha number? Alpha value 0-100
---@return string formatted The formatted color string
function GoAdapter:format_color(hex, format, alpha)
  local r, g, b = self:hex_to_rgb(hex)
  local a = alpha and self:alpha_to_byte(alpha) or 255

  if format == "color_rgba" then
    return string.format("color.RGBA{%d, %d, %d, %d}", r, g, b, a)
  elseif format == "color_rgba_named" then
    return string.format("color.RGBA{R: %d, G: %d, B: %d, A: %d}", r, g, b, a)
  elseif format == "color_nrgba" then
    return string.format("color.NRGBA{%d, %d, %d, %d}", r, g, b, a)
  elseif format == "color_nrgba_named" then
    return string.format("color.NRGBA{R: %d, G: %d, B: %d, A: %d}", r, g, b, a)
  elseif format == "struct_rgba" then
    return string.format("{%d, %d, %d, %d}", r, g, b, a)
  elseif format == "hex_numeric" then
    return string.format("0x%s", hex:sub(2):upper())
  elseif format == "hex_numeric_argb" then
    return string.format("0x%02X%s", a, hex:sub(2):upper())
  elseif format == "hex" or format == "hex8" then
    if alpha and alpha < 100 then
      return hex .. string.format("%02X", a)
    end
    return hex
  end

  return hex
end

---Parse a Go color string to hex
---@param match string The matched string
---@param format string The format type
---@return string? hex Hex color
---@return number? alpha Alpha value 0-100
function GoAdapter:parse_color(match, format)
  if format == "color_rgba_named" or format == "color_nrgba_named" then
    local r = match:match("R%s*:%s*(%d+)")
    local g = match:match("G%s*:%s*(%d+)")
    local b = match:match("B%s*:%s*(%d+)")
    local a = match:match("A%s*:%s*(%d+)")
    if r and g and b and a then
      local alpha = self:byte_to_alpha(tonumber(a))
      return self:rgb_to_hex(tonumber(r), tonumber(g), tonumber(b)), alpha
    end
  elseif format == "color_rgba" or format == "color_nrgba" then
    local r, g, b, a = match:match("color%.N?RGBA%s*%{%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%}")
    if r and g and b and a then
      local alpha = self:byte_to_alpha(tonumber(a))
      return self:rgb_to_hex(tonumber(r), tonumber(g), tonumber(b)), alpha
    end
  elseif format == "struct_rgba" then
    local r, g, b, a = match:match("%{%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%}")
    if r and g and b and a then
      local alpha = self:byte_to_alpha(tonumber(a))
      return self:rgb_to_hex(tonumber(r), tonumber(g), tonumber(b)), alpha
    end
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
      local a = tonumber(hex_str:sub(1, 2), 16)
      local alpha = self:byte_to_alpha(a)
      return "#" .. hex_str:sub(3, 8):upper(), alpha
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

return GoAdapter
