---@module 'nvim-colorpicker.picker.layout'
---@brief Layout configuration and multipanel rendering for the color picker

local Types = require('nvim-colorpicker.picker.types')
local State = require('nvim-colorpicker.picker.state')
local Grid = require('nvim-colorpicker.picker.grid')
local Preview = require('nvim-colorpicker.picker.preview')
local ContentBuilder = require('nvim-float.content_builder')

local M = {}

-- Lazy-loaded tab renderers to avoid circular dependencies
local function get_info_tab()
  return require('nvim-colorpicker.picker.info_tab')
end

local function get_history_tab()
  return require('nvim-colorpicker.picker.history_tab')
end

local function get_presets_tab()
  return require('nvim-colorpicker.picker.presets_tab')
end

local function get_tabs()
  return require('nvim-colorpicker.picker.tabs')
end

-- ============================================================================
-- Local References
-- ============================================================================

local HEADER_HEIGHT = Types.HEADER_HEIGHT
local PREVIEW_BORDERS = Types.PREVIEW_BORDERS
local MIN_SIDE_BY_SIDE_WIDTH = Types.MIN_SIDE_BY_SIDE_WIDTH
local INFO_PANEL_MIN_WIDTH = Types.INFO_PANEL_MIN_WIDTH
local INFO_PANEL_MIN_HEIGHT = Types.INFO_PANEL_MIN_HEIGHT

-- ============================================================================
-- Layout Configuration
-- ============================================================================

---Create layout configuration for multipanel mode
---@return MultiPanelConfig
function M.create_layout_config()
  local ui = vim.api.nvim_list_uis()[1]
  local is_narrow = ui.width < MIN_SIDE_BY_SIDE_WIDTH

  local min_preview_height = PREVIEW_BORDERS + 1
  local grid_content_height = HEADER_HEIGHT + 11 + min_preview_height

  if is_narrow then
    return {
      layout = {
        split = "vertical",
        children = {
          {
            name = "grid",
            title = "Color Grid",
            ratio = 0.70,
            min_height = grid_content_height,
            focusable = true,
            cursorline = false,
            filetype = "nvim-colorpicker-grid",
          },
          {
            name = "info",
            title = "Info",
            ratio = 0.30,
            min_height = INFO_PANEL_MIN_HEIGHT,
            focusable = true,
            cursorline = true,
            filetype = "nvim-colorpicker-info",
          },
        }
      },
      total_width_ratio = 0.85,
      total_height_ratio = 0.75,
    }
  else
    return {
      layout = {
        split = "horizontal",
        children = {
          {
            name = "grid",
            title = "Color Grid",
            ratio = 0.60,
            min_width = 40,
            focusable = true,
            cursorline = false,
            filetype = "nvim-colorpicker-grid",
          },
          {
            name = "info",
            title = "Info",
            ratio = 0.40,
            min_width = INFO_PANEL_MIN_WIDTH,
            focusable = true,
            cursorline = true,
            filetype = "nvim-colorpicker-info",
          },
        }
      },
      total_width_ratio = 0.70,
      total_height_ratio = 0.65,
    }
  end
end

-- ============================================================================
-- ContentBuilder Render Functions
-- ============================================================================

---Render header using ContentBuilder
---@return ContentBuilder cb The content builder with header content
function M.render_header_cb()
  local state = State.state
  local cb = ContentBuilder.new()

  cb:blank()
  cb:styled("  " .. (state and state.options.title or "Pick Color"), "header")
  cb:blank()

  return cb
end

---Render footer (empty - preview is now integrated into the grid)
---@return ContentBuilder cb Empty content builder
---@return table swatch_info Empty (no longer used)
function M.render_footer_cb()
  return ContentBuilder.new(), {}
end

-- ============================================================================
-- Panel Rendering
-- ============================================================================

---Render the grid panel content
---@param multi_state MultiPanelState
---@return string[] lines
---@return table[] highlights
function M.render_grid_panel(multi_state)
  local state = State.state
  if not state then return {}, {} end

  local all_lines = {}
  local all_highlights = {}
  local line_offset = 0

  local panel = multi_state.panels["grid"]
  if not panel or not panel.float or not panel.float:is_valid() then
    return {}, {}
  end

  local panel_width = panel.rect.width
  local panel_height = panel.rect.height

  local grid_width, grid_height, preview_rows = Grid.calculate_grid_size(panel_width, panel_height)
  state.grid_width = grid_width
  state.grid_height = grid_height
  state.preview_rows = preview_rows

  local header_cb = M.render_header_cb()
  local header_lines = header_cb:build_lines()
  local header_highlights = header_cb:build_highlights()

  for _, line in ipairs(header_lines) do
    table.insert(all_lines, line)
  end
  for _, hl in ipairs(header_highlights) do
    table.insert(all_highlights, {
      line = hl.line + line_offset,
      col_start = hl.col_start,
      col_end = hl.col_end,
      hl_group = hl.hl_group,
    })
  end
  line_offset = #all_lines

  local grid_lines, grid_highlights = Grid.render_grid()
  for _, line in ipairs(grid_lines) do
    table.insert(all_lines, line)
  end
  for _, hl in ipairs(grid_highlights) do
    table.insert(all_highlights, {
      line = hl.line + line_offset,
      col_start = hl.col_start,
      col_end = hl.col_end,
      hl_group = hl.hl_group,
    })
  end
  line_offset = #all_lines

  local preview_lines, preview_highlights = Preview.render_preview()
  for _, line in ipairs(preview_lines) do
    table.insert(all_lines, line)
  end
  for _, hl in ipairs(preview_highlights) do
    table.insert(all_highlights, {
      line = hl.line + line_offset,
      col_start = hl.col_start,
      col_end = hl.col_end,
      hl_group = hl.hl_group,
    })
  end

  local footer_start_line = #all_lines

  local footer_cb, swatch_info = M.render_footer_cb()
  local footer_lines = footer_cb:build_lines()
  local footer_highlights = footer_cb:build_highlights()

  for _, line in ipairs(footer_lines) do
    table.insert(all_lines, line)
  end
  for _, hl in ipairs(footer_highlights) do
    table.insert(all_highlights, {
      line = hl.line + footer_start_line,
      col_start = hl.col_start,
      col_end = hl.col_end,
      hl_group = hl.hl_group,
    })
  end

  return all_lines, all_highlights
end

-- ============================================================================
-- Right Panel (Tab-Aware) Rendering
-- ============================================================================

---Render the right panel content based on active tab
---@param multi_state MultiPanelState
---@return string[] lines
---@return table[] highlights
function M.render_right_panel(multi_state)
  local state = State.state
  if not state then return {}, {} end

  local active_tab = state.active_tab or "info"

  if active_tab == "info" then
    return get_info_tab().render_info_panel(multi_state)
  elseif active_tab == "history" then
    return get_history_tab().render_history_panel(multi_state)
  elseif active_tab == "presets" then
    return get_presets_tab().render_presets_panel(multi_state)
  end

  -- Fallback to info tab
  return get_info_tab().render_info_panel(multi_state)
end

-- ============================================================================
-- Render Scheduling
-- ============================================================================

-- Forward declaration for schedule_render
local render_multipanel

---Schedule a render for multipanel mode
---@param render_fn fun() The render function to call
function M.schedule_render(render_fn)
  local state = State.state
  if not state or not state._multipanel then return end

  if state._render_pending then return end

  state._render_pending = true
  vim.schedule(function()
    if State.state and State.state._multipanel then
      State.state._render_pending = false
      render_fn()
    end
  end)
end

return M
