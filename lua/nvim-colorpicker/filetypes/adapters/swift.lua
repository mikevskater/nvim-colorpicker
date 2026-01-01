---@module 'nvim-colorpicker.filetypes.adapters.swift'
---@brief Swift adapter for iOS/macOS (UIKit and SwiftUI)

local base = require('nvim-colorpicker.filetypes.base')
local patterns = require('nvim-colorpicker.filetypes.patterns')

---@class SwiftAdapter : BaseAdapter
local SwiftAdapter = base.BaseAdapter.new({
  filetypes = { "swift" },
  default_format = "color_swiftui",
  value_range = "0-1",
  patterns = patterns.combine(
    -- Swift/SwiftUI Color patterns
    {
      -- UIColor(red: r, green: g, blue: b, alpha: a)
      { pattern = "UIColor%s*%(%s*red%s*:%s*[%d%.]+%s*,%s*green%s*:%s*[%d%.]+%s*,%s*blue%s*:%s*[%d%.]+%s*,%s*alpha%s*:%s*[%d%.]+%s*%)", format = "uicolor", priority = 100 },
      -- Color(red: r, green: g, blue: b) - SwiftUI
      { pattern = "Color%s*%(%s*red%s*:%s*[%d%.]+%s*,%s*green%s*:%s*[%d%.]+%s*,%s*blue%s*:%s*[%d%.]+%s*%)", format = "color_swiftui", priority = 95 },
      -- Color(hex: 0xRRGGBB) - common extension
      { pattern = "Color%s*%(%s*hex%s*:%s*0x%x%x%x%x%x%x%s*%)", format = "color_hex_ext", priority = 90 },
      -- UIColor(hex: 0xRRGGBB)
      { pattern = "UIColor%s*%(%s*hex%s*:%s*0x%x%x%x%x%x%x%s*%)", format = "uicolor_hex_ext", priority = 90 },
    },
    -- Standard hex patterns (in string literals)
    patterns.universal
  ),
})

---Format a hex color to Swift format
---@param hex string The hex color
---@param format string Target format
---@param alpha number? Alpha value 0-100
---@return string formatted The formatted color string
function SwiftAdapter:format_color(hex, format, alpha)
  local r, g, b = self:hex_to_rgb(hex)
  local rf, gf, bf = self:rgb_to_float(r, g, b)
  local af = alpha and self:alpha_to_decimal(alpha) or 1.0

  if format == "uicolor" then
    -- UIColor(red: r, green: g, blue: b, alpha: a)
    return string.format("UIColor(red: %.3f, green: %.3f, blue: %.3f, alpha: %.2f)", rf, gf, bf, af)
  elseif format == "color_swiftui" then
    -- Color(red: r, green: g, blue: b) - SwiftUI (no alpha param in basic init)
    if alpha and alpha < 100 then
      -- Use opacity modifier for alpha
      return string.format("Color(red: %.3f, green: %.3f, blue: %.3f).opacity(%.2f)", rf, gf, bf, af)
    end
    return string.format("Color(red: %.3f, green: %.3f, blue: %.3f)", rf, gf, bf)
  elseif format == "color_hex_ext" then
    -- Color(hex: 0xRRGGBB)
    return string.format("Color(hex: 0x%s)", hex:sub(2):upper())
  elseif format == "uicolor_hex_ext" then
    -- UIColor(hex: 0xRRGGBB)
    return string.format("UIColor(hex: 0x%s)", hex:sub(2):upper())
  elseif format == "hex" or format == "hex8" then
    if alpha and alpha < 100 then
      return hex .. string.format("%02X", self:alpha_to_byte(alpha))
    end
    return hex
  end

  return hex
end

---Parse a Swift color string to hex
---@param match string The matched string
---@param format string The format type
---@return string? hex Hex color
---@return number? alpha Alpha value 0-100
function SwiftAdapter:parse_color(match, format)
  if format == "uicolor" then
    -- UIColor(red: r, green: g, blue: b, alpha: a)
    local rf, gf, bf, af = match:match("UIColor%s*%(%s*red%s*:%s*([%d%.]+)%s*,%s*green%s*:%s*([%d%.]+)%s*,%s*blue%s*:%s*([%d%.]+)%s*,%s*alpha%s*:%s*([%d%.]+)%s*%)")
    if rf and gf and bf and af then
      local r, g, b = self:float_to_rgb(tonumber(rf), tonumber(gf), tonumber(bf))
      local alpha = self:decimal_to_alpha(tonumber(af))
      return self:rgb_to_hex(r, g, b), alpha
    end
  elseif format == "color_swiftui" then
    -- Color(red: r, green: g, blue: b)
    local rf, gf, bf = match:match("Color%s*%(%s*red%s*:%s*([%d%.]+)%s*,%s*green%s*:%s*([%d%.]+)%s*,%s*blue%s*:%s*([%d%.]+)%s*%)")
    if rf and gf and bf then
      local r, g, b = self:float_to_rgb(tonumber(rf), tonumber(gf), tonumber(bf))
      return self:rgb_to_hex(r, g, b), nil
    end
  elseif format == "color_hex_ext" then
    -- Color(hex: 0xRRGGBB)
    local hex_str = match:match("Color%s*%(%s*hex%s*:%s*0x(%x%x%x%x%x%x)%s*%)")
    if hex_str then
      return "#" .. hex_str:upper(), nil
    end
  elseif format == "uicolor_hex_ext" then
    -- UIColor(hex: 0xRRGGBB)
    local hex_str = match:match("UIColor%s*%(%s*hex%s*:%s*0x(%x%x%x%x%x%x)%s*%)")
    if hex_str then
      return "#" .. hex_str:upper(), nil
    end
  elseif format == "hex" then
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
  end

  -- Fallback
  local color_format = require('nvim-colorpicker.color.format')
  return color_format.parse_color_string(match)
end

return SwiftAdapter
