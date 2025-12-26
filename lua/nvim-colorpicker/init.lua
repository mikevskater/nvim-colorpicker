---@module 'nvim-colorpicker'
---@brief Interactive color picker for Neovim
---
---nvim-colorpicker provides an interactive HSL-based color picker with:
--- - Visual grid navigation for hue and lightness
--- - Saturation adjustment with keyboard shortcuts
--- - Multiple color modes (HSL, RGB, HSV, CMYK)
--- - Direct hex input
--- - Cursor color detection and in-place replacement
---
---@usage
---```lua
---local colorpicker = require('nvim-colorpicker')
---
----- Setup with options
---colorpicker.setup({
---  keymaps = { nav_left = 'h', ... },
---  default_format = 'hex',
---})
---
----- Open picker
---colorpicker.pick({ color = '#ff5500' })
---
----- Pick and replace at cursor
---colorpicker.pick_at_cursor()
---```

local M = {}

---Plugin version
M.version = '0.4.0'

-- Lazy-load modules
local function get_config()
  return require('nvim-colorpicker.config')
end

local function get_picker()
  return require('nvim-colorpicker.picker')
end

local function get_utils()
  return require('nvim-colorpicker.utils')
end

local function get_detect()
  return require('nvim-colorpicker.detect')
end

---Setup nvim-colorpicker with options
---@param opts NvimColorPickerConfig? Configuration options
function M.setup(opts)
  get_config().setup(opts)
end

---@class NvimColorPickerPickOptions
---@field color string? Initial color (hex, rgb, or hsl string)
---@field on_select fun(color: string)? Called when user confirms selection
---@field on_cancel fun()? Called when user cancels
---@field on_change fun(color: string)? Called on every color change
---@field keymaps table? Override keymaps for this picker instance
---@field alpha_enabled boolean? Enable alpha editing

---Open color picker
---@param opts NvimColorPickerPickOptions? Options for the picker
function M.pick(opts)
  opts = opts or {}
  local config = get_config().get()

  -- Merge keymaps if provided
  if opts.keymaps then
    opts.keymaps = vim.tbl_deep_extend('force', config.keymaps, opts.keymaps)
  else
    opts.keymaps = config.keymaps
  end

  -- Use config defaults
  if opts.alpha_enabled == nil then
    opts.alpha_enabled = config.alpha_enabled
  end

  get_picker().pick(opts)
end

---Detect color at cursor and open picker for replacement
function M.pick_at_cursor()
  local detect = get_detect()
  local color_info = detect.get_color_at_cursor()

  if not color_info then
    vim.notify('No color found at cursor', vim.log.levels.WARN)
    return
  end

  M.pick({
    color = color_info.color,
    on_select = function(new_color)
      detect.replace_color_at_cursor(new_color, color_info)
    end,
  })
end

---Detect color under cursor without opening picker
---@return table? Color info with: color, start_col, end_col, format
function M.detect_at_cursor()
  return get_detect().get_color_at_cursor()
end

---Convert color at cursor to different format
---@param format "hex"|"rgb"|"hsl"|"hsv" Target format
function M.convert_at_cursor(format)
  local detect = get_detect()
  local utils = get_utils()

  local color_info = detect.get_color_at_cursor()
  if not color_info then
    vim.notify('No color found at cursor', vim.log.levels.WARN)
    return
  end

  local converted = utils.convert_format(color_info.color, format)
  if converted then
    detect.replace_color_at_cursor(converted, color_info)
  end
end

---Get color utilities module
---@return table Color utilities (hex_to_rgb, rgb_to_hex, etc.)
function M.utils()
  return get_utils()
end

return M
