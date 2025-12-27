---@module 'nvim-colorpicker.color.manipulation'
---@brief Color manipulation functions (adjust, contrast, luminance)

local hex_module = require('nvim-colorpicker.color.hex')
local hsl_module = require('nvim-colorpicker.color.hsl')

local M = {}

---Adjust hue of a color
---@param hex string Base hex color
---@param delta number Hue adjustment (-360 to 360)
---@return string hex New hex color
function M.adjust_hue(hex, delta)
  local h, s, l = hsl_module.hex_to_hsl(hex)
  h = (h + delta) % 360
  if h < 0 then h = h + 360 end
  return hsl_module.hsl_to_hex(h, s, l)
end

---Adjust saturation of a color
---@param hex string Base hex color
---@param delta number Saturation adjustment (-100 to 100)
---@return string hex New hex color
function M.adjust_saturation(hex, delta)
  local h, s, l = hsl_module.hex_to_hsl(hex)
  s = math.max(0, math.min(100, s + delta))
  return hsl_module.hsl_to_hex(h, s, l)
end

---Adjust lightness of a color
---@param hex string Base hex color
---@param delta number Lightness adjustment (-100 to 100)
---@return string hex New hex color
function M.adjust_lightness(hex, delta)
  local h, s, l = hsl_module.hex_to_hsl(hex)
  l = math.max(0, math.min(100, l + delta))
  return hsl_module.hsl_to_hex(h, s, l)
end

---Get color at specific HSL offset from base color
---@param hex string Base hex color
---@param hue_offset number Hue offset
---@param lightness_offset number Lightness offset
---@param saturation_offset number Saturation offset
---@return string hex New hex color
function M.get_offset_color(hex, hue_offset, lightness_offset, saturation_offset)
  local h, s, l = hsl_module.hex_to_hsl(hex)

  h = (h + hue_offset) % 360
  if h < 0 then h = h + 360 end

  s = math.max(0, math.min(100, s + saturation_offset))
  l = math.max(0, math.min(100, l + lightness_offset))

  return hsl_module.hsl_to_hex(h, s, l)
end

---Calculate relative luminance of a color
---@param hex string Hex color
---@return number luminance (0-1)
function M.get_luminance(hex)
  local r, g, b = hex_module.hex_to_rgb(hex)
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
  local r, g, b = hex_module.hex_to_rgb(hex)
  return hex_module.rgb_to_hex(255 - r, 255 - g, 255 - b)
end

return M
