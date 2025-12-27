---@module 'nvim-colorpicker.color.cmyk'
---@brief CMYK color conversions

local hex_module = require('nvim-colorpicker.color.hex')

local M = {}

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
  local r, g, b = hex_module.hex_to_rgb(hex)
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
  return hex_module.rgb_to_hex(r, g, b)
end

return M
