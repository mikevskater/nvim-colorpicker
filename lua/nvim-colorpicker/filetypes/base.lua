---@module 'nvim-colorpicker.filetypes.base'
---@brief Base adapter class for filetype-specific color handling

local M = {}

---@class BaseAdapter : FiletypeAdapter
---@field filetypes string[]
---@field patterns PatternDef[]
---@field default_format string
---@field value_range "0-255"|"0-1"
local BaseAdapter = {}
BaseAdapter.__index = BaseAdapter

---Create a new adapter instance
---@param config table Configuration options
---@return BaseAdapter
function BaseAdapter.new(config)
  local self = setmetatable({}, BaseAdapter)
  self.filetypes = config.filetypes or {}
  self.patterns = config.patterns or {}
  self.default_format = config.default_format or "hex"
  self.value_range = config.value_range or "0-255"
  return self
end

---Format a hex color to target format
---Override in subclasses for custom formatting
---@param hex string The hex color
---@param format string Target format
---@param alpha number? Alpha value 0-100
---@return string formatted The formatted color string
function BaseAdapter:format_color(hex, format, alpha)
  local color_format = require('nvim-colorpicker.color.format')
  return color_format.convert_format(hex, format, alpha) or hex
end

---Parse a matched color string to hex
---Override in subclasses for custom parsing
---@param match string The matched string
---@param format string The format type
---@return string? hex Hex color
---@return number? alpha Alpha value 0-100
function BaseAdapter:parse_color(match, format)
  local color_format = require('nvim-colorpicker.color.format')
  return color_format.parse_color_string(match)
end

-- ============================================================================
-- Color Utility Methods (convenience wrappers)
-- ============================================================================

---Convert hex to RGB
---@param hex string Hex color
---@return number r Red (0-255)
---@return number g Green (0-255)
---@return number b Blue (0-255)
function BaseAdapter:hex_to_rgb(hex)
  local hex_module = require('nvim-colorpicker.color.hex')
  return hex_module.hex_to_rgb(hex)
end

---Convert RGB to hex
---@param r number Red (0-255)
---@param g number Green (0-255)
---@param b number Blue (0-255)
---@return string hex
function BaseAdapter:rgb_to_hex(r, g, b)
  local hex_module = require('nvim-colorpicker.color.hex')
  return hex_module.rgb_to_hex(r, g, b)
end

---Convert hex to HSL
---@param hex string Hex color
---@return number h Hue (0-360)
---@return number s Saturation (0-100)
---@return number l Lightness (0-100)
function BaseAdapter:hex_to_hsl(hex)
  local hsl_module = require('nvim-colorpicker.color.hsl')
  return hsl_module.hex_to_hsl(hex)
end

---Convert HSL to hex
---@param h number Hue (0-360)
---@param s number Saturation (0-100)
---@param l number Lightness (0-100)
---@return string hex
function BaseAdapter:hsl_to_hex(h, s, l)
  local hsl_module = require('nvim-colorpicker.color.hsl')
  return hsl_module.hsl_to_hex(h, s, l)
end

---Convert hex to HSV
---@param hex string Hex color
---@return number h Hue (0-360)
---@return number s Saturation (0-100)
---@return number v Value (0-100)
function BaseAdapter:hex_to_hsv(hex)
  local hsv_module = require('nvim-colorpicker.color.hsv')
  return hsv_module.hex_to_hsv(hex)
end

---Convert HSV to hex
---@param h number Hue (0-360)
---@param s number Saturation (0-100)
---@param v number Value (0-100)
---@return string hex
function BaseAdapter:hsv_to_hex(h, s, v)
  local hsv_module = require('nvim-colorpicker.color.hsv')
  return hsv_module.hsv_to_hex(h, s, v)
end

---Normalize hex color format
---@param hex string Hex color (with or without #)
---@return string normalized Normalized #RRGGBB format
function BaseAdapter:normalize_hex(hex)
  local color_utils = require('nvim-colorpicker.color')
  return color_utils.normalize_hex(hex)
end

-- ============================================================================
-- Alpha Helpers
-- ============================================================================

---Convert alpha percentage to byte (0-255)
---@param alpha number Alpha percentage (0-100)
---@return number byte Alpha byte (0-255)
function BaseAdapter:alpha_to_byte(alpha)
  return math.floor((alpha / 100) * 255 + 0.5)
end

---Convert alpha byte to percentage
---@param byte number Alpha byte (0-255)
---@return number alpha Alpha percentage (0-100)
function BaseAdapter:byte_to_alpha(byte)
  return math.floor((byte / 255) * 100 + 0.5)
end

---Convert alpha percentage to decimal (0-1)
---@param alpha number Alpha percentage (0-100)
---@return number decimal Alpha decimal (0.0-1.0)
function BaseAdapter:alpha_to_decimal(alpha)
  return alpha / 100
end

---Convert alpha decimal to percentage
---@param decimal number Alpha decimal (0.0-1.0)
---@return number alpha Alpha percentage (0-100)
function BaseAdapter:decimal_to_alpha(decimal)
  return math.floor(decimal * 100 + 0.5)
end

-- ============================================================================
-- Float Value Helpers (for shader adapters)
-- ============================================================================

---Convert 0-255 RGB to 0.0-1.0 floats
---@param r number Red (0-255)
---@param g number Green (0-255)
---@param b number Blue (0-255)
---@return number rf, number gf, number bf Float values (0.0-1.0)
function BaseAdapter:rgb_to_float(r, g, b)
  return r / 255, g / 255, b / 255
end

---Convert 0.0-1.0 floats to 0-255 RGB
---@param rf number Red float (0.0-1.0)
---@param gf number Green float (0.0-1.0)
---@param bf number Blue float (0.0-1.0)
---@return number r, number g, number b Integer values (0-255)
function BaseAdapter:float_to_rgb(rf, gf, bf)
  return math.floor(rf * 255 + 0.5), math.floor(gf * 255 + 0.5), math.floor(bf * 255 + 0.5)
end

M.BaseAdapter = BaseAdapter

return M
