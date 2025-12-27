---@module 'nvim-colorpicker.picker.info_panel'
---@brief Info panel rendering and input handling for the color picker

local State = require('nvim-colorpicker.picker.state')
local ColorUtils = require('nvim-colorpicker.color')
local ContentBuilder = require('nvim-float.content_builder')
local InputManager = require('nvim-float.input_manager')

local M = {}

-- ============================================================================
-- Info Panel Rendering
-- ============================================================================

---Render the info panel content using ContentBuilder with interactive inputs
---@param multi_state MultiPanelState
---@return string[] lines
---@return table[] highlights
function M.render_info_panel(multi_state)
  local state = State.state
  if not state then return {}, {} end

  local cb = ContentBuilder.new()

  local current_hex = State.get_active_color()

  cb:blank()
  cb:spans({
    { text = "  Mode: ", style = "label" },
    { text = "[" .. state.color_mode:upper() .. "]", style = "value" },
    { text = "  m", style = "key" },
  })

  cb:blank()

  local hex_display = current_hex
  if state.alpha_enabled and state.color_mode ~= "cmyk" then
    local alpha_byte = math.floor((state.alpha / 100) * 255 + 0.5)
    hex_display = current_hex .. string.format("%02X", alpha_byte)
  end
  cb:input("hex", {
    label = "  Hex",
    value = hex_display,
    width = 10,
    placeholder = "#000000",
  })

  cb:blank()

  cb:styled("  " .. string.rep("─", 16), "muted")

  cb:blank()

  local components = ColorUtils.get_color_components(current_hex, state.color_mode)
  for _, comp in ipairs(components) do
    local formatted = ColorUtils.format_value(comp.value, comp.unit, state.value_format)
    local input_key = "comp_" .. comp.label:lower()
    cb:input(input_key, {
      label = "  " .. comp.label,
      value = formatted,
      width = 8,
      placeholder = "0",
    })
  end

  if state.alpha_enabled and state.color_mode ~= "cmyk" then
    cb:blank()
    local alpha_formatted = ColorUtils.format_value(state.alpha, "pct", state.value_format)
    cb:input("alpha", {
      label = "  A",
      value = alpha_formatted,
      width = 8,
      placeholder = "100%",
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

  state._info_panel_cb = cb

  return cb:build_lines(), cb:build_highlights()
end

-- ============================================================================
-- Input Validation
-- ============================================================================

---Get validation settings for color picker inputs based on current mode
---@return table<string, table> settings_map Map of input key -> validation settings
function M.get_input_validation_settings()
  local state = State.state
  if not state then return {} end

  local settings = {}

  settings["hex"] = {
    value_type = "text",
    input_pattern = "[%x#]",
  }

  if state.alpha_enabled then
    if state.value_format == "decimal" then
      settings["alpha"] = {
        value_type = "float",
        min_value = 0,
        max_value = 1,
        allow_negative = false,
      }
    else
      settings["alpha"] = {
        value_type = "integer",
        min_value = 0,
        max_value = 100,
        allow_negative = false,
      }
    end
  end

  if state.color_mode == "hsl" then
    if state.value_format == "decimal" then
      settings["comp_h"] = { value_type = "float", min_value = 0, max_value = 1, allow_negative = false }
      settings["comp_s"] = { value_type = "float", min_value = 0, max_value = 1, allow_negative = false }
      settings["comp_l"] = { value_type = "float", min_value = 0, max_value = 1, allow_negative = false }
    else
      settings["comp_h"] = { value_type = "integer", min_value = 0, max_value = 360, allow_negative = false }
      settings["comp_s"] = { value_type = "integer", min_value = 0, max_value = 100, allow_negative = false }
      settings["comp_l"] = { value_type = "integer", min_value = 0, max_value = 100, allow_negative = false }
    end
  elseif state.color_mode == "rgb" then
    if state.value_format == "decimal" then
      settings["comp_r"] = { value_type = "float", min_value = 0, max_value = 1, allow_negative = false }
      settings["comp_g"] = { value_type = "float", min_value = 0, max_value = 1, allow_negative = false }
      settings["comp_b"] = { value_type = "float", min_value = 0, max_value = 1, allow_negative = false }
    else
      settings["comp_r"] = { value_type = "integer", min_value = 0, max_value = 255, allow_negative = false }
      settings["comp_g"] = { value_type = "integer", min_value = 0, max_value = 255, allow_negative = false }
      settings["comp_b"] = { value_type = "integer", min_value = 0, max_value = 255, allow_negative = false }
    end
  elseif state.color_mode == "hsv" then
    if state.value_format == "decimal" then
      settings["comp_h"] = { value_type = "float", min_value = 0, max_value = 1, allow_negative = false }
      settings["comp_s"] = { value_type = "float", min_value = 0, max_value = 1, allow_negative = false }
      settings["comp_v"] = { value_type = "float", min_value = 0, max_value = 1, allow_negative = false }
    else
      settings["comp_h"] = { value_type = "integer", min_value = 0, max_value = 360, allow_negative = false }
      settings["comp_s"] = { value_type = "integer", min_value = 0, max_value = 100, allow_negative = false }
      settings["comp_v"] = { value_type = "integer", min_value = 0, max_value = 100, allow_negative = false }
    end
  elseif state.color_mode == "cmyk" then
    if state.value_format == "decimal" then
      settings["comp_c"] = { value_type = "float", min_value = 0, max_value = 1, allow_negative = false }
      settings["comp_m"] = { value_type = "float", min_value = 0, max_value = 1, allow_negative = false }
      settings["comp_y"] = { value_type = "float", min_value = 0, max_value = 1, allow_negative = false }
      settings["comp_k"] = { value_type = "float", min_value = 0, max_value = 1, allow_negative = false }
    else
      settings["comp_c"] = { value_type = "integer", min_value = 0, max_value = 100, allow_negative = false }
      settings["comp_m"] = { value_type = "integer", min_value = 0, max_value = 100, allow_negative = false }
      settings["comp_y"] = { value_type = "integer", min_value = 0, max_value = 100, allow_negative = false }
      settings["comp_k"] = { value_type = "integer", min_value = 0, max_value = 100, allow_negative = false }
    end
  end

  return settings
end

---Update InputManager validation settings
function M.update_input_validation_settings()
  local state = State.state
  if not state or not state._info_input_manager then return end
  local settings = M.get_input_validation_settings()
  state._info_input_manager:update_all_input_settings(settings)
end

-- ============================================================================
-- Input Parsing Helpers
-- ============================================================================

---Extract numeric value from a string
---@param str string The input string
---@return number|nil value The extracted number, or nil if no valid number found
function M.extract_number(str)
  if not str or str == "" then return nil end
  local num_str = str:match("%-?%d+%.?%d*")
  if not num_str or num_str == "" or num_str == "-" or num_str == "." then
    return nil
  end
  return tonumber(num_str)
end

---Extract hex digits from a string
---@param str string The input string
---@return string|nil hex_digits Only the hex digit characters, or nil if none found
function M.extract_hex_digits(str)
  if not str or str == "" then return nil end
  local cleaned = str:gsub("^#", "")
  local hex_only = cleaned:gsub("[^%x]", "")
  if hex_only == "" then return nil end
  return hex_only
end

-- ============================================================================
-- Input Commit Handling
-- ============================================================================

---Handle input commit from the info panel
---@param key string Input field key
---@param value string The committed input value
---@param schedule_render fun() Function to schedule a render
function M.handle_input_commit(key, value, schedule_render)
  local state = State.state
  if not state then return end

  value = value:gsub("^%s+", ""):gsub("%s+$", "")
  if value == "" then return end

  if key == "hex" then
    local hex_digits = M.extract_hex_digits(value)
    if not hex_digits then return end

    if #hex_digits >= 6 then
      local color_hex = "#" .. hex_digits:sub(1, 6):upper()
      if ColorUtils.is_valid_hex(color_hex) then
        State.set_active_color(color_hex)

        if #hex_digits >= 8 and state.alpha_enabled then
          local alpha_hex = hex_digits:sub(7, 8)
          local alpha_byte = tonumber(alpha_hex, 16)
          if alpha_byte then
            state.alpha = (alpha_byte / 255) * 100
          end
        end
        schedule_render()
      end
    end
  elseif key == "alpha" then
    local num = M.extract_number(value)
    if num and state.alpha_enabled then
      if state.value_format == "decimal" and num >= 0 and num <= 1 then
        state.alpha = num * 100
      else
        state.alpha = math.max(0, math.min(100, num))
      end
      schedule_render()
    end
  elseif key:match("^comp_") then
    local comp_name = key:gsub("^comp_", ""):upper()
    local current_hex = State.get_active_color()

    local num = M.extract_number(value)
    if not num then return end

    if state.value_format == "decimal" and num >= 0 and num <= 1 then
      if comp_name == "H" then
        num = num * 360
      elseif state.color_mode == "rgb" then
        num = num * 255
      else
        num = num * 100
      end
    end

    local new_hex = nil
    if state.color_mode == "hsl" then
      local h, s, l = ColorUtils.hex_to_hsl(current_hex)
      if comp_name == "H" then
        h = math.max(0, math.min(360, num))
      elseif comp_name == "S" then
        s = math.max(0, math.min(100, num))
      elseif comp_name == "L" then
        l = math.max(0, math.min(100, num))
      end
      new_hex = ColorUtils.hsl_to_hex(h, s, l)
    elseif state.color_mode == "rgb" then
      local r, g, b = ColorUtils.hex_to_rgb(current_hex)
      if comp_name == "R" then
        r = math.max(0, math.min(255, math.floor(num + 0.5)))
      elseif comp_name == "G" then
        g = math.max(0, math.min(255, math.floor(num + 0.5)))
      elseif comp_name == "B" then
        b = math.max(0, math.min(255, math.floor(num + 0.5)))
      end
      new_hex = ColorUtils.rgb_to_hex(r, g, b)
    elseif state.color_mode == "hsv" then
      local h, s, v = ColorUtils.hex_to_hsv(current_hex)
      if comp_name == "H" then
        h = math.max(0, math.min(360, num))
      elseif comp_name == "S" then
        s = math.max(0, math.min(100, num))
      elseif comp_name == "V" then
        v = math.max(0, math.min(100, num))
      end
      new_hex = ColorUtils.hsv_to_hex(h, s, v)
    elseif state.color_mode == "cmyk" then
      local c, m, y, k = ColorUtils.hex_to_cmyk(current_hex)
      if comp_name == "C" then
        c = math.max(0, math.min(100, num))
      elseif comp_name == "M" then
        m = math.max(0, math.min(100, num))
      elseif comp_name == "Y" then
        y = math.max(0, math.min(100, num))
      elseif comp_name == "K" then
        k = math.max(0, math.min(100, num))
      end
      new_hex = ColorUtils.cmyk_to_hex(c, m, y, k)
    end

    if new_hex then
      State.set_active_color(new_hex)
      if state.saved_hsl then
        local h, s, _ = ColorUtils.hex_to_hsl(new_hex)
        state.saved_hsl.h = h
        state.saved_hsl.s = s
      end
      schedule_render()
    end
  end
end

-- ============================================================================
-- InputManager Setup
-- ============================================================================

---Create and setup InputManager for info panel
---@param multi MultiPanelState
---@param schedule_render fun() Function to schedule a render
function M.setup_info_panel_input_manager(multi, schedule_render)
  local state = State.state
  if not state or not state._info_panel_cb then return end

  local info_panel = multi.panels["info"]
  if not info_panel or not info_panel.float or not info_panel.float:is_valid() then
    return
  end

  local bufnr = info_panel.float.bufnr
  local winid = info_panel.float.winid
  local cb = state._info_panel_cb

  state._info_input_manager = InputManager.new({
    bufnr = bufnr,
    winid = winid,
    inputs = cb:get_inputs(),
    input_order = cb:get_input_order(),
    on_input_exit = function(key)
      local value = state._info_input_manager:get_validated_value(key)
      if value and value ~= "" then
        M.handle_input_commit(key, value, schedule_render)
      end
    end,
  })

  state._info_input_manager:setup()
  state._info_input_manager:init_highlights()
  M.update_input_validation_settings()

  pcall(vim.keymap.del, 'n', '<Tab>', { buffer = bufnr })
  pcall(vim.keymap.del, 'n', '<S-Tab>', { buffer = bufnr })
  pcall(vim.keymap.del, 'i', '<Tab>', { buffer = bufnr })
  pcall(vim.keymap.del, 'i', '<S-Tab>', { buffer = bufnr })

  local opts = { buffer = bufnr, nowait = true, silent = true }
  vim.keymap.set('n', '<Tab>', function()
    multi:focus_next_panel()
  end, opts)
  vim.keymap.set('n', '<S-Tab>', function()
    multi:focus_prev_panel()
  end, opts)
end

return M
