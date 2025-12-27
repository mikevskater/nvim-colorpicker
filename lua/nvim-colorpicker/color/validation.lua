---@module 'nvim-colorpicker.color.validation'
---@brief Hex color validation and normalization

local M = {}

---Check if string is a valid hex color
---@param hex string
---@return boolean
function M.is_valid_hex(hex)
  if type(hex) ~= "string" then return false end
  hex = hex:gsub("^#", "")
  -- Support 3-digit (#RGB), 6-digit (#RRGGBB), and 8-digit (#RRGGBBAA)
  local len = #hex
  return (len == 3 or len == 6 or len == 8) and hex:match("^%x+$") ~= nil
end

---Normalize hex color (ensure # prefix, expand 3-digit to 6-digit, apply case setting)
---@param hex string
---@return string
function M.normalize_hex(hex)
  if not M.is_valid_hex(hex) then
    return "#808080" -- fallback gray
  end
  hex = hex:gsub("^#", "")
  -- Expand 3-digit to 6-digit
  if #hex == 3 then
    hex = hex:sub(1, 1):rep(2) .. hex:sub(2, 2):rep(2) .. hex:sub(3, 3):rep(2)
  elseif #hex == 8 then
    -- Strip alpha for normalization (keep first 6 chars)
    hex = hex:sub(1, 6)
  end
  -- Apply case from config (default: upper)
  local config = require('nvim-colorpicker.config').get()
  if config.hex_case == 'lower' then
    hex = hex:lower()
  else
    hex = hex:upper()
  end
  return "#" .. hex
end

return M
