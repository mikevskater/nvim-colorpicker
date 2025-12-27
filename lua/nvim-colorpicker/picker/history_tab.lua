---@module 'nvim-colorpicker.picker.history_tab'
---@brief History tab rendering for the color picker

local State = require('nvim-colorpicker.picker.state')
local History = require('nvim-colorpicker.history')
local ColorUtils = require('nvim-colorpicker.color')
local ContentBuilder = require('nvim-float.content_builder')

local M = {}

-- ============================================================================
-- Constants
-- ============================================================================

---@type number Maximum history items to display
local MAX_DISPLAY_ITEMS = 10

-- ============================================================================
-- History Highlight Management
-- ============================================================================

---@type table<string, boolean> Cache of created highlight groups
local created_highlights = {}

---Get or create a highlight group for a color swatch
---@param hex string The hex color
---@return string hl_group The highlight group name
local function get_swatch_highlight(hex)
  local hl_name = "NvimColorPickerHistory_" .. hex:gsub("#", "")

  if not created_highlights[hl_name] then
    local fg = ColorUtils.get_contrast_color(hex)
    vim.api.nvim_set_hl(0, hl_name, { bg = hex, fg = fg })
    created_highlights[hl_name] = true
  end

  return hl_name
end

-- ============================================================================
-- History Navigation
-- ============================================================================

---Move cursor up in history
---@param schedule_render fun() Function to trigger re-render
function M.cursor_up(schedule_render)
  local state = State.state
  if not state then return end

  local history = History.get_recent(MAX_DISPLAY_ITEMS)
  if #history == 0 then return end

  state.history_cursor = state.history_cursor - 1
  if state.history_cursor < 1 then
    state.history_cursor = #history
  end

  schedule_render()
end

---Move cursor down in history
---@param schedule_render fun() Function to trigger re-render
function M.cursor_down(schedule_render)
  local state = State.state
  if not state then return end

  local history = History.get_recent(MAX_DISPLAY_ITEMS)
  if #history == 0 then return end

  state.history_cursor = state.history_cursor + 1
  if state.history_cursor > #history then
    state.history_cursor = 1
  end

  schedule_render()
end

---Select the currently highlighted history item
---@param schedule_render fun() Function to trigger re-render
function M.select_current(schedule_render)
  local state = State.state
  if not state then return end

  local history = History.get_recent(MAX_DISPLAY_ITEMS)
  if #history == 0 then return end

  local selected_hex = history[state.history_cursor]
  if selected_hex then
    State.set_active_color(selected_hex)

    -- Update saved HSL for proper grid navigation
    local h, s, _ = ColorUtils.hex_to_hsl(selected_hex)
    state.saved_hsl = { h = h, s = s }
    state.lightness_virtual = nil
    state.saturation_virtual = nil

    schedule_render()
  end
end

---Delete the currently highlighted history item
---@param schedule_render fun() Function to trigger re-render
function M.delete_current(schedule_render)
  local state = State.state
  if not state then return end

  local history = History.get_recent(MAX_DISPLAY_ITEMS)
  if #history == 0 then return end

  -- Get the color to delete
  local to_delete = history[state.history_cursor]
  if not to_delete then return end

  -- Get all colors and remove the selected one
  local all_colors = History.get_recent()
  local new_colors = {}
  for _, color in ipairs(all_colors) do
    if color ~= to_delete then
      table.insert(new_colors, color)
    end
  end

  -- Clear and re-add remaining colors (in reverse to maintain order)
  History.clear_recent()
  for i = #new_colors, 1, -1 do
    History.add_recent(new_colors[i])
  end

  -- Adjust cursor if needed
  local new_history = History.get_recent(MAX_DISPLAY_ITEMS)
  if state.history_cursor > #new_history then
    state.history_cursor = math.max(1, #new_history)
  end

  schedule_render()
end

---Clear all history
---@param schedule_render fun() Function to trigger re-render
function M.clear_all(schedule_render)
  local state = State.state
  if not state then return end

  History.clear_recent()
  state.history_cursor = 1

  schedule_render()
end

-- ============================================================================
-- History Tab Rendering
-- ============================================================================

---Render the history tab content (without tab bar)
---@param cb ContentBuilder The content builder to add content to
function M.render_history_content(cb)
  local state = State.state
  if not state then return end

  local history = History.get_recent(MAX_DISPLAY_ITEMS)

  cb:blank()

  if #history == 0 then
    cb:styled("  No recent colors", "muted")
    cb:blank()
    cb:styled("  Pick colors to add", "muted")
    cb:styled("  them to history.", "muted")
  else
    cb:styled(string.format("  Recent (%d)", #history), "header")
    cb:blank()

    for i, hex in ipairs(history) do
      local is_selected = i == state.history_cursor
      local prefix = is_selected and " >" or "  "
      local style = is_selected and "emphasis" or "value"

      -- Create swatch highlight
      local swatch_hl = get_swatch_highlight(hex)

      -- Build the line with swatch
      cb:spans({
        { text = prefix, style = style },
        { text = string.format("%2d ", i), style = "muted" },
        { text = hex, style = style },
        { text = " ", style = "normal" },
        { text = "████", hl_group = swatch_hl },
      })
    end
  end

  cb:blank()
  cb:styled("  " .. string.rep("─", 16), "muted")
  cb:blank()

  if #history > 0 then
    cb:spans({
      { text = "  ", style = "normal" },
      { text = "Enter", style = "key" },
      { text = "=Select  ", style = "muted" },
      { text = "d", style = "key" },
      { text = "=Del", style = "muted" },
    })
  end
end

---Render the complete history panel (tab bar + history content)
---@param multi_state MultiPanelState
---@return string[] lines
---@return table[] highlights
function M.render_history_panel(multi_state)
  local state = State.state
  if not state then return {}, {} end

  local Tabs = require('nvim-colorpicker.picker.tabs')

  local all_lines = {}
  local all_highlights = {}

  -- Add tab bar
  local tab_lines, tab_highlights = Tabs.render_tab_bar()
  for _, line in ipairs(tab_lines) do
    table.insert(all_lines, line)
  end
  for _, hl in ipairs(tab_highlights) do
    table.insert(all_highlights, hl)
  end
  local line_offset = #all_lines

  -- Add history content
  local cb = ContentBuilder.new()
  M.render_history_content(cb)

  local content_lines = cb:build_lines()
  local content_highlights = cb:build_highlights()

  for _, line in ipairs(content_lines) do
    table.insert(all_lines, line)
  end
  for _, hl in ipairs(content_highlights) do
    table.insert(all_highlights, {
      line = hl.line + line_offset,
      col_start = hl.col_start,
      col_end = hl.col_end,
      hl_group = hl.hl_group,
    })
  end

  return all_lines, all_highlights
end

return M
