---@module 'nvim-colorpicker.color.hsl'
---@brief HSL color conversions

local hex_module = require('nvim-colorpicker.color.hex')

local M = {}

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

-- Export hue_to_rgb for use by other modules if needed
M.hue_to_rgb = hue_to_rgb

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

---Convert hex to HSL
---@param hex string Hex color
---@return number h Hue (0-360)
---@return number s Saturation (0-100)
---@return number l Lightness (0-100)
function M.hex_to_hsl(hex)
  local r, g, b = hex_module.hex_to_rgb(hex)
  return M.rgb_to_hsl(r, g, b)
end

---Convert HSL to hex
---@param h number Hue (0-360)
---@param s number Saturation (0-100)
---@param l number Lightness (0-100)
---@return string hex
function M.hsl_to_hex(h, s, l)
  local r, g, b = M.hsl_to_rgb(h, s, l)
  return hex_module.rgb_to_hex(r, g, b)
end

return M
