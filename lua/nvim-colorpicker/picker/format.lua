---@module 'nvim-colorpicker.picker.format'
---@brief Shared color formatting utilities for picker headers and info panels

local ColorUtils = require('nvim-colorpicker.color')

local M = {}

-- ============================================================================
-- Color Formatting
-- ============================================================================

---Format color value based on mode and format type
---@param hex string The hex color
---@param mode string Color mode (hex, hsl, rgb, hsv, cmyk)
---@param alpha number? Alpha value 0-100
---@param alpha_enabled boolean Whether alpha is enabled
---@param value_format "standard"|"decimal" Value display format
---@return string formatted The formatted color string
function M.format_color(hex, mode, alpha, alpha_enabled, value_format)
  local r, g, b = ColorUtils.hex_to_rgb(hex)
  local h, s, l = ColorUtils.hex_to_hsl(hex)
  local hv, sv, v = ColorUtils.hex_to_hsv(hex)
  local c, m, y, k = ColorUtils.hex_to_cmyk(hex)

  local is_decimal = value_format == "decimal"
  alpha = alpha or 100

  -- Alpha as hex byte for hex mode
  local alpha_hex = alpha_enabled and string.format("%02X", math.floor((alpha / 100) * 255 + 0.5)) or ""

  if mode == "hex" then
    if alpha_enabled then
      return hex .. alpha_hex
    else
      return hex
    end
  elseif mode == "hsl" then
    if is_decimal then
      local hd, sd, ld = h / 360, s / 100, l / 100
      local ad = alpha / 100
      if alpha_enabled then
        return string.format("hsla(%.2f, %.2f, %.2f, %.2f)", hd, sd, ld, ad)
      else
        return string.format("hsl(%.2f, %.2f, %.2f)", hd, sd, ld)
      end
    else
      if alpha_enabled then
        return string.format("hsla(%d, %d%%, %d%%, %d%%)", math.floor(h), math.floor(s), math.floor(l), alpha)
      else
        return string.format("hsl(%d, %d%%, %d%%)", math.floor(h), math.floor(s), math.floor(l))
      end
    end
  elseif mode == "rgb" then
    if is_decimal then
      local rd, gd, bd = r / 255, g / 255, b / 255
      local ad = alpha / 100
      if alpha_enabled then
        return string.format("rgba(%.2f, %.2f, %.2f, %.2f)", rd, gd, bd, ad)
      else
        return string.format("rgb(%.2f, %.2f, %.2f)", rd, gd, bd)
      end
    else
      if alpha_enabled then
        return string.format("rgba(%d, %d, %d, %d%%)", r, g, b, alpha)
      else
        return string.format("rgb(%d, %d, %d)", r, g, b)
      end
    end
  elseif mode == "hsv" then
    if is_decimal then
      local hvd, svd, vd = hv / 360, sv / 100, v / 100
      local ad = alpha / 100
      if alpha_enabled then
        return string.format("hsva(%.2f, %.2f, %.2f, %.2f)", hvd, svd, vd, ad)
      else
        return string.format("hsv(%.2f, %.2f, %.2f)", hvd, svd, vd)
      end
    else
      if alpha_enabled then
        return string.format("hsva(%d, %d%%, %d%%, %d%%)", math.floor(hv), math.floor(sv), math.floor(v), alpha)
      else
        return string.format("hsv(%d, %d%%, %d%%)", math.floor(hv), math.floor(sv), math.floor(v))
      end
    end
  elseif mode == "cmyk" then
    if is_decimal then
      local cd, md, yd, kd = c / 100, m / 100, y / 100, k / 100
      return string.format("cmyk(%.2f, %.2f, %.2f, %.2f)", cd, md, yd, kd)
    else
      return string.format("cmyk(%d, %d, %d, %d)", math.floor(c), math.floor(m), math.floor(y), math.floor(k))
    end
  else
    -- Fallback to hex
    if alpha_enabled then
      return hex .. alpha_hex
    else
      return hex
    end
  end
end

---Build a header/title string with color value and step label
---@param hex string The hex color
---@param mode string Color mode
---@param alpha number? Alpha value 0-100
---@param alpha_enabled boolean Whether alpha is enabled
---@param value_format "standard"|"decimal" Value display format
---@param step_label string Step size label (e.g., "1x", "2x")
---@return string title The formatted title string
function M.build_title(hex, mode, alpha, alpha_enabled, value_format, step_label)
  local color_str = M.format_color(hex, mode, alpha, alpha_enabled, value_format)
  return string.format(" %s | %s ", color_str, step_label)
end

---Get hex display with optional alpha byte appended
---@param hex string The hex color
---@param alpha number Alpha value 0-100
---@param alpha_enabled boolean Whether alpha is enabled
---@param mode string Current color mode (alpha hidden for cmyk)
---@return string hex_display
function M.get_hex_display(hex, alpha, alpha_enabled, mode)
  if alpha_enabled and mode ~= "cmyk" then
    local alpha_byte = math.floor((alpha / 100) * 255 + 0.5)
    return hex .. string.format("%02X", alpha_byte)
  end
  return hex
end

return M
