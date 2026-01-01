---@module 'nvim-colorpicker.picker.state'
---@brief State management for the color picker

local Types = require('nvim-colorpicker.picker.types')
local ColorUtils = require('nvim-colorpicker.color')

-- Lazy load filetypes to avoid circular dependencies
local function get_filetypes()
  return require('nvim-colorpicker.filetypes')
end

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

  -- Get filetype adapter and available formats
  local target_filetype = options.target_filetype
  local adapter = target_filetype and get_filetypes().get_adapter(target_filetype) or nil
  local output_format = options.original_format or (adapter and adapter.default_format) or "hex"

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
    -- Filetype-aware output format
    target_filetype = target_filetype,
    output_format = output_format,
    _adapter = adapter,
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

-- ============================================================================
-- Output Format Management
-- ============================================================================

---Get available output formats for current filetype
---@return string[] formats Available format names
function M.get_available_formats()
  if not M.state then return { "hex" } end

  local adapter = M.state._adapter
  if not adapter then return { "hex", "rgb", "hsl" } end

  -- Build list of available formats from adapter patterns
  local formats = {}
  local seen = {}

  -- Add adapter default first
  if adapter.default_format then
    table.insert(formats, adapter.default_format)
    seen[adapter.default_format] = true
  end

  -- Add formats from patterns
  if adapter.patterns then
    for _, pattern_def in ipairs(adapter.patterns) do
      if pattern_def.format and not seen[pattern_def.format] then
        table.insert(formats, pattern_def.format)
        seen[pattern_def.format] = true
      end
    end
  end

  -- Always include hex as fallback
  if not seen["hex"] then
    table.insert(formats, "hex")
  end

  return formats
end

---Get the formatted output preview for current color
---@return string formatted The color formatted for the target filetype
function M.get_formatted_output()
  if not M.state then return "#808080" end

  local hex = M.state.current.color or "#808080"
  local alpha = M.state.alpha_enabled and M.state.alpha or nil
  local adapter = M.state._adapter
  local format = M.state.output_format or "hex"

  if adapter and adapter.format_color then
    local ok, result = pcall(adapter.format_color, adapter, hex, format, alpha)
    if ok and result then
      return result
    end
  end

  -- Fallback to hex with alpha if needed
  if alpha and alpha < 100 then
    local alpha_byte = math.floor(alpha * 255 / 100 + 0.5)
    return hex .. string.format("%02X", alpha_byte)
  end

  return hex
end

---Get current output format
---@return string format
function M.get_output_format()
  if not M.state then return "hex" end
  return M.state.output_format or "hex"
end

---Set output format
---@param format string
function M.set_output_format(format)
  if not M.state then return end
  M.state.output_format = format
end

---Cycle to next output format
---@param schedule_render fun() Function to schedule a render
function M.cycle_output_format(schedule_render)
  if not M.state then return end

  local formats = M.get_available_formats()
  if #formats <= 1 then return end

  local current = M.state.output_format or formats[1]
  local current_idx = 1

  for i, fmt in ipairs(formats) do
    if fmt == current then
      current_idx = i
      break
    end
  end

  -- Cycle to next format
  local next_idx = (current_idx % #formats) + 1
  M.state.output_format = formats[next_idx]

  if schedule_render then
    schedule_render()
  end
end

return M
