---@module 'nvim-colorpicker.picker.state'
---@brief State management for the color picker

local Types = require('nvim-colorpicker.picker.types')
local ColorUtils = require('nvim-colorpicker.color')

local M = {}

-- ============================================================================
-- State
-- ============================================================================

---@type NvimColorPickerState?
M.state = nil

-- ============================================================================
-- State Accessors
-- ============================================================================

---Get the current color
---@return string hex
function M.get_active_color()
  if not M.state then return "#808080" end
  return M.state.current.color or "#808080"
end

---Set the current color
---@param hex string
function M.set_active_color(hex)
  if not M.state then return end
  hex = ColorUtils.normalize_hex(hex)
  M.state.current.color = hex
end

---Get current step multiplier
---@return number
function M.get_step_multiplier()
  if not M.state then return 1 end
  return Types.STEP_SIZES[M.state.step_index] or 1
end

---Get current step label
---@return string
function M.get_step_label()
  if not M.state then return "1x" end
  return Types.STEP_LABELS[M.state.step_index] or "1x"
end

-- ============================================================================
-- State Initialization
-- ============================================================================

---Initialize state with options
---@param initial NvimColorPickerColor The initial color
---@param options NvimColorPickerOptions The picker options
---@param grid_width number Grid width
---@param grid_height number Grid height
---@param preview_rows number Preview rows
---@param namespace number Vim namespace for highlights
---@param resolved_keymaps table Resolved keymap configuration
---@param multipanel table? MultiPanel instance
---@param grid_buf number? Grid buffer handle
---@param grid_win number? Grid window handle
function M.init_state(initial, options, grid_width, grid_height, preview_rows, namespace, resolved_keymaps, multipanel, grid_buf, grid_win)
  local initial_hsl = nil
  if initial.color then
    local h, s, _ = ColorUtils.hex_to_hsl(initial.color)
    initial_hsl = { h = h, s = s }
  end

  M.state = {
    current = vim.deepcopy(initial),
    original = vim.deepcopy(initial),
    grid_width = grid_width,
    grid_height = grid_height,
    preview_rows = preview_rows,
    win = grid_win,
    buf = grid_buf,
    ns = namespace,
    options = options,
    saved_hsl = initial_hsl,
    step_index = Types.DEFAULT_STEP_INDEX,
    lightness_virtual = nil,
    saturation_virtual = nil,
    _float = nil,
    _multipanel = multipanel,
    color_mode = options.forced_mode or "hsl",
    value_format = "standard",
    alpha = options.initial_alpha or 100,
    original_alpha = options.initial_alpha or 100,
    alpha_enabled = options.alpha_enabled or false,
    focused_panel = "grid",
    _render_pending = false,
    _keymaps = resolved_keymaps,
    custom_values = {},
    -- Tab system state
    active_tab = "info",
    history_cursor = 1,
    presets_cursor = 1,
    presets_expanded = {},
    presets_search = "",
    -- Slider state
    slider_focus = 1,  -- Which slider is focused (1-indexed)
  }

  -- Initialize custom control values from defaults
  if options.custom_controls then
    for _, control in ipairs(options.custom_controls) do
      M.state.custom_values[control.id] = control.default
    end
  end
end

---Clear state
function M.clear_state()
  M.state = nil
end

---Check if state exists
---@return boolean
function M.has_state()
  return M.state ~= nil
end

---Get state (for external access)
---@return NvimColorPickerState?
function M.get_state()
  return M.state
end

-- ============================================================================
-- Step Size Management
-- ============================================================================

---Increase step size
---@param schedule_render fun() Function to schedule a render
function M.increase_step_size(schedule_render)
  if not M.state then return end
  if M.state.step_index < #Types.STEP_SIZES then
    M.state.step_index = M.state.step_index + 1
    schedule_render()
  end
end

---Decrease step size
---@param schedule_render fun() Function to schedule a render
function M.decrease_step_size(schedule_render)
  if not M.state then return end
  if M.state.step_index > 1 then
    M.state.step_index = M.state.step_index - 1
    schedule_render()
  end
end

return M
