---@module 'nvim-colorpicker.picker.navigation'
---@brief HSL navigation functions for the color picker

local Types = require('nvim-colorpicker.picker.types')
local State = require('nvim-colorpicker.picker.state')
local Grid = require('nvim-colorpicker.picker.grid')
local ColorUtils = require('nvim-colorpicker.color')

local M = {}

-- ============================================================================
-- Local References
-- ============================================================================

local BASE_STEP_HUE = Types.BASE_STEP_HUE
local BASE_STEP_LIGHTNESS = Types.BASE_STEP_LIGHTNESS
local BASE_STEP_SATURATION = Types.BASE_STEP_SATURATION
local COLOR_MODES = Types.COLOR_MODES

-- ============================================================================
-- Navigation Functions
-- ============================================================================

---Shift hue
---@param delta number Positive = right (increase hue), negative = left
---@param schedule_render fun() Function to schedule a render
function M.shift_hue(delta, schedule_render)
  local state = State.state
  if not state then return end
  local current = State.get_active_color()
  local step = delta * BASE_STEP_HUE * State.get_step_multiplier()
  local new_color = ColorUtils.adjust_hue(current, step)

  if state.saved_hsl then
    local h, _, _ = ColorUtils.hex_to_hsl(new_color)
    state.saved_hsl.h = h
  end

  State.set_active_color(new_color)
  schedule_render()
end

---Shift lightness with bounce and color band memory
---@param delta number Positive = up (increase lightness), negative = down
---@param schedule_render fun() Function to schedule a render
function M.shift_lightness(delta, schedule_render)
  local state = State.state
  if not state then return end
  local current = State.get_active_color()
  local h, s, l = ColorUtils.hex_to_hsl(current)

  if not state.lightness_virtual then
    state.lightness_virtual = l
  end

  if l > 2 and l < 98 and s > 5 then
    state.saved_hsl = { h = h, s = s }
  end

  local step = delta * BASE_STEP_LIGHTNESS * State.get_step_multiplier()
  state.lightness_virtual = state.lightness_virtual + step

  local new_l = Grid.virtual_to_actual(state.lightness_virtual)

  local new_h, new_s = h, s
  if state.saved_hsl and new_l > 2 and new_l < 98 then
    new_h = state.saved_hsl.h
    new_s = state.saved_hsl.s
  end

  local new_color = ColorUtils.hsl_to_hex(new_h, new_s, new_l)
  State.set_active_color(new_color)
  schedule_render()
end

---Shift saturation with bounce
---@param delta number Positive = increase, negative = decrease
---@param schedule_render fun() Function to schedule a render
function M.shift_saturation(delta, schedule_render)
  local state = State.state
  if not state then return end
  local current = State.get_active_color()
  local h, s, l = ColorUtils.hex_to_hsl(current)

  if not state.saturation_virtual then
    state.saturation_virtual = s
  end

  local step = delta * BASE_STEP_SATURATION * State.get_step_multiplier()
  state.saturation_virtual = state.saturation_virtual + step

  local new_s = Grid.virtual_to_actual(state.saturation_virtual)

  if state.saved_hsl then
    state.saved_hsl.s = new_s
  end

  local new_color = ColorUtils.hsl_to_hex(h, new_s, l)
  State.set_active_color(new_color)
  schedule_render()
end

---Reset to original color
---@param schedule_render fun() Function to schedule a render
function M.reset_color(schedule_render)
  local state = State.state
  if not state then return end

  -- Reset color
  state.current = vim.deepcopy(state.original)

  -- Reset virtual positions (clears bounce state)
  state.lightness_virtual = nil
  state.saturation_virtual = nil

  -- Update saved HSL from original color
  local h, s, _ = ColorUtils.hex_to_hsl(state.original.color)
  state.saved_hsl = { h = h, s = s }

  -- Reset alpha if enabled
  if state.alpha_enabled and state.original_alpha then
    state.alpha = state.original_alpha
  end

  schedule_render()
end

---Adjust alpha value
---@param delta number Amount to change alpha
---@param schedule_render fun() Function to schedule a render
function M.adjust_alpha(delta, schedule_render)
  local state = State.state
  if not state then return end

  if not state.alpha_enabled then
    vim.notify("Alpha editing is not enabled", vim.log.levels.INFO)
    return
  end

  if state.color_mode == "cmyk" then
    vim.notify("CMYK mode does not support alpha", vim.log.levels.INFO)
    return
  end

  local step = delta * BASE_STEP_SATURATION * State.get_step_multiplier()
  state.alpha = math.max(0, math.min(100, state.alpha + step))
  schedule_render()
end

---Cycle through color modes
---@param schedule_render fun() Function to schedule a render
function M.cycle_mode(schedule_render)
  local state = State.state
  if not state then return end

  if state.options.forced_mode then
    vim.notify("Color mode is locked to " .. state.options.forced_mode:upper(), vim.log.levels.INFO)
    return
  end

  local current_idx = 1
  for i, mode in ipairs(COLOR_MODES) do
    if mode == state.color_mode then
      current_idx = i
      break
    end
  end

  local next_idx = (current_idx % #COLOR_MODES) + 1
  state.color_mode = COLOR_MODES[next_idx]
  schedule_render()
end

---Cycle value display format
---@param schedule_render fun() Function to schedule a render
function M.cycle_format(schedule_render)
  local state = State.state
  if not state then return end
  state.value_format = state.value_format == "standard" and "decimal" or "standard"
  schedule_render()
end

---Toggle or cycle a custom control value
---@param control_id string The control ID
---@param schedule_render fun() Function to schedule a render
function M.toggle_custom_control(control_id, schedule_render)
  local state = State.state
  if not state or not state.options.custom_controls then return end

  local control = nil
  for _, ctrl in ipairs(state.options.custom_controls) do
    if ctrl.id == control_id then
      control = ctrl
      break
    end
  end

  if not control then return end

  local old_value = state.custom_values[control_id]
  local new_value = old_value

  if control.type == "toggle" then
    new_value = not old_value
  elseif control.type == "select" then
    local current_idx = 1
    for i, opt in ipairs(control.options) do
      if opt == old_value then
        current_idx = i
        break
      end
    end
    local next_idx = (current_idx % #control.options) + 1
    new_value = control.options[next_idx]
  elseif control.type == "number" then
    local step = control.step or 1
    local min_val = control.min or 0
    local max_val = control.max or 100
    new_value = old_value + step
    if new_value > max_val then new_value = min_val end
  end

  state.custom_values[control_id] = new_value

  if control.on_change and old_value ~= new_value then
    control.on_change(new_value, old_value, control_id)
  end

  schedule_render()
end

---Enter hex input mode
---@param schedule_render fun() Function to schedule a render
function M.enter_hex_input(schedule_render)
  local state = State.state
  if not state then return end

  local current = State.get_active_color()

  vim.ui.input({
    prompt = "Enter hex color: ",
    default = current,
  }, function(input)
    if input and ColorUtils.is_valid_hex(input) then
      State.set_active_color(input)
      schedule_render()
    elseif input then
      vim.notify("Invalid hex color: " .. input, vim.log.levels.WARN)
    end
  end)
end

return M
