---@module 'nvim-colorpicker.picker.slider'
---@brief Slider rendering and component adjustment for the color picker

local ColorUtils = require('nvim-colorpicker.color')
local State = require('nvim-colorpicker.picker.state')
local Types = require('nvim-colorpicker.picker.types')

local M = {}

-- ============================================================================
-- Constants
-- ============================================================================

-- Slider characters
M.FILLED_CHAR = "█"   -- U+2588 Full block
M.EMPTY_CHAR = "░"    -- U+2591 Light shade

-- Default slider width
M.DEFAULT_WIDTH = 16

-- ============================================================================
-- Component Definitions
-- ============================================================================

---@class SliderComponent
---@field key string Component key (h, s, l, r, g, b, v, c, m, y, k, a)
---@field label string Display label
---@field min number Minimum value
---@field max number Maximum value
---@field unit string Unit type for formatting ("deg", "pct", "int")
---@field wrap boolean Whether value wraps (hue) or clamps

---Get component definitions for a given mode
---@param mode string The color mode (hsl, rgb, hsv, cmyk, hex)
---@param alpha_enabled boolean Whether alpha is enabled
---@return SliderComponent[] components
function M.get_components(mode, alpha_enabled)
  local components = {}

  -- For "hex" mode, treat it as "hsl" internally for sliders
  local effective_mode = mode == "hex" and "hsl" or mode

  if effective_mode == "hsl" then
    components = {
      { key = "h", label = "H", min = 0, max = 360, unit = "deg", wrap = true },
      { key = "s", label = "S", min = 0, max = 100, unit = "pct", wrap = false },
      { key = "l", label = "L", min = 0, max = 100, unit = "pct", wrap = false },
    }
  elseif effective_mode == "rgb" then
    components = {
      { key = "r", label = "R", min = 0, max = 255, unit = "int", wrap = false },
      { key = "g", label = "G", min = 0, max = 255, unit = "int", wrap = false },
      { key = "b", label = "B", min = 0, max = 255, unit = "int", wrap = false },
    }
  elseif effective_mode == "hsv" then
    components = {
      { key = "h", label = "H", min = 0, max = 360, unit = "deg", wrap = true },
      { key = "s", label = "S", min = 0, max = 100, unit = "pct", wrap = false },
      { key = "v", label = "V", min = 0, max = 100, unit = "pct", wrap = false },
    }
  elseif effective_mode == "cmyk" then
    components = {
      { key = "c", label = "C", min = 0, max = 100, unit = "pct", wrap = false },
      { key = "m", label = "M", min = 0, max = 100, unit = "pct", wrap = false },
      { key = "y", label = "Y", min = 0, max = 100, unit = "pct", wrap = false },
      { key = "k", label = "K", min = 0, max = 100, unit = "pct", wrap = false },
    }
  end

  -- Add alpha slider if enabled (except for CMYK which doesn't support alpha)
  if alpha_enabled and effective_mode ~= "cmyk" then
    table.insert(components, {
      key = "a",
      label = "A",
      min = 0,
      max = 100,
      unit = "pct",
      wrap = false,
    })
  end

  return components
end

-- ============================================================================
-- Slider Rendering
-- ============================================================================

---Render a slider bar
---@param value number Current value
---@param min number Minimum value
---@param max number Maximum value
---@param width number Slider width in characters
---@return string slider The slider string
---@return number filled Number of filled characters
function M.render_slider(value, min, max, width)
  width = width or M.DEFAULT_WIDTH
  local range = max - min
  local normalized = (value - min) / range
  local filled = math.floor(normalized * width + 0.5)
  local empty = width - filled

  -- Clamp values
  filled = math.max(0, math.min(width, filled))
  empty = math.max(0, width - filled)

  local slider = string.rep(M.FILLED_CHAR, filled) .. string.rep(M.EMPTY_CHAR, empty)
  return slider, filled
end

---Render a complete slider row with label and value
---@param component SliderComponent Component definition
---@param value number Current value
---@param width number Slider width
---@param value_format string Format type ("standard" or "decimal")
---@return string line The formatted line
function M.render_slider_row(component, value, width, value_format)
  local slider = M.render_slider(value, component.min, component.max, width)
  local formatted_value = ColorUtils.format_value(value, component.unit, value_format)

  -- Right-align value (5 chars should be enough for "360°" or "100%")
  local value_padded = string.format("%5s", formatted_value)

  return string.format("  %s: %s %s", component.label, slider, value_padded)
end

-- ============================================================================
-- Component Value Retrieval
-- ============================================================================

---Get current component values from state
---@param hex string Current hex color
---@param mode string Color mode
---@param alpha number Current alpha value
---@return table<string, number> values Map of component key to value
function M.get_component_values(hex, mode, alpha)
  local values = {}

  -- For "hex" mode, use HSL internally
  local effective_mode = mode == "hex" and "hsl" or mode

  if effective_mode == "hsl" then
    local h, s, l = ColorUtils.hex_to_hsl(hex)
    values.h = h
    values.s = s
    values.l = l
  elseif effective_mode == "rgb" then
    local r, g, b = ColorUtils.hex_to_rgb(hex)
    values.r = r
    values.g = g
    values.b = b
  elseif effective_mode == "hsv" then
    local h, s, v = ColorUtils.hex_to_hsv(hex)
    values.h = h
    values.s = s
    values.v = v
  elseif effective_mode == "cmyk" then
    local c, m, y, k = ColorUtils.hex_to_cmyk(hex)
    values.c = c
    values.m = m
    values.y = y
    values.k = k
  end

  values.a = alpha

  return values
end

-- ============================================================================
-- Component Adjustment
-- ============================================================================

---Adjust a component value and update the color
---@param component_index number 1-based index of component to adjust
---@param delta number Amount to change (positive or negative)
---@param schedule_render fun() Function to schedule a render
function M.adjust_component(component_index, delta, schedule_render)
  local state = State.state
  if not state then return end

  local components = M.get_components(state.color_mode, state.alpha_enabled)
  if component_index < 1 or component_index > #components then return end

  local component = components[component_index]
  local current_hex = State.get_active_color()
  local values = M.get_component_values(current_hex, state.color_mode, state.alpha)

  -- Calculate step size based on component range and current step multiplier
  local step_multiplier = State.get_step_multiplier()
  local base_step

  if component.unit == "deg" then
    -- Hue uses the hue step
    base_step = Types.BASE_STEP_HUE
  elseif component.unit == "int" then
    -- RGB uses a proportional step (255/100 ~= 2.5 per percent)
    base_step = 2.5
  else
    -- Percentages use the saturation/lightness step
    base_step = Types.BASE_STEP_SATURATION
  end

  local step = delta * base_step * step_multiplier
  local old_value = values[component.key]
  local new_value = old_value + step

  -- Handle wrapping or clamping
  if component.wrap then
    -- Wrap around (for hue)
    new_value = new_value % component.max
    if new_value < 0 then
      new_value = new_value + component.max
    end
  else
    -- Clamp to range
    new_value = math.max(component.min, math.min(component.max, new_value))
  end

  -- Special handling for alpha
  if component.key == "a" then
    state.alpha = new_value
    schedule_render()
    return
  end

  -- Update the color
  values[component.key] = new_value

  local effective_mode = state.color_mode == "hex" and "hsl" or state.color_mode
  local new_hex = ColorUtils.components_to_hex(values, effective_mode)

  -- Update saved_hsl and lightness_virtual for HSL component changes
  if effective_mode == "hsl" then
    if component.key == "h" or component.key == "s" then
      state.saved_hsl = { h = values.h, s = values.s }
    elseif component.key == "l" then
      -- Update lightness_virtual so the grid cursor moves
      state.lightness_virtual = new_value
    end
  end

  State.set_active_color(new_hex)
  schedule_render()
end

---Get the number of slider rows for current mode
---@return number count Number of slider rows
function M.get_slider_count()
  local state = State.state
  if not state then return 0 end
  local components = M.get_components(state.color_mode, state.alpha_enabled)
  return #components
end

return M
