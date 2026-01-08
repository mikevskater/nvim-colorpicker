---@module 'nvim-colorpicker.picker.mini'
---@brief Compact inline color picker

local State = require('nvim-colorpicker.picker.state')
local Grid = require('nvim-colorpicker.picker.grid')
local Preview = require('nvim-colorpicker.picker.preview')
local Navigation = require('nvim-colorpicker.picker.navigation')
local Actions = require('nvim-colorpicker.picker.actions')
local Format = require('nvim-colorpicker.picker.format')
local Slider = require('nvim-colorpicker.picker.slider')
local ColorUtils = require('nvim-colorpicker.color')
local Config = require('nvim-colorpicker.config')
local UiFloat = require('nvim-float.window')

local M = {}

-- Module-level state for slider mode
local slider_mode = false
local slider_focus = 1  -- 1-indexed focused slider

-- ============================================================================
-- Constants
-- ============================================================================

local MIN_WIDTH = 30
local MIN_HEIGHT = 8
local WIDTH_RATIO = 0.40
local HEIGHT_RATIO = 0.35

-- Controls definition for help popup (ControlsDefinition[] format)
-- Built dynamically to reflect configured keymaps
local function build_controls_definition(cfg)
  return {
    {
      header = "Grid Mode",
      keys = {
        { key = cfg.nav_left .. "/" .. cfg.nav_right, desc = "Adjust hue (left/right)" },
        { key = cfg.nav_down .. "/" .. cfg.nav_up, desc = "Adjust lightness (down/up)" },
        { key = cfg.sat_down .. "/" .. cfg.sat_up, desc = "Adjust saturation" },
        { key = cfg.alpha_down .. "/" .. cfg.alpha_up, desc = "Adjust alpha (if enabled)" },
        { key = cfg.step_down .. "/+", desc = "Decrease/increase step size" },
      },
    },
    {
      header = "Slider Mode",
      keys = {
        { key = "s", desc = "Toggle slider mode" },
        { key = cfg.nav_down .. "/" .. cfg.nav_up, desc = "Navigate sliders" },
        { key = cfg.step_down .. "/+", desc = "Adjust focused slider" },
      },
    },
    {
      header = "Display",
      keys = {
        { key = cfg.cycle_mode, desc = "Cycle color mode (hex/hsl/rgb/hsv/cmyk)" },
        { key = cfg.cycle_format, desc = "Toggle value format (percent/decimal)" },
        { key = cfg.hex_input, desc = "Enter hex color directly" },
      },
    },
    {
      header = "Actions",
      keys = {
        { key = cfg.reset, desc = "Reset to original color" },
        { key = "Enter", desc = "Apply color and close" },
        { key = "q/Esc", desc = "Cancel and close" },
      },
    },
  }
end

-- ============================================================================
-- Title Building
-- ============================================================================

---Build the title string with color and step size
---@return string title
local function build_title()
  local state = State.state
  if not state then return "Pick Color" end

  return Format.build_title(
    state.current.color,
    state.color_mode,
    state.alpha,
    state.alpha_enabled,
    state.value_format or "standard",
    State.get_step_label()
  )
end

-- ============================================================================
-- Rendering
-- ============================================================================

---Render the mini picker content
---@param width number Window inner width
---@param height number Window inner height
---@return string[] lines
---@return table[] highlights
local function render_content(width, height)
  local state = State.state
  if not state then return {}, {} end

  local lines = {}
  local highlights = {}

  -- Calculate grid size: height - 2 (separator row + preview row)
  -- Grid uses full width (no padding)
  local grid_height = height - 2
  local grid_width = width

  -- Ensure odd width for center alignment
  if grid_width % 2 == 0 then grid_width = grid_width - 1 end

  -- Enforce minimums
  grid_width = math.max(11, grid_width)
  grid_height = math.max(3, grid_height)

  -- Track if we need an extra blank line at top (when grid_height is even, we add padding)
  local top_padding_line = false
  if grid_height % 2 == 0 and grid_height > 3 then
    top_padding_line = true
    grid_height = grid_height - 1
  end

  -- Update state with grid dimensions
  state.grid_width = grid_width
  state.grid_height = grid_height
  state.preview_rows = 1

  -- Generate and render grid
  local grid = Grid.generate_virtual_grid()
  Grid.create_grid_highlights(grid)

  local center_row = math.ceil(#grid / 2)
  local center_col = math.ceil(#grid[1] / 2)

  -- Add top padding line if needed to fill window height
  local line_offset = 0
  if top_padding_line then
    table.insert(lines, "")
    line_offset = 1
  end

  -- Character constants with their byte lengths
  local BLOCK_CHAR = "█"
  local BLOCK_CHAR_LEN = #BLOCK_CHAR  -- 3 bytes in UTF-8
  local CURSOR_CHAR = "x"
  local CURSOR_CHAR_LEN = #CURSOR_CHAR  -- 1 byte

  -- Render grid rows (no padding - edge to edge)
  for row_idx, row in ipairs(grid) do
    local line = ""
    local row_highlights = {}
    local byte_pos = 0

    for col_idx, _ in ipairs(row) do
      local char, char_len
      if row_idx == center_row and col_idx == center_col then
        char = CURSOR_CHAR
        char_len = CURSOR_CHAR_LEN
      else
        char = BLOCK_CHAR
        char_len = BLOCK_CHAR_LEN
      end
      line = line .. char

      table.insert(row_highlights, {
        col_start = byte_pos,
        col_end = byte_pos + char_len,
        hl_group = Grid.get_cell_hl_group(row_idx, col_idx),
      })

      byte_pos = byte_pos + char_len
    end
    table.insert(lines, line)

    -- Add highlights for each cell
    for _, hl in ipairs(row_highlights) do
      table.insert(highlights, {
        line = row_idx - 1 + line_offset,
        col_start = hl.col_start,
        col_end = hl.col_end,
        hl_group = hl.hl_group,
      })
    end
  end

  -- Build separator row: ──Original──┬──Current──
  local half_width = math.floor(grid_width / 2)
  local orig_label = "Original"
  local curr_label = "Current"

  -- Left side: dashes + label + dashes
  local left_dashes = math.floor((half_width - #orig_label) / 2)
  local right_dashes_left = half_width - left_dashes - #orig_label

  -- Right side: dashes + label + dashes (after ┬)
  local right_half = grid_width - half_width - 1  -- -1 for ┬
  local left_dashes_right = math.floor((right_half - #curr_label) / 2)
  local right_dashes_right = right_half - left_dashes_right - #curr_label

  local sep_line = string.rep("─", left_dashes) .. orig_label .. string.rep("─", right_dashes_left)
                   .. "┬"
                   .. string.rep("─", left_dashes_right) .. curr_label .. string.rep("─", right_dashes_right)

  table.insert(lines, sep_line)
  local sep_line_idx = #lines - 1

  -- Highlight the separator
  table.insert(highlights, {
    line = sep_line_idx,
    col_start = 0,
    col_end = #sep_line,
    hl_group = "FloatBorder",
  })

  -- Preview row: alpha-aware color blocks with vertical divider
  local original_hex = state.original.color
  local current_hex = state.current.color
  local orig_alpha = state.original_alpha or 100
  local curr_alpha = state.alpha or 100

  -- Get alpha characters (like full picker preview)
  local orig_char = Preview.get_alpha_char(orig_alpha)
  local curr_char = Preview.get_alpha_char(curr_alpha)

  -- Create highlight groups for preview (foreground color, like full picker)
  local orig_hl = "NvimColorPickerMiniOriginal"
  local curr_hl = "NvimColorPickerMiniCurrent"
  vim.api.nvim_set_hl(0, orig_hl, { fg = original_hex })
  vim.api.nvim_set_hl(0, curr_hl, { fg = current_hex })

  -- Build preview line: left block + │ + right block
  local left_block_width = half_width
  local right_block_width = grid_width - half_width - 1  -- -1 for divider
  local divider = "│"

  local preview_line = string.rep(orig_char, left_block_width)
                       .. divider
                       .. string.rep(curr_char, right_block_width)

  table.insert(lines, preview_line)
  local preview_line_idx = #lines - 1

  -- Calculate byte positions for highlights
  -- orig_char and curr_char may be multi-byte
  local orig_char_bytes = #orig_char
  local curr_char_bytes = #curr_char
  local divider_bytes = #divider

  local left_block_bytes = left_block_width * orig_char_bytes
  local right_block_bytes = right_block_width * curr_char_bytes

  -- Add highlights for preview blocks
  table.insert(highlights, {
    line = preview_line_idx,
    col_start = 0,
    col_end = left_block_bytes,
    hl_group = orig_hl,
  })
  -- Divider gets border highlight
  table.insert(highlights, {
    line = preview_line_idx,
    col_start = left_block_bytes,
    col_end = left_block_bytes + divider_bytes,
    hl_group = "FloatBorder",
  })
  table.insert(highlights, {
    line = preview_line_idx,
    col_start = left_block_bytes + divider_bytes,
    col_end = left_block_bytes + divider_bytes + right_block_bytes,
    hl_group = curr_hl,
  })

  return lines, highlights
end

---Render the mini picker in slider mode
---@param width number Window inner width
---@param height number Window inner height
---@return string[] lines
---@return table[] highlights
local function render_sliders_content(width, height)
  local state = State.state
  if not state then return {}, {} end

  local lines = {}
  local highlights = {}

  -- Get components for current mode
  local components = Slider.get_components(state.color_mode, state.alpha_enabled)
  local values = Slider.get_component_values(state.current.color, state.color_mode, state.alpha)

  -- Calculate slider width (leave room for label and value)
  -- Format: "  L: ████░░░░ 100%"
  -- ~6 chars for label ("  L: "), ~6 chars for value (" 100%"), rest for slider
  local slider_width = math.max(8, width - 12)

  -- Layout: sliders at top, preview anchored at bottom, padding in between
  -- Preview takes 2 lines (separator + color blocks)
  -- Sliders take #components lines
  local slider_lines = #components
  local preview_lines = 2
  local padding_lines = math.max(1, height - slider_lines - preview_lines)

  -- Add a blank line at top for visual spacing
  table.insert(lines, "")

  -- Helper to pad based on display width (handles multi-byte chars like °)
  local function pad_display(str, width)
    local display_width = vim.fn.strdisplaywidth(str)
    local padding = math.max(0, width - display_width)
    return string.rep(" ", padding) .. str
  end

  -- Render each slider
  for i, comp in ipairs(components) do
    local value = values[comp.key] or 0
    local slider_str = Slider.render_slider(value, comp.min, comp.max, slider_width)
    local formatted = ColorUtils.format_value(value, comp.unit, state.value_format or "standard")
    local value_padded = pad_display(formatted, 5)

    local line = string.format("  %s: %s %s", comp.label, slider_str, value_padded)
    table.insert(lines, line)

    local line_idx = #lines - 1

    -- Highlight focused slider differently
    local is_focused = (i == slider_focus)
    if is_focused then
      -- Add emphasis highlight for focused row
      table.insert(highlights, {
        line = line_idx,
        col_start = 0,
        col_end = #line,
        hl_group = "CursorLine",
      })
    end
  end

  -- Add padding lines to push preview to bottom
  -- Subtract 1 for the top blank line we already added
  for _ = 1, padding_lines - 1 do
    table.insert(lines, "")
  end

  -- Build separator row (same as grid mode)
  local half_width = math.floor(width / 2)
  local orig_label = "Original"
  local curr_label = "Current"

  local left_dashes = math.floor((half_width - #orig_label) / 2)
  local right_dashes_left = half_width - left_dashes - #orig_label
  local right_half = width - half_width - 1
  local left_dashes_right = math.floor((right_half - #curr_label) / 2)
  local right_dashes_right = right_half - left_dashes_right - #curr_label

  local sep_line = string.rep("─", left_dashes) .. orig_label .. string.rep("─", right_dashes_left)
                   .. "┬"
                   .. string.rep("─", left_dashes_right) .. curr_label .. string.rep("─", right_dashes_right)

  table.insert(lines, sep_line)
  local sep_line_idx = #lines - 1

  table.insert(highlights, {
    line = sep_line_idx,
    col_start = 0,
    col_end = #sep_line,
    hl_group = "FloatBorder",
  })

  -- Preview row (same as grid mode)
  local original_hex = state.original.color
  local current_hex = state.current.color
  local orig_alpha = state.original_alpha or 100
  local curr_alpha = state.alpha or 100

  local orig_char = Preview.get_alpha_char(orig_alpha)
  local curr_char = Preview.get_alpha_char(curr_alpha)

  local orig_hl = "NvimColorPickerMiniOriginal"
  local curr_hl = "NvimColorPickerMiniCurrent"
  vim.api.nvim_set_hl(0, orig_hl, { fg = original_hex })
  vim.api.nvim_set_hl(0, curr_hl, { fg = current_hex })

  local left_block_width = half_width
  local right_block_width = width - half_width - 1
  local divider = "│"

  local preview_line = string.rep(orig_char, left_block_width)
                       .. divider
                       .. string.rep(curr_char, right_block_width)

  table.insert(lines, preview_line)
  local preview_line_idx = #lines - 1

  local orig_char_bytes = #orig_char
  local curr_char_bytes = #curr_char
  local divider_bytes = #divider

  local left_block_bytes = left_block_width * orig_char_bytes
  local right_block_bytes = right_block_width * curr_char_bytes

  table.insert(highlights, {
    line = preview_line_idx,
    col_start = 0,
    col_end = left_block_bytes,
    hl_group = orig_hl,
  })
  table.insert(highlights, {
    line = preview_line_idx,
    col_start = left_block_bytes,
    col_end = left_block_bytes + divider_bytes,
    hl_group = "FloatBorder",
  })
  table.insert(highlights, {
    line = preview_line_idx,
    col_start = left_block_bytes + divider_bytes,
    col_end = left_block_bytes + divider_bytes + right_block_bytes,
    hl_group = curr_hl,
  })

  return lines, highlights
end

-- ============================================================================
-- Window Management
-- ============================================================================

---@type FloatWindow?
local mini_float = nil

---Update the title with current color/step
local function update_title()
  if not mini_float or not mini_float:is_valid() then return end
  mini_float:update_title(build_title())
end

---Render the mini picker
local function render()
  if not mini_float or not mini_float:is_valid() then return end

  local state = State.state
  if not state then return end

  local win_config = vim.api.nvim_win_get_config(mini_float.winid)
  local inner_width = win_config.width
  local inner_height = win_config.height

  -- Render based on mode (grid or sliders)
  local lines, highlights
  if slider_mode then
    lines, highlights = render_sliders_content(inner_width, inner_height)
  else
    lines, highlights = render_content(inner_width, inner_height)
  end

  -- Update buffer content
  vim.api.nvim_buf_set_option(mini_float.bufnr, 'modifiable', true)
  vim.api.nvim_buf_set_lines(mini_float.bufnr, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(mini_float.bufnr, 'modifiable', false)

  -- Apply highlights
  local ns = vim.api.nvim_create_namespace("nvim_colorpicker_mini")
  vim.api.nvim_buf_clear_namespace(mini_float.bufnr, ns, 0, -1)

  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(
      mini_float.bufnr,
      ns,
      hl.hl_group,
      hl.line,
      hl.col_start,
      hl.col_end
    )
  end

  -- Update title
  update_title()

  -- Call on_change callback
  if state.options.on_change then
    local result = Actions.build_result()
    state.options.on_change(result)
  end
end

---Schedule a render for next frame
local function schedule_render()
  vim.schedule(render)
end

-- ============================================================================
-- Slider Navigation (for slider mode)
-- ============================================================================

---Move slider focus up
local function slider_focus_up()
  local state = State.state
  if not state then return end

  local components = Slider.get_components(state.color_mode, state.alpha_enabled)
  local count = #components

  slider_focus = slider_focus - 1
  if slider_focus < 1 then
    slider_focus = count  -- Wrap to bottom
  end

  schedule_render()
end

---Move slider focus down
local function slider_focus_down()
  local state = State.state
  if not state then return end

  local components = Slider.get_components(state.color_mode, state.alpha_enabled)
  local count = #components

  slider_focus = slider_focus + 1
  if slider_focus > count then
    slider_focus = 1  -- Wrap to top
  end

  schedule_render()
end

---Adjust the focused slider
---@param delta number Positive or negative delta
local function adjust_focused_slider(delta)
  Slider.adjust_component(slider_focus, delta, schedule_render)
end

---Toggle between grid and slider mode
local function toggle_slider_mode()
  slider_mode = not slider_mode
  slider_focus = 1  -- Reset focus when toggling
  schedule_render()
end

-- ============================================================================
-- Public API
-- ============================================================================

---Close the mini picker
function M.close()
  local state = State.state

  if state then
    Actions.cleanup_highlights(state.grid_height, state.grid_width)
  end

  State.clear_state()

  -- Reset module state
  slider_mode = false
  slider_focus = 1

  if mini_float and mini_float:is_valid() then
    mini_float:close()
  end
  mini_float = nil
end

---Check if mini picker is open
---@return boolean
function M.is_open()
  return mini_float ~= nil and mini_float:is_valid()
end

---Open the mini color picker
---@param opts table Options
function M.pick(opts)
  opts = opts or {}

  -- Close any existing picker
  M.close()

  -- Determine initial color
  local initial_color = opts.color or "#808080"
  initial_color = ColorUtils.normalize_hex(initial_color)

  -- Calculate window dimensions
  local ui = vim.api.nvim_list_uis()[1]
  local width = math.max(MIN_WIDTH, math.floor(ui.width * WIDTH_RATIO))
  local height = math.max(MIN_HEIGHT, math.floor(ui.height * HEIGHT_RATIO))

  -- Calculate cursor's actual screen position
  -- vim.fn.screenpos() returns the true screen coordinates of the cursor
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local screen_pos = vim.fn.screenpos(0, cursor_pos[1], cursor_pos[2] + 1)
  local cursor_screen_row = screen_pos.row
  local cursor_screen_col = screen_pos.col

  -- Smart positioning: prefer below cursor, but go above if not enough room below
  -- Account for window height + 2 for border + 1 for gap
  local total_height = height + 3
  local row, col

  -- Check if there's room below the cursor
  local room_below = ui.height - cursor_screen_row
  local room_above = cursor_screen_row - 1

  if room_below >= total_height then
    -- Position below cursor with 1 row gap
    row = 2
  elseif room_above >= total_height then
    -- Position above cursor with 1 row gap (negative offset from cursor)
    row = -height - 3
  elseif room_below >= room_above then
    -- More room below, position there even if it might clip
    row = 2
  else
    -- More room above, position there even if it might clip
    row = -height - 3
  end

  -- Horizontal positioning: prefer right of cursor, go left if not enough room
  local room_right = ui.width - cursor_screen_col
  if room_right >= width + 2 then
    col = 1  -- Right of cursor
  else
    col = -width - 1  -- Left of cursor
  end

  -- Determine alpha settings (use config default if not specified)
  local config = Config.get()
  local alpha_enabled = opts.alpha ~= nil or config.alpha_enabled
  local initial_alpha = opts.alpha or 100

  -- Get configured keymaps
  local cfg = Config.get_keymaps()
  if opts.keymaps then
    cfg = vim.tbl_deep_extend('force', cfg, opts.keymaps)
  end

  -- Helper to get key from config
  local function get_key(name, default)
    return cfg[name] or default
  end

  -- Initialize state
  local initial = { color = initial_color }

  -- Create options for state
  local state_options = {
    initial = initial,
    on_select = opts.on_select,
    on_change = opts.on_change,
    on_cancel = opts.on_cancel,
    alpha_enabled = alpha_enabled,
    initial_alpha = initial_alpha,
    forced_mode = opts.forced_mode,
    target_filetype = opts.target_filetype,
  }

  -- Calculate initial grid size (will be recalculated on render)
  local grid_width = math.max(11, width - 4)
  local grid_height = math.max(3, height - 2)

  State.init_state(
    initial,
    state_options,
    grid_width,
    grid_height,
    1,  -- preview_rows
    vim.api.nvim_create_namespace("nvim_colorpicker_mini"),
    cfg,  -- pass resolved keymaps
    nil, -- no multipanel
    nil, -- no grid_buf
    nil  -- no grid_win
  )

  -- Build keymaps using config
  local keymaps = {}

  -- Navigation keymaps (j/k behave differently in slider mode)
  keymaps[get_key("nav_left", "h")] = function()
    local count = vim.v.count1
    Navigation.shift_hue(-count, schedule_render)
  end
  keymaps[get_key("nav_right", "l")] = function()
    local count = vim.v.count1
    Navigation.shift_hue(count, schedule_render)
  end
  keymaps[get_key("nav_up", "k")] = function()
    if slider_mode then
      slider_focus_up()
    else
      local count = vim.v.count1
      Navigation.shift_lightness(count, schedule_render)
    end
  end
  keymaps[get_key("nav_down", "j")] = function()
    if slider_mode then
      slider_focus_down()
    else
      local count = vim.v.count1
      Navigation.shift_lightness(-count, schedule_render)
    end
  end
  keymaps[get_key("sat_up", "K")] = function()
    local count = vim.v.count1
    Navigation.shift_saturation(count, schedule_render)
  end
  keymaps[get_key("sat_down", "J")] = function()
    local count = vim.v.count1
    Navigation.shift_saturation(-count, schedule_render)
  end

  -- Step size keymaps (adjust focused slider in slider mode, step size in grid mode)
  keymaps[get_key("step_down", "-")] = function()
    if slider_mode then
      local count = vim.v.count1
      adjust_focused_slider(-count)
    else
      State.decrease_step_size(schedule_render)
    end
  end
  local step_up_keys = get_key("step_up", { "+", "=" })
  if type(step_up_keys) == "table" then
    for _, k in ipairs(step_up_keys) do
      keymaps[k] = function()
        if slider_mode then
          local count = vim.v.count1
          adjust_focused_slider(count)
        else
          State.increase_step_size(schedule_render)
        end
      end
    end
  else
    keymaps[step_up_keys] = function()
      if slider_mode then
        local count = vim.v.count1
        adjust_focused_slider(count)
      else
        State.increase_step_size(schedule_render)
      end
    end
  end

  -- Mode and format keymaps
  keymaps[get_key("cycle_mode", "m")] = function()
    Navigation.cycle_mode(schedule_render)
  end
  keymaps[get_key("cycle_format", "f")] = function()
    Navigation.cycle_format(schedule_render)
  end

  -- Action keymaps
  keymaps[get_key("reset", "r")] = function()
    Navigation.reset_color(schedule_render)
  end
  keymaps[get_key("hex_input", "#")] = function()
    Navigation.enter_hex_input(schedule_render)
  end
  keymaps[get_key("apply", "<CR>")] = function()
    Actions.apply(M.close)
  end

  -- Cancel keymaps (supports array)
  local cancel_keys = get_key("cancel", { "q", "<Esc>" })
  if type(cancel_keys) == "table" then
    for _, k in ipairs(cancel_keys) do
      keymaps[k] = function()
        Actions.cancel(M.close)
      end
    end
  else
    keymaps[cancel_keys] = function()
      Actions.cancel(M.close)
    end
  end

  -- Alpha keymaps (always add if alpha is enabled)
  if alpha_enabled then
    keymaps[get_key("alpha_down", "a")] = function()
      local count = vim.v.count1
      Navigation.adjust_alpha(-count, schedule_render)
    end
    keymaps[get_key("alpha_up", "A")] = function()
      local count = vim.v.count1
      Navigation.adjust_alpha(count, schedule_render)
    end
  end

  -- Slider mode toggle
  keymaps["s"] = toggle_slider_mode

  -- Build controls definition with resolved keymaps
  local controls = build_controls_definition({
    nav_left = get_key("nav_left", "h"),
    nav_right = get_key("nav_right", "l"),
    nav_up = get_key("nav_up", "k"),
    nav_down = get_key("nav_down", "j"),
    sat_up = get_key("sat_up", "K"),
    sat_down = get_key("sat_down", "J"),
    alpha_up = get_key("alpha_up", "A"),
    alpha_down = get_key("alpha_down", "a"),
    step_down = get_key("step_down", "-"),
    cycle_mode = get_key("cycle_mode", "m"),
    cycle_format = get_key("cycle_format", "f"),
    hex_input = get_key("hex_input", "#"),
    reset = get_key("reset", "r"),
  })

  -- Create the floating window
  mini_float = UiFloat.create({
    title = build_title(),
    title_pos = "left",
    footer = "? = Controls",
    footer_pos = "right",
    width = width,
    height = height,
    relative = "cursor",
    row = row,
    col = col,
    centered = false,
    border = "rounded",
    keymaps = keymaps,
    default_keymaps = false,
    cursorline = false,
    scrollbar = false,
    filetype = "nvim-colorpicker-mini",
    controls = controls,
    on_close = function()
      State.clear_state()
      mini_float = nil
    end,
  })

  if not mini_float or not mini_float:is_valid() then
    vim.notify("nvim-colorpicker: Failed to create mini picker", vim.log.levels.ERROR)
    return
  end

  -- Initial render
  render()
end

---Open the mini color picker in slider mode
---@param opts table Options (same as pick)
function M.pick_slider(opts)
  -- First open normally
  M.pick(opts)

  -- Then switch to slider mode
  slider_mode = true
  slider_focus = 1
  schedule_render()
end

---Check if currently in slider mode
---@return boolean
function M.is_slider_mode()
  return slider_mode
end

return M
