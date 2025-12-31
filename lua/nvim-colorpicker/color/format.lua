---@module 'nvim-colorpicker.color.format'
---@brief Color formatting, parsing, and component handling

local hex_module = require('nvim-colorpicker.color.hex')
local hsl_module = require('nvim-colorpicker.color.hsl')
local hsv_module = require('nvim-colorpicker.color.hsv')
local cmyk_module = require('nvim-colorpicker.color.cmyk')

local M = {}

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
    local h, s, l = hsl_module.hex_to_hsl(hex)
    return {
      { key = "h", label = "H", value = h, unit = "deg" },
      { key = "s", label = "S", value = s, unit = "pct" },
      { key = "l", label = "L", value = l, unit = "pct" },
    }
  elseif mode == "rgb" then
    local r, g, b = hex_module.hex_to_rgb(hex)
    return {
      { key = "r", label = "R", value = r, unit = "int" },
      { key = "g", label = "G", value = g, unit = "int" },
      { key = "b", label = "B", value = b, unit = "int" },
    }
  elseif mode == "cmyk" then
    local c, m, y, k = cmyk_module.hex_to_cmyk(hex)
    return {
      { key = "c", label = "C", value = c, unit = "pct" },
      { key = "m", label = "M", value = m, unit = "pct" },
      { key = "y", label = "Y", value = y, unit = "pct" },
      { key = "k", label = "K", value = k, unit = "pct" },
    }
  elseif mode == "hsv" then
    local h, s, v = hsv_module.hex_to_hsv(hex)
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
    return hsl_module.hsl_to_hex(h, s, l)
  elseif mode == "rgb" then
    local r = components.r or 128
    local g = components.g or 128
    local b = components.b or 128
    return hex_module.rgb_to_hex(r, g, b)
  elseif mode == "cmyk" then
    local c = components.c or 0
    local m = components.m or 0
    local y = components.y or 0
    local k = components.k or 0
    return cmyk_module.cmyk_to_hex(c, m, y, k)
  elseif mode == "hsv" then
    local h = components.h or 0
    local s = components.s or 0
    local v = components.v or 100
    return hsv_module.hsv_to_hex(h, s, v)
  end

  return "#808080"
end

---Convert a color string to a different format
---@param color string Color string (hex, rgb(), hsl())
---@param target_format "hex"|"rgb"|"hsl"|"hsv" Target format
---@param alpha number? Optional alpha value (0-100). If nil, extracts from input color.
---@return string? converted Converted color string, or nil if invalid
function M.convert_format(color, target_format, alpha)
  -- Parse the input color to hex first (also extracts alpha)
  local hex, detected_alpha = M.parse_color_string(color)
  if not hex then return nil end

  -- Use provided alpha, or detected alpha, or nil (no alpha)
  local final_alpha = alpha or detected_alpha

  -- Convert to target format
  if target_format == "hex" then
    if final_alpha and final_alpha < 100 then
      -- Include alpha as hex byte
      local alpha_byte = math.floor(final_alpha * 255 / 100 + 0.5)
      return hex .. string.format("%02X", alpha_byte)
    end
    return hex
  elseif target_format == "rgb" then
    local r, g, b = hex_module.hex_to_rgb(hex)
    if final_alpha and final_alpha < 100 then
      return string.format("rgba(%d, %d, %d, %.2f)", math.floor(r + 0.5), math.floor(g + 0.5), math.floor(b + 0.5), final_alpha / 100)
    end
    return string.format("rgb(%d, %d, %d)", math.floor(r + 0.5), math.floor(g + 0.5), math.floor(b + 0.5))
  elseif target_format == "hsl" then
    local h, s, l = hsl_module.hex_to_hsl(hex)
    if final_alpha and final_alpha < 100 then
      return string.format("hsla(%d, %d%%, %d%%, %.2f)", math.floor(h + 0.5), math.floor(s + 0.5), math.floor(l + 0.5), final_alpha / 100)
    end
    return string.format("hsl(%d, %d%%, %d%%)", math.floor(h + 0.5), math.floor(s + 0.5), math.floor(l + 0.5))
  elseif target_format == "hsv" then
    local h, s, v = hsv_module.hex_to_hsv(hex)
    if final_alpha and final_alpha < 100 then
      return string.format("hsva(%d, %d%%, %d%%, %.2f)", math.floor(h + 0.5), math.floor(s + 0.5), math.floor(v + 0.5), final_alpha / 100)
    end
    return string.format("hsv(%d, %d%%, %d%%)", math.floor(h + 0.5), math.floor(s + 0.5), math.floor(v + 0.5))
  end

  return nil
end

---Parse any color string format to hex
---@param color string Color string (hex, rgb(), rgba(), hsl(), hsla(), hsv())
---@return string? hex Hex color or nil if invalid
---@return number? alpha Alpha value 0-100 or nil if no alpha
function M.parse_color_string(color)
  if not color or type(color) ~= "string" then return nil end

  color = color:match("^%s*(.-)%s*$") -- trim
  if color == "" then return nil end

  -- Hex format: #RGB, #RRGGBB, #RRGGBBAA
  if color:match("^#?%x+$") then
    local hex = color:gsub("^#", "")
    if #hex == 3 then
      -- Expand shorthand #RGB to #RRGGBB
      hex = hex:sub(1, 1):rep(2) .. hex:sub(2, 2):rep(2) .. hex:sub(3, 3):rep(2)
      return "#" .. hex:upper(), nil
    elseif #hex == 6 then
      return "#" .. hex:upper(), nil
    elseif #hex == 8 then
      -- 8-digit hex with alpha - extract alpha as percentage
      local alpha_byte = tonumber(hex:sub(7, 8), 16)
      local alpha_pct = math.floor(alpha_byte * 100 / 255 + 0.5)
      return "#" .. hex:sub(1, 6):upper(), alpha_pct
    end
  end

  -- RGBA format: rgba(r, g, b, a) - with alpha
  local r, g, b, a = color:match("rgba%s*%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*,%s*([%d%.]+)")
  if r and g and b and a then
    local alpha_val = tonumber(a)
    -- Alpha can be 0-1 decimal or 0-100 percentage
    local alpha_pct = alpha_val <= 1 and math.floor(alpha_val * 100 + 0.5) or math.floor(alpha_val + 0.5)
    return hex_module.rgb_to_hex(tonumber(r), tonumber(g), tonumber(b)), alpha_pct
  end

  -- RGB format: rgb(r, g, b) - integer values (no alpha)
  r, g, b = color:match("rgb%s*%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
  if r and g and b then
    return hex_module.rgb_to_hex(tonumber(r), tonumber(g), tonumber(b)), nil
  end

  -- RGB format with percentage values: rgb(r%, g%, b%)
  local rp, gp, bp = color:match("rgba?%s*%(%s*([%d%.]+)%%%s*,%s*([%d%.]+)%%%s*,%s*([%d%.]+)%%")
  if rp and gp and bp then
    local rv = math.floor(tonumber(rp) * 255 / 100 + 0.5)
    local gv = math.floor(tonumber(gp) * 255 / 100 + 0.5)
    local bv = math.floor(tonumber(bp) * 255 / 100 + 0.5)
    return hex_module.rgb_to_hex(rv, gv, bv), nil
  end

  -- HSLA format: hsla(h, s%, l%, a)
  local h, s, l
  h, s, l, a = color:match("hsla%s*%(%s*(%d+)%s*,%s*(%d+)%%%s*,%s*(%d+)%%%s*,%s*([%d%.]+)")
  if h and s and l and a then
    local alpha_val = tonumber(a)
    local alpha_pct = alpha_val <= 1 and math.floor(alpha_val * 100 + 0.5) or math.floor(alpha_val + 0.5)
    return hsl_module.hsl_to_hex(tonumber(h), tonumber(s), tonumber(l)), alpha_pct
  end

  -- HSL format: hsl(h, s%, l%) (no alpha)
  h, s, l = color:match("hsl%s*%(%s*(%d+)%s*,%s*(%d+)%%%s*,%s*(%d+)%%")
  if h and s and l then
    return hsl_module.hsl_to_hex(tonumber(h), tonumber(s), tonumber(l)), nil
  end

  -- HSVA format: hsva(h, s%, v%, a)
  local hh, ss, v
  hh, ss, v, a = color:match("hsva%s*%(%s*(%d+)%s*,%s*(%d+)%%%s*,%s*(%d+)%%%s*,%s*([%d%.]+)")
  if hh and ss and v and a then
    local alpha_val = tonumber(a)
    local alpha_pct = alpha_val <= 1 and math.floor(alpha_val * 100 + 0.5) or math.floor(alpha_val + 0.5)
    return hsv_module.hsv_to_hex(tonumber(hh), tonumber(ss), tonumber(v)), alpha_pct
  end

  -- HSV format: hsv(h, s%, v%) - with percent signs (no alpha)
  hh, ss, v = color:match("hsv%s*%(%s*(%d+)%s*,%s*(%d+)%%%s*,%s*(%d+)%%")
  if hh and ss and v then
    return hsv_module.hsv_to_hex(tonumber(hh), tonumber(ss), tonumber(v)), nil
  end

  -- HSV format: hsv(h, s, v) - without percent signs (values 0-100)
  hh, ss, v = color:match("hsv%s*%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
  if hh and ss and v then
    return hsv_module.hsv_to_hex(tonumber(hh), tonumber(ss), tonumber(v)), nil
  end

  return nil
end

return M
