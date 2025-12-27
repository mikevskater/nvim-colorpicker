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
M.version = '1.9.1'

-- Lazy-load modules
local function get_config()
  return require('nvim-colorpicker.config')
end

local function get_picker()
  return require('nvim-colorpicker.picker')
end

local function get_utils()
  return require('nvim-colorpicker.color')
end

local function get_detect()
  return require('nvim-colorpicker.detect')
end

local function get_presets()
  return require('nvim-colorpicker.presets')
end

local function get_history()
  return require('nvim-colorpicker.history')
end

local function get_highlight()
  return require('nvim-colorpicker.highlight')
end

---Setup nvim-colorpicker with options
---@param opts NvimColorPickerConfig? Configuration options
function M.setup(opts)
  get_config().setup(opts)
  -- Setup highlight module (will enable auto-highlight if configured)
  get_highlight().setup()
end

---@class NvimColorPickerPickOptions
---@field color string? Initial color (hex, rgb, or hsl string)
---@field title string? Title for the picker window
---@field on_select fun(result: table)? Called when user confirms (result: {color, alpha?, custom?})
---@field on_cancel fun()? Called when user cancels
---@field on_change fun(result: table)? Called on every color change (result: {color, alpha?, custom?})
---@field keymaps table? Override keymaps for this picker instance
---@field alpha_enabled boolean? Enable alpha editing
---@field initial_alpha number? Initial alpha value (0-100)
---@field forced_mode "hsl"|"rgb"|"cmyk"|"hsv"? Force specific color mode
---@field custom_controls NvimColorPickerCustomControl[]? Injectable custom controls (toggle/select/number/text)

---Custom control definition for injectable UI elements
---@class NvimColorPickerCustomControl
---@field id string Unique identifier for this control
---@field type "toggle"|"select"|"number"|"text" Control type
---@field label string Display label
---@field default any Default value
---@field key string? Optional keymap to toggle/cycle this control
---@field options string[]? Options for select type
---@field min number? Minimum for number type
---@field max number? Maximum for number type
---@field step number? Step for number type
---@field on_change fun(new_value: any, old_value: any, control_id: string)? Callback when value changes

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
    alpha_enabled = true,  -- Always allow alpha editing
    initial_alpha = color_info.alpha or 100,  -- Use detected alpha or default to 100
    on_select = function(result)
      -- result is {color, alpha} - extract the color
      local new_color = result.color or color_info.color
      detect.replace_color_at_cursor(new_color, color_info, result.alpha)
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

-- ============================================================================
-- Picker Manipulation
-- ============================================================================

---Set the current color in an open picker (for external updates like fg/bg switching)
---@param hex string The new hex color
---@param original_hex string? Optional original color for reset/comparison
function M.set_color(hex, original_hex)
  get_picker().set_color(hex, original_hex)
end

---Get the current color from an open picker
---@return string? hex The current hex color, or nil if picker not open
function M.get_color()
  return get_picker().get_color()
end

---Check if picker is currently open
---@return boolean
function M.is_open()
  return get_picker().is_open()
end

-- ============================================================================
-- Presets
-- ============================================================================

---Get color presets module
---@return table Presets module
function M.presets()
  return get_presets()
end

---Get available preset names
---@return string[] names
function M.get_preset_names()
  return get_presets().get_preset_names()
end

---Search presets for a color by name
---@param query string Search query
---@return table[] matches
function M.search_presets(query)
  return get_presets().search(query)
end

-- ============================================================================
-- Clipboard & History
-- ============================================================================

---Get history module
---@return table History module
function M.history()
  return get_history()
end

---Copy color to clipboard
---@param hex string? Hex color (default: color at cursor)
---@param format "hex"|"rgb"|"hsl"|"hsv"? Format
function M.yank(hex, format)
  if not hex then
    get_history().yank_at_cursor(format)
  else
    get_history().yank(hex, format)
  end
end

---Paste color from clipboard
---@return string? hex Parsed hex color
function M.paste()
  return get_history().paste()
end

---Get recent colors
---@param count number? Max colors
---@return string[] colors
function M.get_recent_colors(count)
  return get_history().get_recent(count)
end

---Add color to recent history
---@param hex string Hex color
function M.add_recent_color(hex)
  get_history().add_recent(hex)
end

-- ============================================================================
-- Buffer Highlighting
-- ============================================================================

---Get highlight module
---@return table Highlight module
function M.highlight()
  return get_highlight()
end

---Toggle color highlighting in current buffer
function M.toggle_highlight()
  get_highlight().toggle()
end

---Enable color highlighting in current buffer
function M.enable_highlight()
  get_highlight().highlight_buffer()
end

---Disable color highlighting in current buffer
function M.disable_highlight()
  get_highlight().clear_buffer()
end

---Enable auto-highlighting for file patterns
---@param patterns string[]? File patterns
function M.enable_auto_highlight(patterns)
  get_highlight().enable_auto(patterns)
end

---Disable auto-highlighting
function M.disable_auto_highlight()
  get_highlight().disable_auto()
end

---Set highlight mode
---@param mode "background"|"foreground"|"virtualtext"
function M.set_highlight_mode(mode)
  get_highlight().set_mode(mode)
end

return M
