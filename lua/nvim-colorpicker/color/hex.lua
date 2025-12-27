---@module 'nvim-colorpicker.color.hex'
---@brief Hex color conversions - base module for RGB/Hex operations

local M = {}

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

return M
