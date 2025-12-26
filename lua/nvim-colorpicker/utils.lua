---@module 'nvim-colorpicker.utils'
---@brief Color conversion and manipulation utilities
---
---This module provides pure math functions for color space conversions
---and color manipulation. It has zero external dependencies.

---@class NvimColorPickerUtils
---Color conversion and manipulation utilities
local M = {}

-- ============================================================================
-- Hex <-> RGB Conversions
-- ============================================================================

---Parse hex color string to RGB components
---@param hex string Hex color like "#FF5500" or "FF5500"
---@return number r Red (0-255)
---@return number g Green (0-255)
---@return number b Blue (0-255)
function M.hex_to_rgb(hex)
  hex = hex:gsub("^#", "")
  if #hex ~= 6 then
    return 128, 128, 128 -- fallback gray
  end
  local r = tonumber(hex:sub(1, 2), 16) or 128
  local g = tonumber(hex:sub(3, 4), 16) or 128
  local b = tonumber(hex:sub(5, 6), 16) or 128
  return r, g, b
end

---Convert RGB components to hex string
---@param r number Red (0-255)
---@param g number Green (0-255)
---@param b number Blue (0-255)
---@return string hex Hex color like "#FF5500"
function M.rgb_to_hex(r, g, b)
  r = math.max(0, math.min(255, math.floor(r + 0.5)))
  g = math.max(0, math.min(255, math.floor(g + 0.5)))
  b = math.max(0, math.min(255, math.floor(b + 0.5)))
  return string.format("#%02X%02X%02X", r, g, b)
end

-- ============================================================================
-- RGB <-> HSL Conversions
-- ============================================================================

---Convert RGB to HSL
---@param r number Red (0-255)
---@param g number Green (0-255)
---@param b number Blue (0-255)
---@return number h Hue (0-360)
---@return number s Saturation (0-100)
---@return number l Lightness (0-100)
function M.rgb_to_hsl(r, g, b)
  r, g, b = r / 255, g / 255, b / 255

  local max = math.max(r, g, b)
  local min = math.min(r, g, b)
  local h, s, l

  l = (max + min) / 2

  if max == min then
    h, s = 0, 0 -- achromatic
  else
    local d = max - min
    s = l > 0.5 and d / (2 - max - min) or d / (max + min)

    if max == r then
      h = (g - b) / d + (g < b and 6 or 0)
    elseif max == g then
      h = (b - r) / d + 2
    else
      h = (r - g) / d + 4
    end

    h = h / 6
  end

  return h * 360, s * 100, l * 100
end

---Helper for HSL to RGB conversion
---@param p number
---@param q number
---@param t number
---@return number
local function hue_to_rgb(p, q, t)
  if t < 0 then t = t + 1 end
  if t > 1 then t = t - 1 end
  if t < 1/6 then return p + (q - p) * 6 * t end
  if t < 1/2 then return q end
  if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
  return p
end

---Convert HSL to RGB
---@param h number Hue (0-360)
---@param s number Saturation (0-100)
---@param l number Lightness (0-100)
---@return number r Red (0-255)
---@return number g Green (0-255)
---@return number b Blue (0-255)
function M.hsl_to_rgb(h, s, l)
  h, s, l = h / 360, s / 100, l / 100

  local r, g, b

  if s == 0 then
    r, g, b = l, l, l -- achromatic
  else
    local q = l < 0.5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q
    r = hue_to_rgb(p, q, h + 1/3)
    g = hue_to_rgb(p, q, h)
    b = hue_to_rgb(p, q, h - 1/3)
  end

  return r * 255, g * 255, b * 255
end

-- ============================================================================
-- Hex <-> HSL Conversions (convenience)
-- ============================================================================

---Convert hex to HSL
---@param hex string Hex color
---@return number h Hue (0-360)
---@return number s Saturation (0-100)
---@return number l Lightness (0-100)
function M.hex_to_hsl(hex)
  local r, g, b = M.hex_to_rgb(hex)
  return M.rgb_to_hsl(r, g, b)
end

---Convert HSL to hex
---@param h number Hue (0-360)
---@param s number Saturation (0-100)
---@param l number Lightness (0-100)
---@return string hex
function M.hsl_to_hex(h, s, l)
  local r, g, b = M.hsl_to_rgb(h, s, l)
  return M.rgb_to_hex(r, g, b)
end

-- ============================================================================
-- Color Manipulation
-- ============================================================================

---Adjust hue of a color
---@param hex string Base hex color
---@param delta number Hue adjustment (-360 to 360)
---@return string hex New hex color
function M.adjust_hue(hex, delta)
  local h, s, l = M.hex_to_hsl(hex)
  h = (h + delta) % 360
  if h < 0 then h = h + 360 end
  return M.hsl_to_hex(h, s, l)
end

---Adjust saturation of a color
---@param hex string Base hex color
---@param delta number Saturation adjustment (-100 to 100)
---@return string hex New hex color
function M.adjust_saturation(hex, delta)
  local h, s, l = M.hex_to_hsl(hex)
  s = math.max(0, math.min(100, s + delta))
  return M.hsl_to_hex(h, s, l)
end

---Adjust lightness of a color
---@param hex string Base hex color
---@param delta number Lightness adjustment (-100 to 100)
---@return string hex New hex color
function M.adjust_lightness(hex, delta)
  local h, s, l = M.hex_to_hsl(hex)
  l = math.max(0, math.min(100, l + delta))
  return M.hsl_to_hex(h, s, l)
end

---Get color at specific HSL offset from base color
---@param hex string Base hex color
---@param hue_offset number Hue offset
---@param lightness_offset number Lightness offset
---@param saturation_offset number Saturation offset
---@return string hex New hex color
function M.get_offset_color(hex, hue_offset, lightness_offset, saturation_offset)
  local h, s, l = M.hex_to_hsl(hex)

  h = (h + hue_offset) % 360
  if h < 0 then h = h + 360 end

  s = math.max(0, math.min(100, s + saturation_offset))
  l = math.max(0, math.min(100, l + lightness_offset))

  return M.hsl_to_hex(h, s, l)
end

-- ============================================================================
-- Contrast and Luminance
-- ============================================================================

---Calculate relative luminance of a color
---@param hex string Hex color
---@return number luminance (0-1)
function M.get_luminance(hex)
  local r, g, b = M.hex_to_rgb(hex)
  -- Relative luminance formula (WCAG)
  local function to_linear(c)
    c = c / 255
    return c <= 0.03928 and c / 12.92 or ((c + 0.055) / 1.055) ^ 2.4
  end
  return 0.2126 * to_linear(r) + 0.7152 * to_linear(g) + 0.0722 * to_linear(b)
end

---Get contrasting color (black or white) for text on given background
---@param hex string Background hex color
---@return string hex Contrasting text color (#000000 or #FFFFFF)
function M.get_contrast_color(hex)
  local luminance = M.get_luminance(hex)
  return luminance > 0.179 and "#000000" or "#FFFFFF"
end

---Get inverted color
---@param hex string Hex color
---@return string hex Inverted color
function M.invert_color(hex)
  local r, g, b = M.hex_to_rgb(hex)
  return M.rgb_to_hex(255 - r, 255 - g, 255 - b)
end

-- ============================================================================
-- Validation
-- ============================================================================

---Check if string is a valid hex color
---@param hex string
---@return boolean
function M.is_valid_hex(hex)
  if type(hex) ~= "string" then return false end
  hex = hex:gsub("^#", "")
  return #hex == 6 and hex:match("^%x+$") ~= nil
end

---Normalize hex color (ensure # prefix and uppercase)
---@param hex string
---@return string
function M.normalize_hex(hex)
  if not M.is_valid_hex(hex) then
    return "#808080" -- fallback gray
  end
  hex = hex:gsub("^#", ""):upper()
  return "#" .. hex
end

-- ============================================================================
-- Color Steps for Grid
-- ============================================================================

---Default step sizes for color navigation
M.STEPS = {
  hue = 3,        -- degrees per step
  saturation = 2, -- percent per step
  lightness = 2,  -- percent per step
}

---Generate a row of colors varying by hue
---@param base_hex string Center color
---@param count number Total colors in row (should be odd)
---@param hue_step number Hue change per cell
---@param lightness_offset number Additional lightness offset for this row
---@param saturation_offset number Additional saturation offset
---@return string[] colors Array of hex colors
function M.generate_hue_row(base_hex, count, hue_step, lightness_offset, saturation_offset)
  local colors = {}
  local half = math.floor(count / 2)

  for i = 1, count do
    local hue_offset = (i - half - 1) * hue_step
    local color = M.get_offset_color(base_hex, hue_offset, lightness_offset, saturation_offset)
    table.insert(colors, color)
  end

  return colors
end

---Generate full color grid
---@param center_hex string Center color of grid
---@param width number Grid width (columns, should be odd)
---@param height number Grid height (rows, should be odd)
---@param hue_step number Hue change per horizontal cell
---@param lightness_step number Lightness change per vertical cell
---@return string[][] grid 2D array of hex colors [row][col]
function M.generate_color_grid(center_hex, width, height, hue_step, lightness_step)
  local grid = {}
  local half_height = math.floor(height / 2)

  for row = 1, height do
    local lightness_offset = (half_height + 1 - row) * lightness_step
    local row_colors = M.generate_hue_row(center_hex, width, hue_step, lightness_offset, 0)
    table.insert(grid, row_colors)
  end

  return grid
end

-- ============================================================================
-- RGB <-> HSV Conversions
-- ============================================================================

---Convert RGB to HSV
---@param r number Red (0-255)
---@param g number Green (0-255)
---@param b number Blue (0-255)
---@return number h Hue (0-360)
---@return number s Saturation (0-100)
---@return number v Value (0-100)
function M.rgb_to_hsv(r, g, b)
  r, g, b = r / 255, g / 255, b / 255
  local max = math.max(r, g, b)
  local min = math.min(r, g, b)
  local h, s, v = 0, 0, max
  local d = max - min

  s = max == 0 and 0 or d / max

  if max ~= min then
    if max == r then
      h = (g - b) / d + (g < b and 6 or 0)
    elseif max == g then
      h = (b - r) / d + 2
    else
      h = (r - g) / d + 4
    end
    h = h / 6
  end

  return h * 360, s * 100, v * 100
end

---Convert HSV to RGB
---@param h number Hue (0-360)
---@param s number Saturation (0-100)
---@param v number Value (0-100)
---@return number r Red (0-255)
---@return number g Green (0-255)
---@return number b Blue (0-255)
function M.hsv_to_rgb(h, s, v)
  h, s, v = h / 360, s / 100, v / 100
  local r, g, b

  local i = math.floor(h * 6)
  local f = h * 6 - i
  local p = v * (1 - s)
  local q = v * (1 - f * s)
  local t = v * (1 - (1 - f) * s)

  i = i % 6
  if i == 0 then r, g, b = v, t, p
  elseif i == 1 then r, g, b = q, v, p
  elseif i == 2 then r, g, b = p, v, t
  elseif i == 3 then r, g, b = p, q, v
  elseif i == 4 then r, g, b = t, p, v
  else r, g, b = v, p, q
  end

  return r * 255, g * 255, b * 255
end

---Convert hex to HSV
---@param hex string Hex color
---@return number h Hue (0-360)
---@return number s Saturation (0-100)
---@return number v Value (0-100)
function M.hex_to_hsv(hex)
  local r, g, b = M.hex_to_rgb(hex)
  return M.rgb_to_hsv(r, g, b)
end

---Convert HSV to hex
---@param h number Hue (0-360)
---@param s number Saturation (0-100)
---@param v number Value (0-100)
---@return string hex
function M.hsv_to_hex(h, s, v)
  local r, g, b = M.hsv_to_rgb(h, s, v)
  return M.rgb_to_hex(r, g, b)
end

-- ============================================================================
-- RGB <-> CMYK Conversions
-- ============================================================================

---Convert RGB to CMYK
---@param r number Red (0-255)
---@param g number Green (0-255)
---@param b number Blue (0-255)
---@return number c Cyan (0-100)
---@return number m Magenta (0-100)
---@return number y Yellow (0-100)
---@return number k Key/Black (0-100)
function M.rgb_to_cmyk(r, g, b)
  r, g, b = r / 255, g / 255, b / 255

  local k = 1 - math.max(r, g, b)

  -- Pure black
  if k == 1 then
    return 0, 0, 0, 100
  end

  local c = (1 - r - k) / (1 - k)
  local m = (1 - g - k) / (1 - k)
  local y = (1 - b - k) / (1 - k)

  return c * 100, m * 100, y * 100, k * 100
end

---Convert CMYK to RGB
---@param c number Cyan (0-100)
---@param m number Magenta (0-100)
---@param y number Yellow (0-100)
---@param k number Key/Black (0-100)
---@return number r Red (0-255)
---@return number g Green (0-255)
---@return number b Blue (0-255)
function M.cmyk_to_rgb(c, m, y, k)
  c, m, y, k = c / 100, m / 100, y / 100, k / 100

  local r = 255 * (1 - c) * (1 - k)
  local g = 255 * (1 - m) * (1 - k)
  local b = 255 * (1 - y) * (1 - k)

  return r, g, b
end

---Convert hex to CMYK
---@param hex string Hex color
---@return number c Cyan (0-100)
---@return number m Magenta (0-100)
---@return number y Yellow (0-100)
---@return number k Key/Black (0-100)
function M.hex_to_cmyk(hex)
  local r, g, b = M.hex_to_rgb(hex)
  return M.rgb_to_cmyk(r, g, b)
end

---Convert CMYK to hex
---@param c number Cyan (0-100)
---@param m number Magenta (0-100)
---@param y number Yellow (0-100)
---@param k number Key/Black (0-100)
---@return string hex
function M.cmyk_to_hex(c, m, y, k)
  local r, g, b = M.cmyk_to_rgb(c, m, y, k)
  return M.rgb_to_hex(r, g, b)
end

-- ============================================================================
-- Value Formatting Helpers
-- ============================================================================

---Format a color component value for display
---@param value number The value to format
---@param unit string The unit type: "deg" (degrees), "pct" (percent), "int" (integer 0-255), "decimal"
---@param format_type "standard"|"decimal" Display format
---@return string formatted The formatted value string
function M.format_value(value, unit, format_type)
  format_type = format_type or "standard"

  if format_type == "decimal" then
    -- Convert to 0.0-1.0 range
    if unit == "deg" then
      return string.format("%.2f", value / 360)
    elseif unit == "pct" then
      return string.format("%.2f", value / 100)
    elseif unit == "int" then
      return string.format("%.2f", value / 255)
    else
      return string.format("%.2f", value)
    end
  else
    -- Standard format with units
    if unit == "deg" then
      return string.format("%d°", math.floor(value + 0.5))
    elseif unit == "pct" then
      return string.format("%d%%", math.floor(value + 0.5))
    elseif unit == "int" then
      return string.format("%d", math.floor(value + 0.5))
    else
      return string.format("%d", math.floor(value + 0.5))
    end
  end
end

---Parse a formatted value string back to a number
---@param str string The formatted string (e.g., "240°", "75%", "128", "0.67")
---@param unit string The expected unit type
---@param format_type "standard"|"decimal" The format used
---@return number|nil value The parsed value, or nil if invalid
function M.parse_value(str, unit, format_type)
  if not str or str == "" then return nil end

  -- Remove any whitespace
  str = str:match("^%s*(.-)%s*$")

  -- Try to extract number
  local num_str = str:gsub("[°%%]", "")
  local num = tonumber(num_str)

  if not num then return nil end

  if format_type == "decimal" then
    -- Convert from 0.0-1.0 range back to native range
    if unit == "deg" then
      return num * 360
    elseif unit == "pct" then
      return num * 100
    elseif unit == "int" then
      return num * 255
    else
      return num
    end
  else
    -- Standard format - value is already in native range
    return num
  end
end

---Get color components for a given mode
---@param hex string The hex color
---@param mode "hsl"|"rgb"|"cmyk"|"hsv" The color mode
---@return table[] components Array of {key, label, value, unit}
function M.get_color_components(hex, mode)
  if mode == "hsl" then
    local h, s, l = M.hex_to_hsl(hex)
    return {
      { key = "h", label = "H", value = h, unit = "deg" },
      { key = "s", label = "S", value = s, unit = "pct" },
      { key = "l", label = "L", value = l, unit = "pct" },
    }
  elseif mode == "rgb" then
    local r, g, b = M.hex_to_rgb(hex)
    return {
      { key = "r", label = "R", value = r, unit = "int" },
      { key = "g", label = "G", value = g, unit = "int" },
      { key = "b", label = "B", value = b, unit = "int" },
    }
  elseif mode == "cmyk" then
    local c, m, y, k = M.hex_to_cmyk(hex)
    return {
      { key = "c", label = "C", value = c, unit = "pct" },
      { key = "m", label = "M", value = m, unit = "pct" },
      { key = "y", label = "Y", value = y, unit = "pct" },
      { key = "k", label = "K", value = k, unit = "pct" },
    }
  elseif mode == "hsv" then
    local h, s, v = M.hex_to_hsv(hex)
    return {
      { key = "h", label = "H", value = h, unit = "deg" },
      { key = "s", label = "S", value = s, unit = "pct" },
      { key = "v", label = "V", value = v, unit = "pct" },
    }
  end

  return {}
end

---Build hex color from components
---@param components table Map of component key to value
---@param mode "hsl"|"rgb"|"cmyk"|"hsv" The color mode
---@return string hex The resulting hex color
function M.components_to_hex(components, mode)
  if mode == "hsl" then
    local h = components.h or 0
    local s = components.s or 0
    local l = components.l or 50
    return M.hsl_to_hex(h, s, l)
  elseif mode == "rgb" then
    local r = components.r or 128
    local g = components.g or 128
    local b = components.b or 128
    return M.rgb_to_hex(r, g, b)
  elseif mode == "cmyk" then
    local c = components.c or 0
    local m = components.m or 0
    local y = components.y or 0
    local k = components.k or 0
    return M.cmyk_to_hex(c, m, y, k)
  elseif mode == "hsv" then
    local h = components.h or 0
    local s = components.s or 0
    local v = components.v or 100
    return M.hsv_to_hex(h, s, v)
  end

  return "#808080"
end

-- ============================================================================
-- Format Conversion
-- ============================================================================

---Convert a color string to a different format
---@param color string Color string (hex, rgb(), hsl())
---@param target_format "hex"|"rgb"|"hsl"|"hsv" Target format
---@return string? converted Converted color string, or nil if invalid
function M.convert_format(color, target_format)
  -- Parse the input color to hex first
  local hex = M.parse_color_string(color)
  if not hex then return nil end

  -- Convert to target format
  if target_format == "hex" then
    return hex
  elseif target_format == "rgb" then
    local r, g, b = M.hex_to_rgb(hex)
    return string.format("rgb(%d, %d, %d)", math.floor(r + 0.5), math.floor(g + 0.5), math.floor(b + 0.5))
  elseif target_format == "hsl" then
    local h, s, l = M.hex_to_hsl(hex)
    return string.format("hsl(%d, %d%%, %d%%)", math.floor(h + 0.5), math.floor(s + 0.5), math.floor(l + 0.5))
  elseif target_format == "hsv" then
    local h, s, v = M.hex_to_hsv(hex)
    return string.format("hsv(%d, %d%%, %d%%)", math.floor(h + 0.5), math.floor(s + 0.5), math.floor(v + 0.5))
  end

  return nil
end

---Parse any color string format to hex
---@param color string Color string (hex, rgb(), hsl(), hsv())
---@return string? hex Hex color or nil if invalid
function M.parse_color_string(color)
  if not color or type(color) ~= "string" then return nil end

  color = color:match("^%s*(.-)%s*$") -- trim

  -- Hex format: #RGB, #RRGGBB
  if color:match("^#?%x+$") then
    local hex = color:gsub("^#", "")
    if #hex == 3 then
      -- Expand shorthand #RGB to #RRGGBB
      hex = hex:sub(1, 1):rep(2) .. hex:sub(2, 2):rep(2) .. hex:sub(3, 3):rep(2)
    end
    if #hex == 6 then
      return "#" .. hex:upper()
    end
  end

  -- RGB format: rgb(r, g, b)
  local r, g, b = color:match("rgb%s*%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%)")
  if r and g and b then
    return M.rgb_to_hex(tonumber(r), tonumber(g), tonumber(b))
  end

  -- HSL format: hsl(h, s%, l%)
  local h, s, l = color:match("hsl%s*%(%s*(%d+)%s*,%s*(%d+)%%%s*,%s*(%d+)%%%s*%)")
  if h and s and l then
    return M.hsl_to_hex(tonumber(h), tonumber(s), tonumber(l))
  end

  -- HSV format: hsv(h, s%, v%)
  local hh, ss, v = color:match("hsv%s*%(%s*(%d+)%s*,%s*(%d+)%%%s*,%s*(%d+)%%%s*%)")
  if hh and ss and v then
    return M.hsv_to_hex(tonumber(hh), tonumber(ss), tonumber(v))
  end

  return nil
end

return M
