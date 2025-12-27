---@module 'nvim-colorpicker.picker.types'
---@brief Type definitions and constants for the color picker

local M = {}

-- ============================================================================
-- Types
-- ============================================================================

---@class NvimColorPickerColor
---@field color string The hex color

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

---@class NvimColorPickerOptions
---@field initial NvimColorPickerColor Initial color value
---@field title string? Title for the picker (e.g., color key name)
---@field on_change fun(color: NvimColorPickerColor)? Called on every navigation
---@field on_select fun(color: NvimColorPickerColor)? Called when user confirms
---@field on_cancel fun()? Called when user cancels
---@field forced_mode "hsl"|"rgb"|"cmyk"|"hsv"? Force specific color mode (locks mode switching)
---@field alpha_enabled boolean? Allow alpha editing (default: false)
---@field initial_alpha number? Initial alpha value 0-100 (default: 100)
---@field keymaps table? Custom keymaps (merged with defaults)
---@field custom_controls NvimColorPickerCustomControl[]? Injectable custom controls

---@class NvimColorPickerState
---@field current NvimColorPickerColor Current working color
---@field original NvimColorPickerColor Original color for reset
---@field grid_width number Current grid width
---@field grid_height number Current grid height
---@field preview_rows number Number of rows for footer preview blocks
---@field win number? Window handle
---@field buf number? Buffer handle
---@field ns number Namespace for highlights
---@field options NvimColorPickerOptions
---@field saved_hsl table? Saved HSL for when at white/black extremes
---@field step_index number Index into STEP_SIZES array
---@field lightness_virtual number? Virtual lightness position (can exceed 0-100 for bounce)
---@field saturation_virtual number? Virtual saturation position (can exceed 0-100 for bounce)
---@field _float FloatWindow? Reference to UiFloat window instance
---@field _render_pending boolean? Whether a render is scheduled
---@field _render_timer number? Timer handle for debounced render
---@field color_mode "hsl"|"rgb"|"cmyk"|"hsv" Current color mode for info panel
---@field value_format "standard"|"decimal" Value display format
---@field alpha number Current alpha value 0-100
---@field original_alpha number Original alpha value 0-100 (for preview comparison)
---@field alpha_enabled boolean Whether alpha editing is available
---@field focused_panel "grid"|"info" Currently focused panel
---@field _multipanel table? MultiPanelWindow instance (for multipanel mode)
---@field _info_panel_cb table? ContentBuilder for info panel (stores inputs)
---@field _info_input_manager table? InputManager for info panel
---@field _keymaps table? Resolved keymaps
---@field custom_values table<string, any> Current values for custom controls
---@field active_tab "info"|"history"|"presets" Currently active tab in right panel
---@field history_cursor number Selected item index in history tab
---@field presets_cursor number Selected item index in presets tab
---@field presets_expanded table<string, boolean> Expanded state of preset categories
---@field presets_search string Current search query in presets tab

-- ============================================================================
-- Layout Constants
-- ============================================================================

M.PREVIEW_BORDERS = 2   -- Top and bottom border lines around preview
M.PREVIEW_RATIO = 0.10  -- Preview section = 10% of available height
M.HEADER_HEIGHT = 3     -- Blank + title + blank
M.PADDING = 2           -- Left/right padding

-- ============================================================================
-- Navigation Constants
-- ============================================================================

M.BASE_STEP_HUE = 3          -- Base hue degrees per grid cell
M.BASE_STEP_LIGHTNESS = 2    -- Base lightness percent per grid row
M.BASE_STEP_SATURATION = 2   -- Base saturation percent per J/K press

-- ============================================================================
-- Step Size Configuration
-- ============================================================================

-- Step size multipliers (index 3 is default 1x)
M.STEP_SIZES = { 0.25, 0.5, 1, 2, 4, 8 }
M.STEP_LABELS = { "1/4x", "1/2x", "1x", "2x", "4x", "8x" }
M.DEFAULT_STEP_INDEX = 3  -- 1x multiplier

-- ============================================================================
-- Alpha Visualization
-- ============================================================================

-- Alpha visualization characters (for preview section)
M.ALPHA_CHARS = {
  { min = 100, max = 100, char = "█" },
  { min = 85,  max = 99,  char = "▓" },
  { min = 70,  max = 84,  char = "▒" },
  { min = 55,  max = 69,  char = "░" },
  { min = 42,  max = 54,  char = "⣿" },
  { min = 30,  max = 41,  char = "⢯" },
  { min = 20,  max = 29,  char = "⡪" },
  { min = 12,  max = 19,  char = "⠪" },
  { min = 6,   max = 11,  char = "⠊" },
  { min = 2,   max = 5,   char = "·" },
  { min = 0,   max = 1,   char = "⠀" },
}

-- ============================================================================
-- Color Modes
-- ============================================================================

-- Color modes available
M.COLOR_MODES = { "hsl", "rgb", "cmyk", "hsv" }

-- ============================================================================
-- Panel Layout Constants
-- ============================================================================

-- Minimum width for side-by-side layout (below this, use stacked)
M.MIN_SIDE_BY_SIDE_WIDTH = 80

-- Info panel minimum dimensions
M.INFO_PANEL_MIN_WIDTH = 22
M.INFO_PANEL_MIN_HEIGHT = 12

return M
