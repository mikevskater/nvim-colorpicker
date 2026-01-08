---@module 'nvim-colorpicker.picker'
---@brief Interactive color picker with HSL grid navigation
---
--- This is the main entry point for the color picker module.
--- Delegates to submodules for specific functionality.

local Types = require('nvim-colorpicker.picker.types')
local State = require('nvim-colorpicker.picker.state')
local Grid = require('nvim-colorpicker.picker.grid')
local Preview = require('nvim-colorpicker.picker.preview')
local Layout = require('nvim-colorpicker.picker.layout')
local Navigation = require('nvim-colorpicker.picker.navigation')
local InfoPanel = require('nvim-colorpicker.picker.info_tab')
local Keymaps = require('nvim-colorpicker.picker.keymaps')
local Actions = require('nvim-colorpicker.picker.actions')
local ColorUtils = require('nvim-colorpicker.color')
local Config = require('nvim-colorpicker.config')
local UiFloat = require('nvim-float.window')
local MultiPanel = require('nvim-float.float.multipanel')

local ColorPicker = {}

-- Re-export types for external use
ColorPicker.Types = Types

-- ============================================================================
-- Rendering
-- ============================================================================

-- Forward declarations
local render_multipanel
local schedule_render

---Render all multipanel panels
render_multipanel = function()
  local state = State.state
  if not state or not state._multipanel then return end

  local multi = state._multipanel
  local active_tab = state.active_tab or "info"

  multi:render_panel("grid")
  multi:render_panel("info")

  -- Handle tab-specific keymaps
  if active_tab == "info" then
    -- Setup info tab keymaps (for slider adjustment)
    Keymaps.setup_info_keymaps(multi, schedule_render)
  elseif active_tab == "history" then
    -- Clear info keymaps first, then setup history keymaps
    Keymaps.clear_info_keymaps(multi)
    Keymaps.setup_history_keymaps(multi, schedule_render)
  elseif active_tab == "presets" then
    -- Clear info keymaps first, then setup presets keymaps
    Keymaps.clear_info_keymaps(multi)
    Keymaps.setup_presets_keymaps(multi, schedule_render)
  else
    -- Clear tab-specific keymaps for unknown tabs
    Keymaps.clear_info_keymaps(multi)
    Keymaps.clear_history_keymaps(multi)
  end

  -- Call on_change callback
  if state.options.on_change then
    local result = Actions.build_result()
    state.options.on_change(result)
  end
end

---Schedule a render for the next event loop iteration (simple, no debounce)
schedule_render = function()
  vim.schedule(function()
    if State.state and State.state._multipanel then
      render_multipanel()
    end
  end)
end

-- ============================================================================
-- Apply/Cancel Actions
-- ============================================================================

---Apply and close (using shared Actions module)
local function apply()
  Actions.apply(ColorPicker.close)
end

---Cancel and close (using shared Actions module)
local function cancel()
  Actions.cancel(ColorPicker.close)
end

-- ============================================================================
-- Window Management
-- ============================================================================

---Close the color picker
function ColorPicker.close()
  local state = State.state
  if not state then return end

  local multipanel = state._multipanel

  -- Use shared cleanup (clears state, augroup, and highlights)
  Actions.full_cleanup("NvimColorPickerFocusLoss")

  if multipanel and multipanel:is_valid() then
    multipanel:close()
  end
end

-- ============================================================================
-- Public API
-- ============================================================================

---Show the color picker in multipanel mode
---@param options NvimColorPickerOptions
function ColorPicker.show_multipanel(options)
  ColorPicker.close()

  if not options or not options.initial then
    vim.notify("nvim-colorpicker: initial color required", vim.log.levels.ERROR)
    return
  end

  local initial = vim.deepcopy(options.initial)
  if initial.color then
    initial.color = ColorUtils.normalize_hex(initial.color)
  else
    initial.color = "#808080"
  end

  local layout_config = Layout.create_layout_config()

  local grid_title = options.title or "Color Grid"

  if options.title then
    layout_config.layout.children[1].title = grid_title
  end

  layout_config.layout.children[1].on_render = Layout.render_grid_panel
  layout_config.layout.children[2].on_render = Layout.render_right_panel

  layout_config.layout.children[1].on_focus = function(multi_state)
    if State.state then State.state.focused_panel = "grid" end
    multi_state:update_panel_title("grid", grid_title .. " *")
    multi_state:update_panel_title("info", "Info")
  end

  layout_config.layout.children[1].on_blur = function(multi_state)
    multi_state:update_panel_title("grid", grid_title)
  end

  layout_config.layout.children[2].on_focus = function(multi_state)
    if State.state then State.state.focused_panel = "info" end
    local Tabs = require('nvim-colorpicker.picker.tabs')
    multi_state:update_panel_title("info", Tabs.get_panel_title(true))
    multi_state:update_panel_title("grid", grid_title)
  end

  layout_config.layout.children[2].on_blur = function(multi_state)
    local Tabs = require('nvim-colorpicker.picker.tabs')
    multi_state:update_panel_title("info", Tabs.get_panel_title(false))
  end

  layout_config.controls = Keymaps.get_controls_definition()
  layout_config.footer = "? = Controls"
  layout_config.initial_focus = "grid"
  layout_config.augroup_name = "NvimColorPickerMulti"

  layout_config.on_close = function()
    State.clear_state()
  end

  local multi = MultiPanel.create(UiFloat, layout_config)

  if not multi or not multi:is_valid() then
    vim.notify("nvim-colorpicker: Failed to create window", vim.log.levels.ERROR)
    return
  end

  local grid_panel = multi.panels["grid"]
  local grid_buf = grid_panel and grid_panel.float and grid_panel.float.bufnr
  local grid_win = grid_panel and grid_panel.float and grid_panel.float.winid

  local grid_width, grid_height, preview_rows = 21, 9, 1
  if grid_panel and grid_panel.rect then
    grid_width, grid_height, preview_rows = Grid.calculate_grid_size(grid_panel.rect.width, grid_panel.rect.height)
  end

  local resolved_keymaps = Config.get_keymaps()
  if options.keymaps then
    resolved_keymaps = vim.tbl_deep_extend('force', resolved_keymaps, options.keymaps)
  end

  State.init_state(
    initial,
    options,
    grid_width,
    grid_height,
    preview_rows,
    vim.api.nvim_create_namespace("nvim_colorpicker_multi"),
    resolved_keymaps,
    multi,
    grid_buf,
    grid_win
  )

  Keymaps.setup_multipanel_keymaps(multi, schedule_render, apply, cancel)
  render_multipanel()

  local augroup = vim.api.nvim_create_augroup("NvimColorPickerFocusLoss", { clear = true })

  local function on_focus_lost()
    if not State.state then return end

    vim.schedule(function()
      if not State.state then return end

      local current_win = vim.api.nvim_get_current_win()

      -- Check if focus moved to a floating window (e.g., controls popup)
      -- Don't close picker if user is interacting with a modal/popup
      local ok, win_config = pcall(vim.api.nvim_win_get_config, current_win)
      if ok and win_config.relative and win_config.relative ~= '' then
        return
      end

      local grid_panel = State.state._multipanel and State.state._multipanel.panels["grid"]
      local info_panel = State.state._multipanel and State.state._multipanel.panels["info"]

      local grid_win = grid_panel and grid_panel.float and grid_panel.float.winid
      local info_win = info_panel and info_panel.float and info_panel.float.winid

      if current_win ~= grid_win and current_win ~= info_win then
        cancel()
      end
    end)
  end

  local grid_panel_ref = multi.panels["grid"]
  local info_panel_ref = multi.panels["info"]

  if grid_panel_ref and grid_panel_ref.float and grid_panel_ref.float.winid then
    vim.api.nvim_create_autocmd("WinLeave", {
      group = augroup,
      buffer = grid_panel_ref.float.bufnr,
      callback = on_focus_lost,
    })
  end

  if info_panel_ref and info_panel_ref.float and info_panel_ref.float.winid then
    vim.api.nvim_create_autocmd("WinLeave", {
      group = augroup,
      buffer = info_panel_ref.float.bufnr,
      callback = on_focus_lost,
    })
  end
end

---Open color picker (wrapper for pick API)
---@param opts table? Options
function ColorPicker.pick(opts)
  opts = opts or {}

  local initial
  if opts.color and type(opts.color) == "string" then
    initial = { color = opts.color }
  elseif opts.initial then
    initial = opts.initial
  else
    initial = { color = "#808080" }
  end

  ColorPicker.show_multipanel({
    initial = initial,
    title = opts.title,
    on_change = opts.on_change,
    on_select = opts.on_select,
    on_cancel = opts.on_cancel,
    forced_mode = opts.forced_mode,
    alpha_enabled = opts.alpha_enabled,
    initial_alpha = opts.initial_alpha,
    keymaps = opts.keymaps,
    custom_controls = opts.custom_controls,
    target_filetype = opts.target_filetype,
  })
end

---Check if picker is open
---@return boolean
function ColorPicker.is_open()
  return State.has_state()
end

---Get current state
---@return NvimColorPickerState?
function ColorPicker.get_state()
  return State.get_state()
end

---Set the current color (for external updates, e.g., when switching fg/bg target)
---@param hex string The new hex color
---@param original_hex string? Optional original color for reset/comparison (defaults to same as hex)
function ColorPicker.set_color(hex, original_hex)
  local state = State.state
  if not state then return end

  hex = ColorUtils.normalize_hex(hex)
  state.current.color = hex

  if original_hex then
    local normalized_original = ColorUtils.normalize_hex(original_hex)
    state.original.color = normalized_original
    state.original_alpha = state.alpha
  end

  local h, s, _ = ColorUtils.hex_to_hsl(hex)
  state.saved_hsl = { h = h, s = s }

  state.lightness_virtual = nil
  state.saturation_virtual = nil

  schedule_render()
end

---Get the current color
---@return string? hex The current hex color
function ColorPicker.get_color()
  local state = State.state
  if not state then return nil end
  return state.current.color
end

return ColorPicker
