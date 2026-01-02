---@module 'nvim-colorpicker.picker.info_tab'
---@brief Info tab rendering for the color picker (display only, no inline editing)

local State = require('nvim-colorpicker.picker.state')
local ColorUtils = require('nvim-colorpicker.color')
local Format = require('nvim-colorpicker.picker.format')
local Slider = require('nvim-colorpicker.picker.slider')
local ContentBuilder = require('nvim-float.content_builder')

local M = {}

-- Store ContentBuilder for element tracking
M._content_builder = nil

-- ============================================================================
-- Info Tab Content Rendering
-- ============================================================================

---Render the info tab content to existing ContentBuilder
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

  -- Render sliders (element tracking handles hover highlighting)
  local components = Slider.get_components(state.color_mode, state.alpha_enabled)
  local values = Slider.get_component_values(current_hex, state.color_mode, state.alpha)

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

    -- Track slider row as interactive element (hover_style handles highlighting)
    cb:spans({
      {
        text = "  " .. comp.label .. ": ",
        style = "label",
        track = {
          name = "slider_" .. comp.key,
          type = "action",
          row_based = true,
          hover_style = "emphasis",
          data = {
            slider_index = i,
            component = comp,
          },
        },
      },
      { text = slider_str, style = "value" },
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
---Uses single ContentBuilder so element positions match buffer positions
---@param multi_state MultiPanelState
---@return string[] lines
---@return table[] highlights
function M.render_info_panel(multi_state)
  local state = State.state
  if not state then return {}, {} end

  local Tabs = require('nvim-colorpicker.picker.tabs')

  -- Single ContentBuilder for everything - element positions are correct
  local cb = ContentBuilder.new()

  -- Add tab bar first
  Tabs.render_tab_bar_to(cb)

  -- Add info content
  M.render_info_content(cb)

  -- Store ContentBuilder for element tracking
  M._content_builder = cb

  return cb:build_lines(), cb:build_highlights()
end

---Get the stored ContentBuilder (for element tracking integration)
---@return ContentBuilder?
function M.get_content_builder()
  return M._content_builder
end

-- ============================================================================
-- Element-Based Slider Actions
-- ============================================================================

---Adjust slider value based on element at cursor
---@param element table The element at cursor (from get_element_at_cursor)
---@param delta number Amount to adjust (+1 or -1)
---@param schedule_render fun() Function to trigger re-render
function M.adjust_slider_element(element, delta, schedule_render)
  local state = State.state
  if not state then return end

  if not element or not element.data or not element.data.slider_index then
    return
  end

  local slider_index = element.data.slider_index
  Slider.adjust_component(slider_index, delta, schedule_render)
end

---Get slider index from element (for visual highlighting)
---@param element table? The element at cursor
---@return number? slider_index
function M.get_slider_index_from_element(element)
  if element and element.data and element.data.slider_index then
    return element.data.slider_index
  end
  return nil
end

return M
