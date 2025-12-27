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

-- ============================================================================
-- Controls Definition (for UiFloat help popup)
-- ============================================================================

---Get controls definition for the color picker
---@return ControlsDefinition[]
function M.get_controls_definition()
  local state = State.state
  local controls = {
    {
      header = "Navigation",
      keys = {
        { key = "h / l", desc = "Move hue (left/right)" },
        { key = "j / k", desc = "Adjust lightness (down/up)" },
        { key = "J / K", desc = "Adjust saturation (less/more)" },
        { key = "[count]", desc = "Use counts: 10h, 50k" },
      }
    },
    {
      header = "Step Size",
      keys = {
        { key = "- / +", desc = "Decrease/increase multiplier" },
      }
    },
    {
      header = "Color Mode",
      keys = {
        { key = "m", desc = "Cycle mode (HSL/RGB/CMYK/HSV)" },
        { key = "f", desc = "Toggle format (standard/decimal)" },
      }
    },
    {
      header = "Tabs",
      keys = {
        { key = "Alt+1", desc = "Info tab" },
        { key = "Alt+2", desc = "History tab" },
        { key = "Alt+3", desc = "Presets tab" },
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

  -- Tab switching keymaps (Alt+number to preserve count prefixes)
  common_keymaps["<A-1>"] = function()
    Tabs.switch_tab("info", schedule_render)
  end
  common_keymaps["<A-2>"] = function()
    Tabs.switch_tab("history", schedule_render)
  end
  common_keymaps["<A-3>"] = function()
    Tabs.switch_tab("presets", schedule_render)
  end

  multi:set_keymaps(common_keymaps)

  -- Info panel-specific keymaps (set on info panel)
  local info_keymaps = {}
  -- Info panel has InputManager, so most navigation is handled there
  multi:set_panel_keymaps("info", info_keymaps)
end

-- ============================================================================
-- History Tab Keymaps
-- ============================================================================

-- Autocmd ID for history CursorMoved handler
local history_cursor_autocmd = nil

---Setup history-specific keymaps when history tab is active
---@param multi MultiPanelState
---@param schedule_render fun() Function to schedule a render
function M.setup_history_keymaps(multi, schedule_render)
  local state = State.state
  if not state then return end

  local HistoryTab = get_history_tab()

  local history_keymaps = {}

  -- Navigation uses default Neovim movement - CursorMoved autocmd syncs selection
  history_keymaps["<CR>"] = function()
    HistoryTab.select_current(schedule_render)
  end
  history_keymaps["d"] = function()
    HistoryTab.delete_current(schedule_render)
  end
  history_keymaps["c"] = function()
    HistoryTab.clear_all(schedule_render)
  end

  -- Apply these keymaps to the info panel (which shows history content when history tab is active)
  multi:set_panel_keymaps("info", history_keymaps)

  -- Setup CursorMoved autocmd for info panel to sync selection with cursor
  local info_buf = multi:get_panel_buffer("info")
  if info_buf and vim.api.nvim_buf_is_valid(info_buf) then
    -- Clean up any existing autocmd
    if history_cursor_autocmd then
      pcall(vim.api.nvim_del_autocmd, history_cursor_autocmd)
    end

    history_cursor_autocmd = vim.api.nvim_create_autocmd("CursorMoved", {
      buffer = info_buf,
      callback = function()
        HistoryTab.on_cursor_moved()
      end,
    })
  end
end

---Clear history-specific keymaps (when switching away from history tab)
---@param multi MultiPanelState
function M.clear_history_keymaps(multi)
  -- Reset to empty keymaps for the info panel
  multi:set_panel_keymaps("info", {})

  -- Clean up CursorMoved autocmd
  if history_cursor_autocmd then
    pcall(vim.api.nvim_del_autocmd, history_cursor_autocmd)
    history_cursor_autocmd = nil
  end
end

-- ============================================================================
-- Presets Tab Keymaps
-- ============================================================================

-- Autocmd ID for presets CursorMoved handler
local presets_cursor_autocmd = nil

---Setup presets-specific keymaps when presets tab is active
---@param multi MultiPanelState
---@param schedule_render fun() Function to schedule a render
function M.setup_presets_keymaps(multi, schedule_render)
  local state = State.state
  if not state then return end

  local PresetsTab = get_presets_tab()

  local presets_keymaps = {}

  -- Navigation uses default Neovim movement - CursorMoved autocmd syncs selection
  presets_keymaps["<CR>"] = function()
    PresetsTab.select_current(schedule_render)
  end
  presets_keymaps["l"] = function()
    PresetsTab.toggle_expand(schedule_render)
  end
  presets_keymaps["h"] = function()
    -- Collapse current or parent
    PresetsTab.toggle_expand(schedule_render)
  end
  presets_keymaps["zo"] = function()
    PresetsTab.toggle_expand(schedule_render)
  end
  presets_keymaps["zc"] = function()
    PresetsTab.toggle_expand(schedule_render)
  end
  presets_keymaps["zR"] = function()
    PresetsTab.expand_all(schedule_render)
  end
  presets_keymaps["zM"] = function()
    PresetsTab.collapse_all(schedule_render)
  end

  -- Apply these keymaps to the info panel
  multi:set_panel_keymaps("info", presets_keymaps)

  -- Setup CursorMoved autocmd for info panel to sync selection with cursor
  local info_buf = multi:get_panel_buffer("info")
  if info_buf and vim.api.nvim_buf_is_valid(info_buf) then
    -- Clean up any existing autocmd
    if presets_cursor_autocmd then
      pcall(vim.api.nvim_del_autocmd, presets_cursor_autocmd)
    end

    presets_cursor_autocmd = vim.api.nvim_create_autocmd("CursorMoved", {
      buffer = info_buf,
      callback = function()
        PresetsTab.on_cursor_moved()
      end,
    })
  end
end

---Clear presets-specific keymaps (when switching away from presets tab)
---@param multi MultiPanelState
function M.clear_presets_keymaps(multi)
  multi:set_panel_keymaps("info", {})

  -- Clean up CursorMoved autocmd
  if presets_cursor_autocmd then
    pcall(vim.api.nvim_del_autocmd, presets_cursor_autocmd)
    presets_cursor_autocmd = nil
  end
end

return M
