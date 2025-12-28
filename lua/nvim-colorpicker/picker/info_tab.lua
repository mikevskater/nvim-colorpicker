---@module 'nvim-colorpicker.picker.info_tab'
---@brief Info tab rendering for the color picker (display only, no inline editing)

local State = require('nvim-colorpicker.picker.state')
local ColorUtils = require('nvim-colorpicker.color')
local Format = require('nvim-colorpicker.picker.format')
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

  cb:blank()

  cb:styled("  " .. string.rep("─", 16), "muted")

  cb:blank()

  local components = ColorUtils.get_color_components(current_hex, state.color_mode)
  for _, comp in ipairs(components) do
    local formatted = ColorUtils.format_value(comp.value, comp.unit, state.value_format)
    cb:spans({
      { text = "  " .. comp.label .. ": ", style = "label" },
      { text = formatted, style = "value" },
    })
  end

  if state.alpha_enabled and state.color_mode ~= "cmyk" then
    cb:blank()
    local alpha_formatted = ColorUtils.format_value(state.alpha, "pct", state.value_format)
    cb:spans({
      { text = "  A: ", style = "label" },
      { text = alpha_formatted, style = "value" },
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
