---@module 'nvim-colorpicker.picker.info_tab'
---@brief Info tab rendering for the color picker (display only, no inline editing)

local State = require('nvim-colorpicker.picker.state')
local ColorUtils = require('nvim-colorpicker.color')
local Format = require('nvim-colorpicker.picker.format')
local Slider = require('nvim-colorpicker.picker.slider')
local ContentBuilder = require('nvim-float.content_builder')

local M = {}

-- ============================================================================
-- Info Tab Content Rendering
-- ============================================================================

---Render the info tab content (without tab bar - pure content only)
---@param cb ContentBuilder The content builder to add content to
function M.render_info_content(cb)
  local state = State.state
  if not state then return end

  local current_hex = State.get_active_color()

  cb:blank()
  cb:spans({
    { text = "  Mode: ", style = "label" },
    { text = "[" .. state.color_mode:upper() .. "]", style = "value" },
    { text = "  m", style = "key" },
  })

  cb:blank()

  local hex_display = Format.get_hex_display(current_hex, state.alpha, state.alpha_enabled, state.color_mode)
  cb:spans({
    { text = "  Hex: ", style = "label" },
    { text = hex_display, style = "value" },
    { text = "  #", style = "key" },
  })

  -- Show filetype-formatted output if we have an adapter
  if state._adapter then
    cb:blank()
    local output = State.get_formatted_output()
    local format_name = State.get_output_format()
    cb:spans({
      { text = "  Out: ", style = "label" },
      { text = output, style = "emphasis" },
    })
    cb:spans({
      { text = "       [", style = "muted" },
      { text = format_name, style = "value" },
      { text = "]", style = "muted" },
      { text = "  o", style = "key" },
    })
  end

  cb:blank()

  cb:styled("  " .. string.rep("─", 16), "muted")

  cb:blank()

  -- Render sliders instead of static values
  local components = Slider.get_components(state.color_mode, state.alpha_enabled)
  local values = Slider.get_component_values(current_hex, state.color_mode, state.alpha)
  local slider_focus = state.slider_focus or 1

  -- Track the content line where sliders start (will be adjusted by tab bar offset later)
  -- Content lines before sliders: blank(1) + Mode(1) + blank(1) + Hex(1) = 4
  -- If adapter present: + blank(1) + Out(1) + format_line(1) = 7
  -- Then: + blank(1) + sep(1) + blank(1) = 10 (with adapter) or 7 (without)
  local base_offset = 4
  if state._adapter then
    base_offset = base_offset + 3  -- blank + Out + format_line
  end
  base_offset = base_offset + 3  -- blank + sep + blank
  M._slider_content_offset = base_offset

  -- Helper to pad based on display width (handles multi-byte chars like °)
  local function pad_display(str, width)
    local display_width = vim.fn.strdisplaywidth(str)
    local padding = math.max(0, width - display_width)
    return string.rep(" ", padding) .. str
  end

  for i, comp in ipairs(components) do
    local value = values[comp.key] or 0
    local slider_str = Slider.render_slider(value, comp.min, comp.max, 14)
    local formatted = ColorUtils.format_value(value, comp.unit, state.value_format)
    local value_padded = pad_display(formatted, 5)

    -- Highlight focused slider
    local is_focused = (i == slider_focus) and state.focused_panel == "info"
    local label_style = is_focused and "emphasis" or "label"
    local slider_style = is_focused and "emphasis" or "value"

    cb:spans({
      { text = "  " .. comp.label .. ": ", style = label_style },
      { text = slider_str, style = slider_style },
      { text = " " .. value_padded, style = "value" },
    })
  end

  cb:blank()

  cb:styled("  " .. string.rep("─", 16), "muted")

  cb:blank()

  local format_label = state.value_format == "standard" and "Standard" or "Decimal"
  cb:spans({
    { text = "  Format: ", style = "label" },
    { text = format_label, style = "value" },
    { text = "  f", style = "key" },
  })

  cb:blank()

  cb:spans({
    { text = "  Step: ", style = "label" },
    { text = State.get_step_label(), style = "value" },
    { text = "  -/+", style = "key" },
  })

  if state.options.custom_controls and #state.options.custom_controls > 0 then
    cb:blank()
    cb:styled("  " .. string.rep("─", 16), "muted")
    cb:blank()
    cb:styled("  Options", "header")

    for _, control in ipairs(state.options.custom_controls) do
      local value = state.custom_values[control.id]
      local key_hint = control.key and ("  " .. control.key) or ""
      if control.type == "toggle" then
        local indicator = value and "[x]" or "[ ]"
        cb:spans({
          { text = "  " .. indicator .. " " .. control.label, style = value and "emphasis" or "muted" },
          { text = key_hint, style = "key" },
        })
      elseif control.type == "select" then
        cb:spans({
          { text = "  " .. control.label .. ": ", style = "label" },
          { text = tostring(value), style = "value" },
          { text = key_hint, style = "key" },
        })
      elseif control.type == "number" then
        cb:spans({
          { text = "  " .. control.label .. ": ", style = "label" },
          { text = tostring(value), style = "value" },
          { text = key_hint, style = "key" },
        })
      elseif control.type == "text" then
        cb:spans({
          { text = "  " .. control.label .. ": ", style = "label" },
          { text = tostring(value), style = "value" },
          { text = key_hint, style = "key" },
        })
      end
    end
  end
end

-- ============================================================================
-- Full Panel Rendering (with tab bar)
-- ============================================================================

---Render the complete info panel (tab bar + info content)
---Called when info tab is active
---@param multi_state MultiPanelState
---@return string[] lines
---@return table[] highlights
function M.render_info_panel(multi_state)
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

  -- Add info content
  local cb = ContentBuilder.new()
  M.render_info_content(cb)

  -- Calculate slider start line: tab_bar_lines + content_offset
  -- Cursor is 1-indexed, so first slider at line (line_offset + _slider_content_offset + 1)
  -- For get_slider_from_cursor: slider_line = cursor - _slider_start_line, should give 1 for first slider
  -- So _slider_start_line = line_offset + _slider_content_offset
  M._slider_start_line = line_offset + (M._slider_content_offset or 7)

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

-- ============================================================================
-- Slider Cursor Tracking
-- ============================================================================

-- Line offset where sliders start (set during render)
M._slider_start_line = 10  -- Default, updated during render
M._slider_content_offset = 7  -- Lines in content before first slider

---Get the slider index from cursor position
---@param cursor_line number 1-indexed cursor line
---@return number? slider_index 1-indexed slider index, or nil if not on a slider
function M.get_slider_from_cursor(cursor_line)
  local state = State.state
  if not state then return nil end

  local components = Slider.get_components(state.color_mode, state.alpha_enabled)
  local slider_count = #components

  -- Calculate which slider the cursor is on
  local slider_line = cursor_line - M._slider_start_line
  if slider_line >= 1 and slider_line <= slider_count then
    return slider_line
  end

  return nil
end

---Called when cursor moves in info panel
function M.on_cursor_moved()
  local state = State.state
  if not state or state.active_tab ~= "info" then return end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1]

  local slider_idx = M.get_slider_from_cursor(line)
  if slider_idx then
    state.slider_focus = slider_idx
  end
end

---Get the line number for a slider index
---@param slider_index number 1-indexed slider index
---@return number line 1-indexed line number
function M.get_line_for_slider(slider_index)
  return M._slider_start_line + slider_index - 1
end

---Restore cursor to the focused slider
---@param win number Window handle
function M.restore_cursor(win)
  local state = State.state
  if not state or not win or not vim.api.nvim_win_is_valid(win) then return end

  local slider_focus = state.slider_focus or 1
  local line = M.get_line_for_slider(slider_focus)

  pcall(vim.api.nvim_win_set_cursor, win, { line, 0 })
end

return M
