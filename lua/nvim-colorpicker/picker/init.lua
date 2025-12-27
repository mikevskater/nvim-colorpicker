---@module 'nvim-colorpicker.picker'
---@brief Interactive color picker with HSL grid navigation
---
--- This is the main entry point for the color picker module.
--- During refactoring, this delegates to submodules for specific functionality.

local Types = require('nvim-colorpicker.picker.types')
local State = require('nvim-colorpicker.picker.state')
local ColorUtils = require('nvim-colorpicker.color')
local Config = require('nvim-colorpicker.config')
local UiFloat = require('nvim-float.float')
local MultiPanel = require('nvim-float.float.multipanel')
local ContentBuilder = require('nvim-float.content_builder')
local InputManager = require('nvim-float.input_manager')

local ColorPicker = {}

-- Re-export types for external use
ColorPicker.Types = Types

-- ============================================================================
-- Local References (from Types)
-- ============================================================================

local PREVIEW_BORDERS = Types.PREVIEW_BORDERS
local PREVIEW_RATIO = Types.PREVIEW_RATIO
local HEADER_HEIGHT = Types.HEADER_HEIGHT
local PADDING = Types.PADDING
local BASE_STEP_HUE = Types.BASE_STEP_HUE
local BASE_STEP_LIGHTNESS = Types.BASE_STEP_LIGHTNESS
local BASE_STEP_SATURATION = Types.BASE_STEP_SATURATION
local STEP_SIZES = Types.STEP_SIZES
local STEP_LABELS = Types.STEP_LABELS
local DEFAULT_STEP_INDEX = Types.DEFAULT_STEP_INDEX
local ALPHA_CHARS = Types.ALPHA_CHARS
local COLOR_MODES = Types.COLOR_MODES
local MIN_SIDE_BY_SIDE_WIDTH = Types.MIN_SIDE_BY_SIDE_WIDTH
local INFO_PANEL_MIN_WIDTH = Types.INFO_PANEL_MIN_WIDTH
local INFO_PANEL_MIN_HEIGHT = Types.INFO_PANEL_MIN_HEIGHT

-- ============================================================================
-- Helpers (using State module)
-- ============================================================================

---Get the current color
---@return string hex
local function get_active_color()
  return State.get_active_color()
end

---Set the current color
---@param hex string
local function set_active_color(hex)
  State.set_active_color(hex)
end

---Get current step multiplier
---@return number
local function get_step_multiplier()
  return State.get_step_multiplier()
end

---Get current step label
---@return string
local function get_step_label()
  return State.get_step_label()
end

---Get the alpha visualization character for a given alpha value
---@param alpha number Alpha value 0-100
---@return string char The character representing the alpha level
local function get_alpha_char(alpha)
  for _, def in ipairs(ALPHA_CHARS) do
    if alpha >= def.min and alpha <= def.max then
      return def.char
    end
  end
  return "█"
end

---Map a virtual position to actual 0-100 value with bounce (triangular wave)
---@param virtual number Virtual position (unbounded)
---@return number actual Actual value (0-100)
local function virtual_to_actual(virtual)
  local period = 200
  local normalized = virtual % period
  if normalized < 0 then normalized = normalized + period end

  if normalized <= 100 then
    return normalized
  else
    return 200 - normalized
  end
end

---Calculate grid dimensions and preview rows based on window size
---@param win_width number
---@param win_height number
---@return number grid_width, number grid_height, number preview_rows
local function calculate_grid_size(win_width, win_height)
  local available_width = win_width - PADDING * 2

  -- Fixed overhead: header (3 lines) + preview borders (2 lines for top/bottom)
  local fixed_overhead = HEADER_HEIGHT + PREVIEW_BORDERS
  local total_flexible = math.max(0, win_height - fixed_overhead)

  -- Allocate space: preview gets ratio, grid gets the rest
  local preview_rows = math.max(1, math.floor(total_flexible * PREVIEW_RATIO))
  local grid_height = total_flexible - preview_rows

  -- Apply odd-height preference for grid (better center alignment)
  if grid_height % 2 == 0 and grid_height > 5 then
    grid_height = grid_height - 1
  end

  -- Apply odd-width preference
  if available_width % 2 == 0 then
    available_width = available_width - 1
  end

  -- Enforce minimums
  available_width = math.max(11, available_width)
  grid_height = math.max(5, grid_height)
  preview_rows = math.max(1, preview_rows)

  -- Final validation: ensure total content fits in window
  local total_content = HEADER_HEIGHT + grid_height + PREVIEW_BORDERS + preview_rows
  if total_content > win_height then
    local excess = total_content - win_height
    grid_height = math.max(5, grid_height - excess)
  end

  return available_width, grid_height, preview_rows
end

---Generate highlight group name for a grid cell
---@param row number
---@param col number
---@return string
local function get_cell_hl_group(row, col)
  return string.format("NvimColorPickerCell_%d_%d", row, col)
end

-- ============================================================================
-- Rendering
-- ============================================================================

---Create highlight groups for the color grid
---@param grid string[][] The color grid
local function create_grid_highlights(grid)
  local state = State.state
  if not state then return end

  local center_row = math.ceil(#grid / 2)
  local center_col = math.ceil(#grid[1] / 2)

  for row_idx, row in ipairs(grid) do
    for col_idx, color in ipairs(row) do
      local hl_name = get_cell_hl_group(row_idx, col_idx)
      local hl_def

      if row_idx == center_row and col_idx == center_col then
        hl_def = {
          fg = ColorUtils.get_contrast_color(color),
          bg = color,
          bold = true,
        }
      else
        hl_def = { bg = color }
      end

      vim.api.nvim_set_hl(0, hl_name, hl_def)
    end
  end
end

---Generate color grid with virtual lightness positions for continuous scrolling
---@return string[][] grid 2D array of hex colors [row][col]
local function generate_virtual_grid()
  local state = State.state
  if not state then return {} end

  local center_color = get_active_color()
  local h, s, l = ColorUtils.hex_to_hsl(center_color)

  if state.saved_hsl and (l < 2 or l > 98) then
    h = state.saved_hsl.h
    s = state.saved_hsl.s
  end

  local virtual_l = state.lightness_virtual or l

  local grid = {}
  local half_height = math.floor(state.grid_height / 2)
  local half_width = math.floor(state.grid_width / 2)
  local hue_step = BASE_STEP_HUE * get_step_multiplier()
  local lightness_step = BASE_STEP_LIGHTNESS * get_step_multiplier()

  for row = 1, state.grid_height do
    local row_colors = {}
    local row_offset = half_height + 1 - row
    local row_virtual_l = virtual_l + (row_offset * lightness_step)
    local row_actual_l = virtual_to_actual(row_virtual_l)

    for col = 1, state.grid_width do
      local col_offset = col - half_width - 1
      local cell_h = (h + col_offset * hue_step) % 360
      if cell_h < 0 then cell_h = cell_h + 360 end

      local color = ColorUtils.hsl_to_hex(cell_h, s, row_actual_l)
      table.insert(row_colors, color)
    end

    table.insert(grid, row_colors)
  end

  return grid
end

---Render the color grid to buffer
---@return string[] lines
---@return table[] highlights
local function render_grid()
  local state = State.state
  if not state then return {}, {} end

  local lines = {}
  local highlights = {}

  local grid = generate_virtual_grid()
  create_grid_highlights(grid)

  local center_row = math.ceil(#grid / 2)
  local center_col = math.ceil(#grid[1] / 2)

  local pad = string.rep(" ", PADDING)

  for row_idx, row in ipairs(grid) do
    local line_chars = {}
    local line_hls = {}

    for col_idx, _ in ipairs(row) do
      local char = " "
      if row_idx == center_row and col_idx == center_col then
        char = "X"
      end
      table.insert(line_chars, char)

      table.insert(line_hls, {
        col_start = PADDING + col_idx - 1,
        col_end = PADDING + col_idx,
        hl_group = get_cell_hl_group(row_idx, col_idx),
      })
    end

    local line = pad .. table.concat(line_chars)
    table.insert(lines, line)

    for _, hl in ipairs(line_hls) do
      table.insert(highlights, {
        line = #lines - 1,
        col_start = hl.col_start,
        col_end = hl.col_end,
        hl_group = hl.hl_group,
      })
    end
  end

  return lines, highlights
end

---Render the split Original/Current preview section
---@return string[] lines
---@return table[] highlights
local function render_preview()
  local state = State.state
  if not state then return {}, {} end

  local lines = {}
  local highlights = {}
  local pad = string.rep(" ", PADDING)

  local preview_width = state.grid_width
  local half_width = math.floor((preview_width - 1) / 2)

  local orig_color = state.original.color or "#808080"
  local curr_color = state.current.color or "#808080"
  local orig_alpha = state.original_alpha or 100
  local curr_alpha = state.alpha or 100

  local orig_char = get_alpha_char(orig_alpha)
  local curr_char = get_alpha_char(curr_alpha)

  vim.api.nvim_set_hl(0, "NvimColorPickerOriginalPreview", { fg = orig_color })
  vim.api.nvim_set_hl(0, "NvimColorPickerCurrentPreview", { fg = curr_color })

  local border_char = "─"
  local orig_label = "Original"
  local curr_label = "Current"

  local orig_label_pos = math.floor((half_width - #orig_label) / 2)
  local curr_label_pos = math.floor((half_width - #curr_label) / 2)

  local top_border_left = string.rep(border_char, orig_label_pos) .. orig_label ..
                          string.rep(border_char, half_width - orig_label_pos - #orig_label)
  local top_border_right = string.rep(border_char, curr_label_pos) .. curr_label ..
                           string.rep(border_char, half_width - curr_label_pos - #curr_label)
  local top_border = pad .. top_border_left .. "┬" .. top_border_right

  local top_visual_len = half_width * 2 + 1
  local current_len = #top_border_left + 1 + #top_border_right
  if current_len < preview_width then
    top_border = top_border .. string.rep(border_char, preview_width - current_len)
  end

  table.insert(lines, pad .. top_border_left .. "┬" .. top_border_right)

  local orig_block = string.rep(orig_char, half_width)
  local curr_block = string.rep(curr_char, half_width)
  local orig_block_bytes = half_width * #orig_char
  local curr_block_bytes = half_width * #curr_char

  local preview_rows = state.preview_rows or 2
  for i = 1, preview_rows do
    local preview_line = pad .. orig_block .. "│" .. curr_block
    table.insert(lines, preview_line)

    table.insert(highlights, {
      line = #lines - 1,
      col_start = PADDING,
      col_end = PADDING + orig_block_bytes,
      hl_group = "NvimColorPickerOriginalPreview",
    })

    local divider_bytes = 3
    table.insert(highlights, {
      line = #lines - 1,
      col_start = PADDING + orig_block_bytes + divider_bytes,
      col_end = PADDING + orig_block_bytes + divider_bytes + curr_block_bytes,
      hl_group = "NvimColorPickerCurrentPreview",
    })
  end

  table.insert(lines, pad .. string.rep(border_char, half_width) .. "┴" .. string.rep(border_char, half_width))

  return lines, highlights
end

-- ============================================================================
-- ContentBuilder Render Functions
-- ============================================================================

---Render header using ContentBuilder
---@return ContentBuilder cb The content builder with header content
local function render_header_cb()
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
local function render_footer_cb()
  return ContentBuilder.new(), {}
end

-- ============================================================================
-- Multipanel Layout and Rendering
-- ============================================================================

local schedule_render_multipanel

---Create layout configuration for multipanel mode
---@return MultiPanelConfig
local function create_layout_config()
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
            cursorline = false,
            filetype = "nvim-colorpicker-info",
          },
        }
      },
      total_width_ratio = 0.95,
      total_height_ratio = 0.85,
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
            cursorline = false,
            filetype = "nvim-colorpicker-info",
          },
        }
      },
      total_width_ratio = 0.80,
      total_height_ratio = 0.75,
    }
  end
end

---Render the grid panel content
---@param multi_state MultiPanelState
---@return string[] lines
---@return table[] highlights
local function render_grid_panel(multi_state)
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

  local grid_width, grid_height, preview_rows = calculate_grid_size(panel_width, panel_height)
  state.grid_width = grid_width
  state.grid_height = grid_height
  state.preview_rows = preview_rows

  local header_cb = render_header_cb()
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

  local grid_lines, grid_highlights = render_grid()
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

  local preview_lines, preview_highlights = render_preview()
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

  local footer_cb, swatch_info = render_footer_cb()
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

---Render the info panel content using ContentBuilder with interactive inputs
---@param multi_state MultiPanelState
---@return string[] lines
---@return table[] highlights
local function render_info_panel(multi_state)
  local state = State.state
  if not state then return {}, {} end

  local cb = ContentBuilder.new()

  local current_hex = get_active_color()

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
    { text = get_step_label(), style = "value" },
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

---Get validation settings for color picker inputs based on current mode
---@return table<string, table> settings_map Map of input key -> validation settings
local function get_input_validation_settings()
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
local function update_input_validation_settings()
  local state = State.state
  if not state or not state._info_input_manager then return end
  local settings = get_input_validation_settings()
  state._info_input_manager:update_all_input_settings(settings)
end

---Render all multipanel panels
local function render_multipanel()
  local state = State.state
  if not state or not state._multipanel then return end

  local multi = state._multipanel

  multi:render_panel("grid")
  multi:render_panel("info")

  if state._info_input_manager and state._info_panel_cb then
    local cb = state._info_panel_cb
    state._info_input_manager:update_inputs(
      cb:get_inputs(),
      cb:get_input_order()
    )
    update_input_validation_settings()
  end

  if state.options.on_change then
    local result = vim.deepcopy(state.current)
    result.alpha = state.alpha_enabled and state.alpha or nil
    if state.options.custom_controls and #state.options.custom_controls > 0 then
      result.custom = vim.deepcopy(state.custom_values)
    end
    state.options.on_change(result)
  end
end

---Schedule a render for multipanel mode
schedule_render_multipanel = function()
  local state = State.state
  if not state or not state._multipanel then return end

  if state._render_pending then return end

  state._render_pending = true
  vim.schedule(function()
    if State.state and State.state._multipanel then
      State.state._render_pending = false
      render_multipanel()
    end
  end)
end

---Schedule a render for the next event loop iteration
local function schedule_render()
  if not State.state then return end
  schedule_render_multipanel()
end

---Increase step size
local function increase_step_size()
  State.increase_step_size(schedule_render)
end

---Decrease step size
local function decrease_step_size()
  State.decrease_step_size(schedule_render)
end

-- ============================================================================
-- Navigation
-- ============================================================================

---Shift hue
---@param delta number Positive = right (increase hue), negative = left
local function shift_hue(delta)
  local state = State.state
  if not state then return end
  local current = get_active_color()
  local step = delta * BASE_STEP_HUE * get_step_multiplier()
  local new_color = ColorUtils.adjust_hue(current, step)

  if state.saved_hsl then
    local h, _, _ = ColorUtils.hex_to_hsl(new_color)
    state.saved_hsl.h = h
  end

  set_active_color(new_color)
  schedule_render()
end

---Shift lightness with bounce and color band memory
---@param delta number Positive = up (increase lightness), negative = down
local function shift_lightness(delta)
  local state = State.state
  if not state then return end
  local current = get_active_color()
  local h, s, l = ColorUtils.hex_to_hsl(current)

  if not state.lightness_virtual then
    state.lightness_virtual = l
  end

  if l > 2 and l < 98 and s > 5 then
    state.saved_hsl = { h = h, s = s }
  end

  local step = delta * BASE_STEP_LIGHTNESS * get_step_multiplier()
  state.lightness_virtual = state.lightness_virtual + step

  local new_l = virtual_to_actual(state.lightness_virtual)

  local new_h, new_s = h, s
  if state.saved_hsl and new_l > 2 and new_l < 98 then
    new_h = state.saved_hsl.h
    new_s = state.saved_hsl.s
  end

  local new_color = ColorUtils.hsl_to_hex(new_h, new_s, new_l)
  set_active_color(new_color)
  schedule_render()
end

---Shift saturation with bounce
---@param delta number Positive = increase, negative = decrease
local function shift_saturation(delta)
  local state = State.state
  if not state then return end
  local current = get_active_color()
  local h, s, l = ColorUtils.hex_to_hsl(current)

  if not state.saturation_virtual then
    state.saturation_virtual = s
  end

  local step = delta * BASE_STEP_SATURATION * get_step_multiplier()
  state.saturation_virtual = state.saturation_virtual + step

  local new_s = virtual_to_actual(state.saturation_virtual)

  if state.saved_hsl then
    state.saved_hsl.s = new_s
  end

  local new_color = ColorUtils.hsl_to_hex(h, new_s, l)
  set_active_color(new_color)
  schedule_render()
end

---Reset to original color
local function reset_color()
  local state = State.state
  if not state then return end
  state.current = vim.deepcopy(state.original)
  schedule_render()
end

---Toggle or cycle a custom control value
---@param control_id string The control ID
local function toggle_custom_control(control_id)
  local state = State.state
  if not state or not state.options.custom_controls then return end

  local control = nil
  for _, ctrl in ipairs(state.options.custom_controls) do
    if ctrl.id == control_id then
      control = ctrl
      break
    end
  end

  if not control then return end

  local old_value = state.custom_values[control_id]
  local new_value = old_value

  if control.type == "toggle" then
    new_value = not old_value
  elseif control.type == "select" then
    local current_idx = 1
    for i, opt in ipairs(control.options) do
      if opt == old_value then
        current_idx = i
        break
      end
    end
    local next_idx = (current_idx % #control.options) + 1
    new_value = control.options[next_idx]
  elseif control.type == "number" then
    local step = control.step or 1
    local min_val = control.min or 0
    local max_val = control.max or 100
    new_value = old_value + step
    if new_value > max_val then new_value = min_val end
  end

  state.custom_values[control_id] = new_value

  if control.on_change and old_value ~= new_value then
    control.on_change(new_value, old_value, control_id)
  end

  schedule_render()
end

---Cycle through color modes
local function cycle_mode()
  local state = State.state
  if not state then return end

  if state.options.forced_mode then
    vim.notify("Color mode is locked to " .. state.options.forced_mode:upper(), vim.log.levels.INFO)
    return
  end

  local current_idx = 1
  for i, mode in ipairs(COLOR_MODES) do
    if mode == state.color_mode then
      current_idx = i
      break
    end
  end

  local next_idx = (current_idx % #COLOR_MODES) + 1
  state.color_mode = COLOR_MODES[next_idx]
  schedule_render()
end

---Cycle value display format
local function cycle_format()
  local state = State.state
  if not state then return end
  state.value_format = state.value_format == "standard" and "decimal" or "standard"
  schedule_render()
end

---Adjust alpha value
---@param delta number Amount to change alpha
local function adjust_alpha(delta)
  local state = State.state
  if not state then return end

  if not state.alpha_enabled then
    vim.notify("Alpha editing is not enabled", vim.log.levels.INFO)
    return
  end

  if state.color_mode == "cmyk" then
    vim.notify("CMYK mode does not support alpha", vim.log.levels.INFO)
    return
  end

  local step = delta * BASE_STEP_SATURATION * get_step_multiplier()
  state.alpha = math.max(0, math.min(100, state.alpha + step))
  schedule_render()
end

---Enter hex input mode
local function enter_hex_input()
  local state = State.state
  if not state then return end

  local current = get_active_color()

  vim.ui.input({
    prompt = "Enter hex color: ",
    default = current,
  }, function(input)
    if input and ColorUtils.is_valid_hex(input) then
      set_active_color(input)
      schedule_render()
    elseif input then
      vim.notify("Invalid hex color: " .. input, vim.log.levels.WARN)
    end
  end)
end

---Apply and close
local function apply()
  local state = State.state
  if not state then return end

  local result = vim.deepcopy(state.current)
  result.alpha = state.alpha_enabled and state.alpha or nil
  if state.options.custom_controls and #state.options.custom_controls > 0 then
    result.custom = vim.deepcopy(state.custom_values)
  end
  local on_select = state.options.on_select

  ColorPicker.close()

  if on_select then
    on_select(result)
  end
end

---Cancel and close
local function cancel()
  local state = State.state
  if not state then return end

  if state.options.on_change then
    state.options.on_change(vim.deepcopy(state.original))
  end

  if state.options.on_cancel then
    state.options.on_cancel()
  end

  ColorPicker.close()
end

-- ============================================================================
-- Controls Definition (for UiFloat help popup)
-- ============================================================================

---Get controls definition for the color picker
---@return ControlsDefinition[]
local function get_controls_definition()
  local state = State.state
  local controls = {
    {
      header = "Navigation",
      keys = {
        { key = "h / l", desc = "Move hue (left/right)" },
        { key = "j / k", desc = "Adjust lightness (down/up)" },
        { key = "J / K", desc = "Adjust saturation (less/more)" },
        { key = "[count]", desc = "Use counts: 10h, 50k" },
      }
    },
    {
      header = "Step Size",
      keys = {
        { key = "- / +", desc = "Decrease/increase multiplier" },
      }
    },
    {
      header = "Color Mode",
      keys = {
        { key = "m", desc = "Cycle mode (HSL/RGB/CMYK/HSV)" },
        { key = "f", desc = "Toggle format (standard/decimal)" },
      }
    },
    {
      header = "Actions",
      keys = {
        { key = "#", desc = "Enter hex color manually" },
        { key = "r", desc = "Reset to original" },
        { key = "Enter", desc = "Apply and close" },
        { key = "q / Esc", desc = "Cancel and close" },
      }
    },
  }

  if state and state.alpha_enabled then
    table.insert(controls, 4, {
      header = "Alpha",
      keys = {
        { key = "a / A", desc = "Decrease/increase opacity" },
      }
    })
  end

  return controls
end

---Show the help popup
local function show_help()
  local state = State.state
  if not state then return end

  if state._multipanel then
    state._multipanel:show_controls(get_controls_definition())
    return
  end

  if state._float then
    state._float:show_controls(get_controls_definition())
  end
end

-- ============================================================================
-- Window Management
-- ============================================================================

---Close the color picker
function ColorPicker.close()
  local state = State.state
  if not state then return end

  local grid_height = state.grid_height or 20
  local grid_width = state.grid_width or 60
  local multipanel = state._multipanel
  local input_manager = state._info_input_manager

  if input_manager then
    input_manager:destroy()
  end

  State.clear_state()

  pcall(vim.api.nvim_del_augroup_by_name, "NvimColorPickerFocusLoss")

  for row = 1, grid_height do
    for col = 1, grid_width do
      pcall(vim.api.nvim_set_hl, 0, get_cell_hl_group(row, col), {})
    end
  end
  pcall(vim.api.nvim_set_hl, 0, "NvimColorPickerPreview", {})
  pcall(vim.api.nvim_set_hl, 0, "NvimColorPickerOriginalPreview", {})
  pcall(vim.api.nvim_set_hl, 0, "NvimColorPickerCurrentPreview", {})

  if multipanel and multipanel:is_valid() then
    multipanel:close()
  end
end

---Setup keymaps for multipanel mode
---@param multi MultiPanelState
local function setup_multipanel_keymaps(multi)
  local state = State.state
  if not state then return end

  local cfg = state._keymaps or Config.get_keymaps()

  local function get_key(name, default)
    return cfg[name] or default
  end

  local grid_keymaps = {}

  local nav_left = get_key("nav_left", "h")
  local nav_right = get_key("nav_right", "l")
  local nav_up = get_key("nav_up", "k")
  local nav_down = get_key("nav_down", "j")
  local sat_up = get_key("sat_up", "K")
  local sat_down = get_key("sat_down", "J")

  grid_keymaps[nav_left] = function()
    local count = vim.v.count1
    shift_hue(-count)
  end
  grid_keymaps[nav_right] = function()
    local count = vim.v.count1
    shift_hue(count)
  end
  grid_keymaps[nav_up] = function()
    local count = vim.v.count1
    shift_lightness(count)
  end
  grid_keymaps[nav_down] = function()
    local count = vim.v.count1
    shift_lightness(-count)
  end
  grid_keymaps[sat_up] = function()
    local count = vim.v.count1
    shift_saturation(count)
  end
  grid_keymaps[sat_down] = function()
    local count = vim.v.count1
    shift_saturation(-count)
  end

  grid_keymaps[get_key("step_down", "-")] = decrease_step_size
  local step_up_keys = get_key("step_up", { "+", "=" })
  if type(step_up_keys) == "table" then
    for _, k in ipairs(step_up_keys) do
      grid_keymaps[k] = increase_step_size
    end
  else
    grid_keymaps[step_up_keys] = increase_step_size
  end

  multi:set_panel_keymaps("grid", grid_keymaps)

  local common_keymaps = {}

  common_keymaps[get_key("reset", "r")] = reset_color
  common_keymaps[get_key("hex_input", "#")] = enter_hex_input
  common_keymaps[get_key("apply", "<CR>")] = apply

  local cancel_keys = get_key("cancel", { "q", "<Esc>" })
  if type(cancel_keys) == "table" then
    for _, k in ipairs(cancel_keys) do
      common_keymaps[k] = cancel
    end
  else
    common_keymaps[cancel_keys] = cancel
  end

  common_keymaps[get_key("help", "?")] = show_help

  common_keymaps[get_key("cycle_mode", "m")] = cycle_mode
  common_keymaps[get_key("cycle_format", "f")] = cycle_format

  common_keymaps[get_key("alpha_up", "A")] = function()
    local count = vim.v.count1
    adjust_alpha(count)
  end
  common_keymaps[get_key("alpha_down", "a")] = function()
    local count = vim.v.count1
    adjust_alpha(-count)
  end

  common_keymaps[get_key("focus_next", "<Tab>")] = function()
    multi:focus_next_panel()
  end
  common_keymaps[get_key("focus_prev", "<S-Tab>")] = function()
    multi:focus_prev_panel()
  end

  if state and state.options.custom_controls then
    for _, control in ipairs(state.options.custom_controls) do
      if control.key then
        common_keymaps[control.key] = function()
          toggle_custom_control(control.id)
        end
      end
    end
  end

  multi:set_keymaps(common_keymaps)
end

---Extract numeric value from a string
---@param str string The input string
---@return number|nil value The extracted number, or nil if no valid number found
local function extract_number(str)
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
local function extract_hex_digits(str)
  if not str or str == "" then return nil end
  local cleaned = str:gsub("^#", "")
  local hex_only = cleaned:gsub("[^%x]", "")
  if hex_only == "" then return nil end
  return hex_only
end

---Handle input commit from the info panel
---@param key string Input field key
---@param value string The committed input value
local function handle_input_commit(key, value)
  local state = State.state
  if not state then return end

  value = value:gsub("^%s+", ""):gsub("%s+$", "")
  if value == "" then return end

  if key == "hex" then
    local hex_digits = extract_hex_digits(value)
    if not hex_digits then return end

    if #hex_digits >= 6 then
      local color_hex = "#" .. hex_digits:sub(1, 6):upper()
      if ColorUtils.is_valid_hex(color_hex) then
        set_active_color(color_hex)

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
    local num = extract_number(value)
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
    local current_hex = get_active_color()

    local num = extract_number(value)
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
      set_active_color(new_hex)
      if state.saved_hsl then
        local h, s, _ = ColorUtils.hex_to_hsl(new_hex)
        state.saved_hsl.h = h
        state.saved_hsl.s = s
      end
      schedule_render()
    end
  end
end

---Create and setup InputManager for info panel
---@param multi MultiPanelState
local function setup_info_panel_input_manager(multi)
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
        handle_input_commit(key, value)
      end
    end,
  })

  state._info_input_manager:setup()
  state._info_input_manager:init_highlights()
  update_input_validation_settings()

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

  local layout_config = create_layout_config()

  local grid_title = options.title or "Color Grid"

  if options.title then
    layout_config.layout.children[1].title = grid_title
  end

  layout_config.layout.children[1].on_render = render_grid_panel
  layout_config.layout.children[2].on_render = render_info_panel

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
    multi_state:update_panel_title("info", "Info *")
    multi_state:update_panel_title("grid", grid_title)
    if State.state and State.state._info_input_manager then
      vim.schedule(function()
        if State.state and State.state._info_input_manager then
          State.state._info_input_manager:focus_first_field()
        end
      end)
    end
  end

  layout_config.layout.children[2].on_blur = function(multi_state)
    multi_state:update_panel_title("info", "Info")
  end

  layout_config.controls = get_controls_definition()
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
    grid_width, grid_height, preview_rows = calculate_grid_size(grid_panel.rect.width, grid_panel.rect.height)
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

  setup_multipanel_keymaps(multi)
  render_multipanel()
  setup_info_panel_input_manager(multi)

  local augroup = vim.api.nvim_create_augroup("NvimColorPickerFocusLoss", { clear = true })

  local function on_focus_lost()
    if not State.state then return end

    vim.schedule(function()
      if not State.state then return end

      local current_win = vim.api.nvim_get_current_win()
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
  vim.notify(string.format("PICKER set_color called: hex=%s, original_hex=%s", hex or "nil", original_hex or "nil"))
  if not state then
    vim.notify("  ERROR: state is nil!")
    return
  end

  hex = ColorUtils.normalize_hex(hex)
  vim.notify(string.format("  Setting state.current.color = %s (was %s)", hex, state.current.color))
  state.current.color = hex

  if original_hex then
    local normalized_original = ColorUtils.normalize_hex(original_hex)
    vim.notify(string.format("  Setting state.original.color = %s (was %s)", normalized_original, state.original.color))
    state.original.color = normalized_original
    state.original_alpha = state.alpha
  else
    vim.notify("  original_hex not provided, original unchanged")
  end

  local h, s, _ = ColorUtils.hex_to_hsl(hex)
  state.saved_hsl = { h = h, s = s }

  state.lightness_virtual = nil
  state.saturation_virtual = nil

  schedule_render()
  vim.notify("  set_color complete, render scheduled")
end

---Get the current color
---@return string? hex The current hex color
function ColorPicker.get_color()
  local state = State.state
  if not state then return nil end
  return state.current.color
end

return ColorPicker
