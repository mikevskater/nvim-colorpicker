---@module 'nvim-colorpicker.filetypes.adapters.python'
---@brief Python adapter for hex strings and RGB tuples (Pygame, PIL, Tkinter)

local base = require('nvim-colorpicker.filetypes.base')
local patterns = require('nvim-colorpicker.filetypes.patterns')

---@class PythonAdapter : BaseAdapter
local PythonAdapter = base.BaseAdapter.new({
  filetypes = { "python" },
  default_format = "hex",
  value_range = "0-255",
  patterns = patterns.combine(
    -- Python tuple patterns (common in Pygame, PIL, Tkinter)
    {
      { pattern = "%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*,%s*%d+%s*%)", format = "tuple_rgba", priority = 95 },
      { pattern = "%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*%)", format = "tuple_rgb", priority = 90 },
    },
    -- Standard hex patterns
    patterns.universal
  ),
})

---Format a hex color to Python format
---@param hex string The hex color
---@param format string Target format
---@param alpha number? Alpha value 0-100
---@return string formatted The formatted color string
function PythonAdapter:format_color(hex, format, alpha)
  local r, g, b = self:hex_to_rgb(hex)
  local has_alpha = alpha and alpha < 100

  if format == "hex" or format == "hex3" or format == "hex8" then
    if has_alpha then
      return hex .. string.format("%02X", self:alpha_to_byte(alpha))
    end
    return hex
  elseif format == "tuple_rgb" then
    if has_alpha then
      -- If alpha needed, upgrade to tuple_rgba
      return string.format("(%d, %d, %d, %d)", r, g, b, self:alpha_to_byte(alpha))
    end
    return string.format("(%d, %d, %d)", r, g, b)
  elseif format == "tuple_rgba" then
    local a = has_alpha and self:alpha_to_byte(alpha) or 255
    return string.format("(%d, %d, %d, %d)", r, g, b, a)
  end

  return hex
end

---Parse a Python color string to hex
---@param match string The matched string
---@param format string The format type
---@return string? hex Hex color
---@return number? alpha Alpha value 0-100
function PythonAdapter:parse_color(match, format)
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
  elseif format == "tuple_rgb" then
    local r, g, b = match:match("%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%)")
    if r and g and b then
      return self:rgb_to_hex(tonumber(r), tonumber(g), tonumber(b)), nil
    end
  elseif format == "tuple_rgba" then
    local r, g, b, a = match:match("%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%)")
    if r and g and b and a then
      local alpha = self:byte_to_alpha(tonumber(a))
      return self:rgb_to_hex(tonumber(r), tonumber(g), tonumber(b)), alpha
    end
  end

  -- Fallback to base parsing
  local color_format = require('nvim-colorpicker.color.format')
  return color_format.parse_color_string(match)
end

return PythonAdapter
