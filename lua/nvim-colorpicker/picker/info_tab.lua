---@module 'nvim-colorpicker.picker.info_tab'
---@brief Info tab rendering for the color picker with embedded containers

local State = require('nvim-colorpicker.picker.state')
local ColorUtils = require('nvim-colorpicker.color')
local Format = require('nvim-colorpicker.picker.format')
local Slider = require('nvim-colorpicker.picker.slider')
local ContentBuilder = require('nvim-float.content')

local M = {}

-- Store ContentBuilder for element tracking
M._content_builder = nil

-- ============================================================================
-- Info Tab Content Rendering
-- ============================================================================

---Render the info tab content to existing ContentBuilder with embedded containers
---@param cb ContentBuilder The content builder to add content to
function M.render_info_content(cb)
  local state = State.state
  if not state then return end

  local current_hex = State.get_active_color()

  -- Helper: trigger full picker re-render via stored schedule_render
  local function trigger_render()
    if state._schedule_render then
      state._schedule_render()
    end
  end

  cb:blank()

  -- Mode selector (embedded dropdown)
  local mode_options = {
    { value = "hsl", label = "HSL" },
    { value = "rgb", label = "RGB" },
    { value = "hsv", label = "HSV" },
    { value = "cmyk", label = "CMYK" },
  }
  cb:embedded_dropdown("color_mode", {
    label = "  Mode",
    options = mode_options,
    selected = state.color_mode,
    width = 8,
    on_change = function(_, v)
      state.color_mode = v
      trigger_render()
    end,
  })

  cb:blank()

  -- Hex value (embedded input for direct entry)
  local hex_display = Format.get_hex_display(current_hex, state.alpha, state.alpha_enabled, state.color_mode)
  cb:embedded_input("hex_value", {
    label = "  Hex ",
    value = hex_display,
    width = 10,
    on_submit = function(_, v)
      local hex = v
      if not hex:match("^#") then hex = "#" .. hex end
      local normalized = ColorUtils.normalize_hex(hex)
      if normalized then
        State.set_active_color(normalized)
        trigger_render()
      end
    end,
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

  -- Render sliders with embedded inputs for direct value entry
  local components = Slider.get_components(state.color_mode, state.alpha_enabled)
  local values = Slider.get_component_values(current_hex, state.color_mode, state.alpha)

  for i, comp in ipairs(components) do
    local value = values[comp.key] or 0
    local slider_str = Slider.render_slider(value, comp.min, comp.max, 14)
    local formatted = ColorUtils.format_value(value, comp.unit, state.value_format)

    -- Slider bar as text + embedded input for the numeric value
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
    })
    cb:embedded_input("slider_" .. comp.key, {
      label = "       ",
      value = formatted,
      width = 6,
      on_submit = function(_, v)
        local num = tonumber(v:gsub("[°%%]", ""))
        if num then
          num = math.max(comp.min, math.min(comp.max, num))
          if comp.key == "a" then
            state.alpha = num
          else
            local current_values = Slider.get_component_values(State.get_active_color(), state.color_mode, state.alpha)
            current_values[comp.key] = num
            local new_hex = ColorUtils.components_to_hex(current_values, state.color_mode)
            State.set_active_color(new_hex)
          end
          trigger_render()
        end
      end,
    })
  end

  cb:blank()

  cb:styled("  " .. string.rep("─", 16), "muted")

  cb:blank()

  -- Format selector (embedded dropdown)
  cb:embedded_dropdown("value_format", {
    label = "  Format",
    options = {
      { value = "standard", label = "Standard" },
      { value = "decimal", label = "Decimal" },
    },
    selected = state.value_format,
    width = 12,
    on_change = function(_, v)
      state.value_format = v
      trigger_render()
    end,
  })

  cb:blank()

  -- Step size display (keep as text with key shortcuts)
  cb:spans({
    { text = "  Step: ", style = "label" },
    { text = State.get_step_label(), style = "value" },
    { text = "  -/+", style = "key" },
  })

  -- Custom controls
  if state.options.custom_controls and #state.options.custom_controls > 0 then
    cb:blank()
    cb:styled("  " .. string.rep("─", 16), "muted")
    cb:blank()
    cb:styled("  Options", "header")

    for _, control in ipairs(state.options.custom_controls) do
      local ctrl_value = state.custom_values[control.id]

      if control.type == "toggle" then
        cb:embedded_dropdown("custom_" .. control.id, {
          label = "  " .. control.label,
          options = {
            { value = "on", label = "On" },
            { value = "off", label = "Off" },
          },
          selected = ctrl_value and "on" or "off",
          width = 6,
          on_change = function(_, v)
            state.custom_values[control.id] = (v == "on")
            trigger_render()
          end,
        })
      elseif control.type == "select" then
        local select_options = {}
        for _, opt in ipairs(control.options or {}) do
          if type(opt) == "table" then
            table.insert(select_options, opt)
          else
            table.insert(select_options, { value = tostring(opt), label = tostring(opt) })
          end
        end
        cb:embedded_dropdown("custom_" .. control.id, {
          label = "  " .. control.label,
          options = select_options,
          selected = tostring(ctrl_value),
          width = 15,
          on_change = function(_, v)
            state.custom_values[control.id] = v
            trigger_render()
          end,
        })
      elseif control.type == "number" then
        cb:embedded_input("custom_" .. control.id, {
          label = "  " .. control.label,
          value = tostring(ctrl_value or 0),
          width = 6,
          on_submit = function(_, v)
            local num = tonumber(v)
            if num then
              state.custom_values[control.id] = num
              trigger_render()
            end
          end,
        })
      elseif control.type == "text" then
        cb:embedded_input("custom_" .. control.id, {
          label = "  " .. control.label,
          value = tostring(ctrl_value or ""),
          width = 20,
          on_submit = function(_, v)
            state.custom_values[control.id] = v
            trigger_render()
          end,
        })
      end
    end
  end
end

-- ============================================================================
-- Full Panel Rendering (with tab bar)
-- ============================================================================

---Render the complete info panel (tab bar + info content with embedded containers)
---Returns ContentBuilder so multi-panel can create embedded containers
---@param multi_state MultiPanelState
---@return ContentBuilder cb
function M.render_info_panel(multi_state)
  local state = State.state
  if not state then
    local cb = ContentBuilder.new()
    return cb
  end

  local Tabs = require('nvim-colorpicker.picker.tabs')

  -- Single ContentBuilder for everything - element positions are correct
  local cb = ContentBuilder.new()

  -- Add tab bar first
  Tabs.render_tab_bar_to(cb)

  -- Add info content with embedded containers
  M.render_info_content(cb)

  -- Store ContentBuilder for element tracking
  M._content_builder = cb

  return cb
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
