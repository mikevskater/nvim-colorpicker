---@module 'nvim-colorpicker.color.hsv'
---@brief HSV color conversions

local hex_module = require('nvim-colorpicker.color.hex')

local M = {}

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
  local r, g, b = hex_module.hex_to_rgb(hex)
  return M.rgb_to_hsv(r, g, b)
end

---Convert HSV to hex
---@param h number Hue (0-360)
---@param s number Saturation (0-100)
---@param v number Value (0-100)
---@return string hex
function M.hsv_to_hex(h, s, v)
  local r, g, b = M.hsv_to_rgb(h, s, v)
  return hex_module.rgb_to_hex(r, g, b)
end

return M
