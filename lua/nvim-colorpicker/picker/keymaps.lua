---@module 'nvim-colorpicker.picker.keymaps'
---@brief Keymap setup and help display for the color picker

local State = require('nvim-colorpicker.picker.state')
local Navigation = require('nvim-colorpicker.picker.navigation')
local Config = require('nvim-colorpicker.config')
local Tabs = require('nvim-colorpicker.picker.tabs')

local M = {}

-- Lazy-loaded to avoid circular dependencies
local function get_history_tab()
  return require('nvim-colorpicker.picker.history_tab')
end

local function get_presets_tab()
  return require('nvim-colorpicker.picker.presets_tab')
end

local function get_info_tab()
  return require('nvim-colorpicker.picker.info_tab')
end

local function get_slider()
  return require('nvim-colorpicker.picker.slider')
end

-- ============================================================================
-- Controls Definition (for UiFloat help popup)
-- ============================================================================

---Get controls definition for the color picker
---@return ControlsDefinition[]
function M.get_controls_definition()
  local state = State.state
  local controls = {
    {
      header = "Grid Navigation",
      keys = {
        { key = "h / l", desc = "Move hue (left/right)" },
        { key = "j / k", desc = "Adjust lightness (down/up)" },
        { key = "J / K", desc = "Adjust saturation (less/more)" },
        { key = "[count]", desc = "Use counts: 10h, 50k" },
      }
    },
    {
      header = "Info Panel",
      keys = {
        { key = "j / k", desc = "Focus slider row" },
        { key = "- / +", desc = "Adjust focused slider" },
      }
    },
    {
      header = "Step Size",
      keys = {
        { key = "- / +", desc = "Decrease/increase multiplier (grid)" },
      }
    },
    {
      header = "Color Mode",
      keys = {
        { key = "m", desc = "Cycle mode (Hex/HSL/RGB/HSV/CMYK)" },
        { key = "f", desc = "Toggle format (standard/decimal)" },
        { key = "o", desc = "Cycle output format (filetype-aware)" },
      }
    },
    {
      header = "Tabs",
      keys = {
        { key = "g1", desc = "Info tab" },
        { key = "g2", desc = "History tab" },
        { key = "g3", desc = "Presets tab" },
      }
    },
    {
      header = "Actions",
      keys = {
        { key = "#", desc = "Enter hex color manually" },
        { key = "r", desc = "Reset to original" },
        { key = "Enter", desc = "Apply and close" },
        { key = "q / Esc", desc = "Cancel and close" },
      }
    },
  }

  if state and state.alpha_enabled then
    table.insert(controls, 4, {
      header = "Alpha",
      keys = {
        { key = "a / A", desc = "Decrease/increase opacity" },
      }
    })
  end

  return controls
end

---Show the help popup
function M.show_help()
  local state = State.state
  if not state then return end

  if state._multipanel then
    state._multipanel:show_controls(M.get_controls_definition())
    return
  end

  if state._float then
    state._float:show_controls(M.get_controls_definition())
  end
end

-- ============================================================================
-- Keymap Setup
-- ============================================================================

---Setup keymaps for multipanel mode
---@param multi MultiPanelState
---@param schedule_render fun() Function to schedule a render
---@param apply fun() Apply function
---@param cancel fun() Cancel function
function M.setup_multipanel_keymaps(multi, schedule_render, apply, cancel)
  local state = State.state
  if not state then return end

  local cfg = state._keymaps or Config.get_keymaps()

  local function get_key(name, default)
    return cfg[name] or default
  end

  local grid_keymaps = {}

  local nav_left = get_key("nav_left", "h")
  local nav_right = get_key("nav_right", "l")
  local nav_up = get_key("nav_up", "k")
  local nav_down = get_key("nav_down", "j")
  local sat_up = get_key("sat_up", "K")
  local sat_down = get_key("sat_down", "J")

  grid_keymaps[nav_left] = function()
    local count = vim.v.count1
    Navigation.shift_hue(-count, schedule_render)
  end
  grid_keymaps[nav_right] = function()
    local count = vim.v.count1
    Navigation.shift_hue(count, schedule_render)
  end
  grid_keymaps[nav_up] = function()
    local count = vim.v.count1
    Navigation.shift_lightness(count, schedule_render)
  end
  grid_keymaps[nav_down] = function()
    local count = vim.v.count1
    Navigation.shift_lightness(-count, schedule_render)
  end
  grid_keymaps[sat_up] = function()
    local count = vim.v.count1
    Navigation.shift_saturation(count, schedule_render)
  end
  grid_keymaps[sat_down] = function()
    local count = vim.v.count1
    Navigation.shift_saturation(-count, schedule_render)
  end

  grid_keymaps[get_key("step_down", "-")] = function()
    State.decrease_step_size(schedule_render)
  end
  local step_up_keys = get_key("step_up", { "+", "=" })
  if type(step_up_keys) == "table" then
    for _, k in ipairs(step_up_keys) do
      grid_keymaps[k] = function()
        State.increase_step_size(schedule_render)
      end
    end
  else
    grid_keymaps[step_up_keys] = function()
      State.increase_step_size(schedule_render)
    end
  end

  multi:set_panel_keymaps("grid", grid_keymaps)

  local common_keymaps = {}

  common_keymaps[get_key("reset", "r")] = function()
    Navigation.reset_color(schedule_render)
  end
  common_keymaps[get_key("hex_input", "#")] = function()
    Navigation.enter_hex_input(schedule_render)
  end
  common_keymaps[get_key("apply", "<CR>")] = apply

  local cancel_keys = get_key("cancel", { "q", "<Esc>" })
  if type(cancel_keys) == "table" then
    for _, k in ipairs(cancel_keys) do
      common_keymaps[k] = cancel
    end
  else
    common_keymaps[cancel_keys] = cancel
  end

  common_keymaps[get_key("help", "?")] = M.show_help

  common_keymaps[get_key("cycle_mode", "m")] = function()
    Navigation.cycle_mode(schedule_render)
  end
  common_keymaps[get_key("cycle_format", "f")] = function()
    Navigation.cycle_format(schedule_render)
  end
  common_keymaps[get_key("cycle_output_format", "o")] = function()
    State.cycle_output_format(schedule_render)
  end

  common_keymaps[get_key("alpha_up", "A")] = function()
    local count = vim.v.count1
    Navigation.adjust_alpha(count, schedule_render)
  end
  common_keymaps[get_key("alpha_down", "a")] = function()
    local count = vim.v.count1
    Navigation.adjust_alpha(-count, schedule_render)
  end

  common_keymaps[get_key("focus_next", "<Tab>")] = function()
    multi:focus_next_panel()
  end
  common_keymaps[get_key("focus_prev", "<S-Tab>")] = function()
    multi:focus_prev_panel()
  end

  if state and state.options.custom_controls then
    for _, control in ipairs(state.options.custom_controls) do
      if control.key then
        common_keymaps[control.key] = function()
          Navigation.toggle_custom_control(control.id, schedule_render)
        end
      end
    end
  end

  -- Tab switching keymaps (g+number for VHS compatibility)
  common_keymaps["g1"] = function()
    Tabs.switch_tab("info", schedule_render)
  end
  common_keymaps["g2"] = function()
    Tabs.switch_tab("history", schedule_render)
  end
  common_keymaps["g3"] = function()
    Tabs.switch_tab("presets", schedule_render)
  end

  multi:set_keymaps(common_keymaps)

  -- Info panel keymaps (empty - navigation uses native cursor movement)
  multi:set_panel_keymaps("info", {})
end

-- ============================================================================
-- History Tab Keymaps
-- ============================================================================

---Setup history-specific keymaps when history tab is active
---@param multi MultiPanelState
---@param schedule_render fun() Function to schedule a render
function M.setup_history_keymaps(multi, schedule_render)
  local state = State.state
  if not state then return end

  local HistoryTab = get_history_tab()

  -- Helper to get element at cursor
  local function get_element()
    local info_panel = multi.panels and multi.panels.info
    if info_panel and info_panel.float then
      return info_panel.float:get_element_at_cursor()
    end
    return nil
  end

  local history_keymaps = {}

  -- Select uses element at cursor directly
  history_keymaps["<CR>"] = function()
    local element = get_element()
    if element then
      HistoryTab.select_element(element, schedule_render)
    end
  end

  -- Delete uses element at cursor directly
  history_keymaps["d"] = function()
    local element = get_element()
    if element then
      HistoryTab.delete_element(element, schedule_render)
    end
  end

  history_keymaps["c"] = function()
    HistoryTab.clear_all(schedule_render)
  end

  multi:set_panel_keymaps("info", history_keymaps)

  -- Setup ContentBuilder for element tracking (on every render)
  local info_buf = multi:get_panel_buffer("info")
  if info_buf and vim.api.nvim_buf_is_valid(info_buf) then
    HistoryTab.apply_swatch_extmarks(info_buf)

    local cb = HistoryTab.get_content_builder()
    if cb then
      multi:set_panel_content_builder("info", cb)
    end
  end
end

---Clear history-specific keymaps (when switching away from history tab)
---@param multi MultiPanelState
function M.clear_history_keymaps(multi)
  multi:set_panel_keymaps("info", {})
end

-- ============================================================================
-- Presets Tab Keymaps
-- ============================================================================

---Setup presets-specific keymaps when presets tab is active
---@param multi MultiPanelState
---@param schedule_render fun() Function to schedule a render
function M.setup_presets_keymaps(multi, schedule_render)
  local state = State.state
  if not state then return end

  local PresetsTab = get_presets_tab()

  -- Helper to get element at cursor
  local function get_element()
    local info_panel = multi.panels and multi.panels.info
    if info_panel and info_panel.float then
      return info_panel.float:get_element_at_cursor()
    end
    return nil
  end

  local presets_keymaps = {}

  -- Actions use element at cursor directly
  presets_keymaps["<CR>"] = function()
    local element = get_element()
    if element then
      PresetsTab.action_on_element(element, schedule_render)
    end
  end

  presets_keymaps["l"] = function()
    local element = get_element()
    if element then
      PresetsTab.toggle_element(element, schedule_render)
    end
  end

  presets_keymaps["h"] = function()
    local element = get_element()
    if element then
      PresetsTab.toggle_element(element, schedule_render)
    end
  end

  presets_keymaps["zo"] = function()
    local element = get_element()
    if element then
      PresetsTab.toggle_element(element, schedule_render)
    end
  end

  presets_keymaps["zc"] = function()
    local element = get_element()
    if element then
      PresetsTab.toggle_element(element, schedule_render)
    end
  end

  presets_keymaps["zR"] = function()
    PresetsTab.expand_all(schedule_render)
  end

  presets_keymaps["zM"] = function()
    PresetsTab.collapse_all(schedule_render)
  end

  multi:set_panel_keymaps("info", presets_keymaps)

  -- Setup ContentBuilder for element tracking (on every render)
  local info_buf = multi:get_panel_buffer("info")
  if info_buf and vim.api.nvim_buf_is_valid(info_buf) then
    PresetsTab.apply_swatch_extmarks(info_buf)

    local cb = PresetsTab.get_content_builder()
    if cb then
      multi:set_panel_content_builder("info", cb)
    end
  end
end

---Clear presets-specific keymaps (when switching away from presets tab)
---@param multi MultiPanelState
function M.clear_presets_keymaps(multi)
  multi:set_panel_keymaps("info", {})
end

-- ============================================================================
-- Info Tab (Sliders) Keymaps
-- ============================================================================

---Setup info-tab-specific keymaps when info tab is active (for slider adjustment)
---@param multi MultiPanelState
---@param schedule_render fun() Function to schedule a render
function M.setup_info_keymaps(multi, schedule_render)
  local state = State.state
  if not state then return end

  local cfg = state._keymaps or Config.get_keymaps()
  local Slider = get_slider()
  local InfoTab = get_info_tab()

  local info_keymaps = {}
  local Navigation = require('nvim-colorpicker.picker.navigation')

  -- Helper to get element at cursor
  local function get_element()
    local info_panel = multi.panels and multi.panels.info
    if info_panel and info_panel.float then
      return info_panel.float:get_element_at_cursor()
    end
    return nil
  end

  -- Helper to get info window and cursor
  local function get_cursor_info()
    local info_win = multi:get_panel_window("info")
    local cursor_pos = info_win and vim.api.nvim_win_is_valid(info_win) and vim.api.nvim_win_get_cursor(info_win)
    return info_win, cursor_pos
  end

  -- Helper to restore cursor after render
  local function restore_cursor_after_render(info_win, cursor_pos)
    vim.schedule(function()
      if cursor_pos and info_win and vim.api.nvim_win_is_valid(info_win) then
        pcall(vim.api.nvim_win_set_cursor, info_win, cursor_pos)
      end
    end)
  end

  -- Adjust slider based on element at cursor
  local function adjust_slider(delta)
    local count = vim.v.count1
    local info_win, cursor_pos = get_cursor_info()
    local element = get_element()

    if element then
      InfoTab.adjust_slider_element(element, delta * count, function()
        schedule_render()
        restore_cursor_after_render(info_win, cursor_pos)
      end)
    end
  end

  -- Wrapper for actions that trigger re-render (format toggle, mode cycle)
  local function action_and_restore(action_fn)
    local info_win, cursor_pos = get_cursor_info()
    action_fn()
    restore_cursor_after_render(info_win, cursor_pos)
  end

  -- Step adjustment keys adjust the slider at cursor
  local step_down_key = cfg.step_down or "-"
  local step_up_keys = cfg.step_up or { "+", "=" }

  -- Decrease component value
  if type(step_down_key) == "table" then
    for _, k in ipairs(step_down_key) do
      info_keymaps[k] = function()
        adjust_slider(-1)
      end
    end
  else
    info_keymaps[step_down_key] = function()
      adjust_slider(-1)
    end
  end

  -- Increase component value
  if type(step_up_keys) == "table" then
    for _, k in ipairs(step_up_keys) do
      info_keymaps[k] = function()
        adjust_slider(1)
      end
    end
  else
    info_keymaps[step_up_keys] = function()
      adjust_slider(1)
    end
  end

  -- Format toggle with cursor preservation
  local format_key = cfg.cycle_format or "f"
  info_keymaps[format_key] = function()
    action_and_restore(function()
      Navigation.cycle_format(schedule_render)
    end)
  end

  -- Mode cycle with cursor preservation
  local mode_key = cfg.cycle_mode or "m"
  info_keymaps[mode_key] = function()
    action_and_restore(function()
      Navigation.cycle_mode(schedule_render)
    end)
  end

  -- Output format cycle with cursor preservation
  local output_format_key = cfg.cycle_output_format or "o"
  info_keymaps[output_format_key] = function()
    action_and_restore(function()
      State.cycle_output_format(schedule_render)
    end)
  end

  multi:set_panel_keymaps("info", info_keymaps)

  -- Setup ContentBuilder for element tracking (on every render)
  local info_buf = multi:get_panel_buffer("info")
  if info_buf and vim.api.nvim_buf_is_valid(info_buf) then
    local cb = InfoTab.get_content_builder()
    if cb then
      multi:set_panel_content_builder("info", cb)
    end
  end
end

---Clear info-specific keymaps (when switching away from info tab)
---@param multi MultiPanelState
function M.clear_info_keymaps(multi)
  multi:set_panel_keymaps("info", {})
end

return M
