---@module 'nvim-colorpicker.filetypes.adapters.kotlin'
---@brief Kotlin/Java adapter for Android and Jetpack Compose

local base = require('nvim-colorpicker.filetypes.base')
local patterns = require('nvim-colorpicker.filetypes.patterns')

---@class KotlinAdapter : BaseAdapter
local KotlinAdapter = base.BaseAdapter.new({
  filetypes = { "kotlin", "java" },
  default_format = "color_constructor",
  value_range = "0-255",
  patterns = patterns.combine(
    -- Android/Compose Color patterns
    {
      -- Color(0xAARRGGBB) - Compose style
      { pattern = "Color%s*%(%s*0x%x%x%x%x%x%x%x%x%s*%)", format = "color_constructor", priority = 100 },
      -- Color.parseColor("#RRGGBB") or Color.parseColor("#AARRGGBB")
      { pattern = 'Color%.parseColor%s*%(%s*"#%x%x%x%x%x%x%x?%x?"%s*%)', format = "parse_color", priority = 95 },
      -- Standalone 0xAARRGGBB (common in Android)
      { pattern = "0x%x%x%x%x%x%x%x%x", format = "hex_argb", priority = 90 },
      -- 0xRRGGBB without alpha
      { pattern = "0x%x%x%x%x%x%x", format = "hex_numeric", priority = 85 },
    },
    -- Standard hex patterns as fallback
    patterns.universal
  ),
})

---Format a hex color to Kotlin/Android format
---@param hex string The hex color
---@param format string Target format
---@param alpha number? Alpha value 0-100
---@return string formatted The formatted color string
function KotlinAdapter:format_color(hex, format, alpha)
  local r, g, b = self:hex_to_rgb(hex)
  local a = alpha and self:alpha_to_byte(alpha) or 255

  if format == "color_constructor" then
    -- Compose: Color(0xAARRGGBB)
    return string.format("Color(0x%02X%02X%02X%02X)", a, r, g, b)
  elseif format == "parse_color" then
    -- Color.parseColor("#AARRGGBB") or Color.parseColor("#RRGGBB")
    if alpha and alpha < 100 then
      return string.format('Color.parseColor("#%02X%02X%02X%02X")', a, r, g, b)
    end
    return string.format('Color.parseColor("#%02X%02X%02X")', r, g, b)
  elseif format == "hex_argb" then
    -- 0xAARRGGBB
    return string.format("0x%02X%02X%02X%02X", a, r, g, b)
  elseif format == "hex_numeric" then
    -- 0xRRGGBB (no alpha)
    return string.format("0x%02X%02X%02X", r, g, b)
  elseif format == "hex" or format == "hex8" then
    if alpha and alpha < 100 then
      return hex .. string.format("%02X", a)
    end
    return hex
  end

  return hex
end

---Parse a Kotlin color string to hex
---@param match string The matched string
---@param format string The format type
---@return string? hex Hex color
---@return number? alpha Alpha value 0-100
function KotlinAdapter:parse_color(match, format)
  if format == "color_constructor" then
    -- Color(0xAARRGGBB)
    local hex_str = match:match("Color%s*%(%s*0x(%x%x%x%x%x%x%x%x)%s*%)")
    if hex_str then
      local a = tonumber(hex_str:sub(1, 2), 16)
      local alpha = self:byte_to_alpha(a)
      return "#" .. hex_str:sub(3, 8):upper(), alpha
    end
  elseif format == "parse_color" then
    -- Color.parseColor("#RRGGBB") or Color.parseColor("#AARRGGBB")
    local hex_str = match:match('Color%.parseColor%s*%(%s*"#(%x+)"%s*%)')
    if hex_str then
      if #hex_str == 8 then
        -- #AARRGGBB
        local a = tonumber(hex_str:sub(1, 2), 16)
        local alpha = self:byte_to_alpha(a)
        return "#" .. hex_str:sub(3, 8):upper(), alpha
      elseif #hex_str == 6 then
        return "#" .. hex_str:upper(), nil
      end
    end
  elseif format == "hex_argb" then
    -- 0xAARRGGBB
    local hex_str = match:match("0x(%x%x%x%x%x%x%x%x)")
    if hex_str then
      local a = tonumber(hex_str:sub(1, 2), 16)
      local alpha = self:byte_to_alpha(a)
      return "#" .. hex_str:sub(3, 8):upper(), alpha
    end
  elseif format == "hex_numeric" then
    -- 0xRRGGBB
    local hex_str = match:match("0x(%x%x%x%x%x%x)")
    if hex_str then
      return "#" .. hex_str:upper(), nil
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

return KotlinAdapter
