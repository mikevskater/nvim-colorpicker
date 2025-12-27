---@module 'nvim-colorpicker.color'
---@brief Color conversion and manipulation utilities
---
---This module re-exports all color functions from submodules,
---providing a unified API compatible with the original utils.lua

local hex = require('nvim-colorpicker.color.hex')
local hsl = require('nvim-colorpicker.color.hsl')
local hsv = require('nvim-colorpicker.color.hsv')
local cmyk = require('nvim-colorpicker.color.cmyk')
local manipulation = require('nvim-colorpicker.color.manipulation')
local validation = require('nvim-colorpicker.color.validation')
local format = require('nvim-colorpicker.color.format')
local grid = require('nvim-colorpicker.color.grid')

---@class NvimColorPickerColor
---Color conversion and manipulation utilities
local M = {}

-- ============================================================================
-- Hex <-> RGB Conversions (from hex.lua)
-- ============================================================================
M.hex_to_rgb = hex.hex_to_rgb
M.rgb_to_hex = hex.rgb_to_hex

-- ============================================================================
-- RGB <-> HSL Conversions (from hsl.lua)
-- ============================================================================
M.rgb_to_hsl = hsl.rgb_to_hsl
M.hsl_to_rgb = hsl.hsl_to_rgb
M.hex_to_hsl = hsl.hex_to_hsl
M.hsl_to_hex = hsl.hsl_to_hex

-- ============================================================================
-- RGB <-> HSV Conversions (from hsv.lua)
-- ============================================================================
M.rgb_to_hsv = hsv.rgb_to_hsv
M.hsv_to_rgb = hsv.hsv_to_rgb
M.hex_to_hsv = hsv.hex_to_hsv
M.hsv_to_hex = hsv.hsv_to_hex

-- ============================================================================
-- RGB <-> CMYK Conversions (from cmyk.lua)
-- ============================================================================
M.rgb_to_cmyk = cmyk.rgb_to_cmyk
M.cmyk_to_rgb = cmyk.cmyk_to_rgb
M.hex_to_cmyk = cmyk.hex_to_cmyk
M.cmyk_to_hex = cmyk.cmyk_to_hex

-- ============================================================================
-- Color Manipulation (from manipulation.lua)
-- ============================================================================
M.adjust_hue = manipulation.adjust_hue
M.adjust_saturation = manipulation.adjust_saturation
M.adjust_lightness = manipulation.adjust_lightness
M.get_offset_color = manipulation.get_offset_color
M.get_luminance = manipulation.get_luminance
M.get_contrast_color = manipulation.get_contrast_color
M.invert_color = manipulation.invert_color

-- ============================================================================
-- Validation (from validation.lua)
-- ============================================================================
M.is_valid_hex = validation.is_valid_hex
M.normalize_hex = validation.normalize_hex

-- ============================================================================
-- Formatting and Parsing (from format.lua)
-- ============================================================================
M.format_value = format.format_value
M.parse_value = format.parse_value
M.get_color_components = format.get_color_components
M.components_to_hex = format.components_to_hex
M.convert_format = format.convert_format
M.parse_color_string = format.parse_color_string

-- ============================================================================
-- Color Grid (from grid.lua)
-- ============================================================================
M.STEPS = grid.STEPS
M.generate_hue_row = grid.generate_hue_row
M.generate_color_grid = grid.generate_color_grid

return M
