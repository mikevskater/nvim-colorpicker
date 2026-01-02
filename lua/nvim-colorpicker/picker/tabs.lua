---@module 'nvim-colorpicker.picker.tabs'
---@brief Tab system for the color picker right panel

local State = require('nvim-colorpicker.picker.state')
local ContentBuilder = require('nvim-float.content_builder')

local M = {}

-- ============================================================================
-- Constants
-- ============================================================================

---@type string[] Available tab names
M.TAB_NAMES = { "info", "history", "presets" }

---@type table<string, string> Tab display labels
M.TAB_LABELS = {
  info = "Info",
  history = "History",
  presets = "Presets",
}

-- ============================================================================
-- Tab State Accessors
-- ============================================================================

---Get the current active tab
---@return string tab_name The active tab name
function M.get_current_tab()
  local state = State.state
  if not state or not state.active_tab then
    return "info"
  end
  return state.active_tab
end

---Check if a tab is the active tab
---@param tab_name string The tab name to check
---@return boolean is_active
function M.is_active_tab(tab_name)
  return M.get_current_tab() == tab_name
end

---Get the index of a tab
---@param tab_name string The tab name
---@return number index The 1-based index
function M.get_tab_index(tab_name)
  for i, name in ipairs(M.TAB_NAMES) do
    if name == tab_name then
      return i
    end
  end
  return 1
end

---Get tab name by index
---@param index number The 1-based index
---@return string tab_name
function M.get_tab_by_index(index)
  return M.TAB_NAMES[index] or "info"
end

-- ============================================================================
-- Tab Switching
-- ============================================================================

---Switch to a specific tab
---@param tab_name string The tab to switch to
---@param schedule_render fun() Function to trigger a re-render
function M.switch_tab(tab_name, schedule_render)
  local state = State.state
  if not state then return end

  -- Validate tab name
  local valid = false
  for _, name in ipairs(M.TAB_NAMES) do
    if name == tab_name then
      valid = true
      break
    end
  end

  if not valid then return end

  -- Don't switch if already on this tab
  if state.active_tab == tab_name then return end

  -- Set new tab
  state.active_tab = tab_name

  -- Reset tab-specific cursor positions
  if tab_name == "history" then
    state.history_cursor = state.history_cursor or 1
  elseif tab_name == "presets" then
    state.presets_cursor = state.presets_cursor or 1
  end

  schedule_render()
end

---Switch to the next tab
---@param schedule_render fun() Function to trigger a re-render
function M.next_tab(schedule_render)
  local current_index = M.get_tab_index(M.get_current_tab())
  local next_index = current_index + 1
  if next_index > #M.TAB_NAMES then
    next_index = 1
  end
  M.switch_tab(M.TAB_NAMES[next_index], schedule_render)
end

---Switch to the previous tab
---@param schedule_render fun() Function to trigger a re-render
function M.prev_tab(schedule_render)
  local current_index = M.get_tab_index(M.get_current_tab())
  local prev_index = current_index - 1
  if prev_index < 1 then
    prev_index = #M.TAB_NAMES
  end
  M.switch_tab(M.TAB_NAMES[prev_index], schedule_render)
end

-- ============================================================================
-- Tab Bar Rendering
-- ============================================================================

---Render the tab bar to an existing ContentBuilder
---@param cb ContentBuilder The content builder to add to
function M.render_tab_bar_to(cb)
  local active_tab = M.get_current_tab()

  -- Build tab bar spans
  local spans = {}

  for i, tab_name in ipairs(M.TAB_NAMES) do
    local label = M.TAB_LABELS[tab_name]
    local is_active = tab_name == active_tab

    -- Add separator before non-first tabs
    if i > 1 then
      table.insert(spans, { text = " │ ", style = "muted" })
    end

    -- Add tab label with appropriate style
    if is_active then
      table.insert(spans, { text = "[" .. label .. "]", style = "emphasis" })
    else
      table.insert(spans, { text = label, style = "muted" })
    end
  end

  cb:blank()
  cb:spans(spans)
  cb:styled("  " .. string.rep("─", 18), "muted")
end

---Render the tab bar (legacy - returns lines/highlights)
---@return string[] lines The rendered lines
---@return table[] highlights The highlight definitions
function M.render_tab_bar()
  local cb = ContentBuilder.new()
  M.render_tab_bar_to(cb)
  return cb:build_lines(), cb:build_highlights()
end

---Get the panel title based on active tab (for focus indicator)
---@param is_focused boolean Whether the panel is focused
---@return string title The panel title
function M.get_panel_title(is_focused)
  local active_tab = M.get_current_tab()
  local label = M.TAB_LABELS[active_tab] or "Info"
  if is_focused then
    return label .. " *"
  end
  return label
end

return M
