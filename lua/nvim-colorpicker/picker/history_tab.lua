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

---@type string Swatch characters (same block char as grid, multiple wide)
local SWATCH_TEXT = "█████"

-- ============================================================================
-- Extmark Namespace
-- ============================================================================

---@type number Namespace for swatch extmarks
local ns = vim.api.nvim_create_namespace('nvim_colorpicker_history_swatches')

---@type table[] Pending extmarks to apply after render
local pending_extmarks = {}

-- ============================================================================
-- History Highlight Management
-- ============================================================================

---@type table<string, boolean> Cache of created highlight groups
local created_highlights = {}

---Get or create a highlight group for a color swatch
---@param hex string The hex color
---@return string hl_group The highlight group name
local function get_swatch_highlight(hex)
  -- Normalize hex to ensure consistent format
  hex = ColorUtils.normalize_hex(hex)
  local hl_name = "NvimColorPickerHistory_" .. hex:gsub("#", "")

  -- Only create if not already cached
  if not created_highlights[hl_name] then
    -- Use fg color for block chars (VHS compatible)
    -- Note: bg would fill entire row, so we only use fg
    vim.api.nvim_set_hl(0, hl_name, { fg = hex })
    created_highlights[hl_name] = true
  end

  return hl_name
end

-- ============================================================================
-- Cursor Management
-- ============================================================================

---Calculate header line offset (tab bar + content header)
---@return number offset Lines before first history item
local function get_header_offset()
  -- Tab bar: 3 lines (blank + tab labels + separator)
  -- Content: 1 blank line + "Recent (N)" header + 1 blank line = 3 lines
  return 3 + 3  -- 6 total lines before first item
end

---Handle CursorMoved event - sync history_cursor from buffer cursor
---No re-render needed - cursor position IS the selection indicator
function M.on_cursor_moved()
  local state = State.state
  if not state then return end

  -- Only handle when history tab is active
  if state.active_tab ~= "history" then return end

  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local header_offset = get_header_offset()
  local history = History.get_recent(MAX_DISPLAY_ITEMS)

  -- Calculate item index from cursor line
  local item_idx = cursor_line - header_offset

  -- Clamp to valid range
  if item_idx < 1 then
    item_idx = 1
  elseif item_idx > #history then
    item_idx = #history
  end

  -- Just update state - no re-render (cursor is the visual indicator)
  if #history > 0 then
    state.history_cursor = item_idx
  end
end

---Restore cursor position from saved state when switching to history tab
---@param winid number Window ID of the info panel
function M.restore_cursor(winid)
  local state = State.state
  if not state then return end
  if not winid or not vim.api.nvim_win_is_valid(winid) then return end

  local history = History.get_recent(MAX_DISPLAY_ITEMS)
  if #history == 0 then return end

  -- Clamp cursor to valid range
  local cursor_idx = state.history_cursor or 1
  if cursor_idx < 1 then cursor_idx = 1 end
  if cursor_idx > #history then cursor_idx = #history end
  state.history_cursor = cursor_idx

  -- Calculate target line: header_offset + cursor_index
  local target_line = get_header_offset() + cursor_idx

  -- Set cursor position (line, col) - col 0 for start of line
  pcall(vim.api.nvim_win_set_cursor, winid, { target_line, 0 })
end

-- ============================================================================
-- History Navigation (for programmatic use)
-- ============================================================================

---Select the currently highlighted history item
---@param schedule_render fun() Function to trigger re-render
function M.select_current(schedule_render)
  local state = State.state
  if not state then return end

  local history = History.get_recent(MAX_DISPLAY_ITEMS)
  if #history == 0 then return end

  local selected_item = history[state.history_cursor]
  if selected_item then
    State.set_active_color(selected_item.hex)

    -- Restore alpha from history
    if selected_item.alpha then
      state.alpha = selected_item.alpha
    end

    -- Restore color mode from history (only if not locked by forced_mode)
    if selected_item.format and not state.options.forced_mode then
      state.color_mode = selected_item.format
    end

    -- Update saved HSL for proper grid navigation
    local h, s, _ = ColorUtils.hex_to_hsl(selected_item.hex)
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

  -- Get the item to delete
  local to_delete = history[state.history_cursor]
  if not to_delete then return end

  -- Get all colors and remove the selected one (compare by hex)
  local all_colors = History.get_recent()
  local new_colors = {}
  for _, item in ipairs(all_colors) do
    if item.hex ~= to_delete.hex then
      table.insert(new_colors, item)
    end
  end

  -- Clear and re-add remaining colors (in reverse to maintain order)
  History.clear_recent()
  for i = #new_colors, 1, -1 do
    History.add_recent(new_colors[i].hex, new_colors[i].alpha, new_colors[i].format)
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

  -- Track line index for extmarks (starts after tab bar: 3 lines)
  local line_idx = 3

  cb:blank()
  line_idx = line_idx + 1

  if #history == 0 then
    cb:styled("  No recent colors", "muted")
    cb:blank()
    cb:styled("  Pick colors to add", "muted")
    cb:styled("  them to history.", "muted")
  else
    cb:styled(string.format("  Recent (%d)", #history), "header")
    line_idx = line_idx + 1
    cb:blank()
    line_idx = line_idx + 1

    -- Clear pending extmarks
    pending_extmarks = {}

    -- Pre-calculate display hex values and find max length for alignment
    local display_items = {}
    local max_hex_len = 0
    for _, item in ipairs(history) do
      local display_hex = item.hex
      if item.alpha and item.alpha < 100 then
        local alpha_byte = math.floor((item.alpha / 100) * 255 + 0.5)
        display_hex = item.hex .. string.format("%02X", alpha_byte)
      end
      table.insert(display_items, display_hex)
      max_hex_len = math.max(max_hex_len, #display_hex)
    end

    -- Render all items - cursor position is the selection indicator
    for i, item in ipairs(history) do
      -- Pad hex to align swatches
      local display_hex = display_items[i]
      local padded_hex = display_hex .. string.rep(" ", max_hex_len - #display_hex)

      -- Format indicator (show if not hex)
      local format_indicator = ""
      if item.format and item.format ~= "hex" then
        format_indicator = " [" .. item.format:upper() .. "]"
      end

      cb:spans({
        { text = "  ", style = "normal" },
        { text = string.format("%2d ", i), style = "value" },
        { text = padded_hex, style = "value" },
        { text = format_indicator, style = "muted" },
      })

      -- Store extmark data for this line
      table.insert(pending_extmarks, {
        line = line_idx,
        hex = item.hex,
      })
      line_idx = line_idx + 1
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

  -- Add history content (swatch highlights are inline via cb:spans with hl_group)
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

---Apply swatch extmarks to the info panel buffer
---Called after the buffer content is set to add virtual text swatches
---@param bufnr number The buffer number to apply extmarks to
function M.apply_swatch_extmarks(bufnr)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then return end

  -- Clear previous extmarks
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  -- Apply pending extmarks as virtual text (cursor-highlight resistant)
  for _, extmark in ipairs(pending_extmarks) do
    local hl_name = get_swatch_highlight(extmark.hex)

    vim.api.nvim_buf_set_extmark(bufnr, ns, extmark.line, 0, {
      virt_text = { { " " .. SWATCH_TEXT, hl_name } },
      virt_text_pos = "eol",  -- End of line
    })
  end
end

---Clear swatch extmarks from buffer
---@param bufnr number The buffer number
function M.clear_swatch_extmarks(bufnr)
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  end
end

return M
