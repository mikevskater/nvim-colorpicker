---@module 'nvim-colorpicker.picker.mini'
---@brief Compact inline color picker

local State = require('nvim-colorpicker.picker.state')
local Grid = require('nvim-colorpicker.picker.grid')
local Preview = require('nvim-colorpicker.picker.preview')
local Navigation = require('nvim-colorpicker.picker.navigation')
local Actions = require('nvim-colorpicker.picker.actions')
local Format = require('nvim-colorpicker.picker.format')
local ColorUtils = require('nvim-colorpicker.color')
local Config = require('nvim-colorpicker.config')
local UiFloat = require('nvim-float.float')

local M = {}

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
      header = "Navigation",
      keys = {
        { key = cfg.nav_left .. "/" .. cfg.nav_right, desc = "Adjust hue (left/right)" },
        { key = cfg.nav_down .. "/" .. cfg.nav_up, desc = "Adjust lightness (down/up)" },
        { key = cfg.sat_down .. "/" .. cfg.sat_up, desc = "Adjust saturation" },
        { key = cfg.alpha_down .. "/" .. cfg.alpha_up, desc = "Adjust alpha (if enabled)" },
        { key = cfg.step_down .. "/+", desc = "Decrease/increase step size" },
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

  -- Render grid rows (no padding - edge to edge)
  for row_idx, row in ipairs(grid) do
    local line = ""
    for col_idx, _ in ipairs(row) do
      if row_idx == center_row and col_idx == center_col then
        line = line .. "x"
      else
        line = line .. " "
      end
    end
    table.insert(lines, line)

    -- Add highlights for each cell
    for col_idx, _ in ipairs(row) do
      local hl_name = Grid.get_cell_hl_group(row_idx, col_idx)
      table.insert(highlights, {
        line = row_idx - 1 + line_offset,
        col_start = col_idx - 1,
        col_end = col_idx,
        hl_group = hl_name,
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

  local lines, highlights = render_content(inner_width, inner_height)

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
-- Public API
-- ============================================================================

---Close the mini picker
function M.close()
  local state = State.state

  if state then
    Actions.cleanup_highlights(state.grid_height, state.grid_width)
  end

  State.clear_state()

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

  -- Calculate cursor-relative position
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local win_pos = vim.api.nvim_win_get_position(0)
  local cursor_screen_row = win_pos[1] + cursor_pos[1]
  local cursor_screen_col = win_pos[2] + cursor_pos[2]

  -- Smart positioning: prefer below-right, but adjust if near edges
  local row = 1  -- Below cursor
  local col = 1  -- Right of cursor

  -- Check if window would go off bottom
  if cursor_screen_row + height + 3 > ui.height then
    row = -height - 1  -- Above cursor
  end

  -- Check if window would go off right
  if cursor_screen_col + width + 2 > ui.width then
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

  -- Navigation keymaps
  keymaps[get_key("nav_left", "h")] = function()
    local count = vim.v.count1
    Navigation.shift_hue(-count, schedule_render)
  end
  keymaps[get_key("nav_right", "l")] = function()
    local count = vim.v.count1
    Navigation.shift_hue(count, schedule_render)
  end
  keymaps[get_key("nav_up", "k")] = function()
    local count = vim.v.count1
    Navigation.shift_lightness(count, schedule_render)
  end
  keymaps[get_key("nav_down", "j")] = function()
    local count = vim.v.count1
    Navigation.shift_lightness(-count, schedule_render)
  end
  keymaps[get_key("sat_up", "K")] = function()
    local count = vim.v.count1
    Navigation.shift_saturation(count, schedule_render)
  end
  keymaps[get_key("sat_down", "J")] = function()
    local count = vim.v.count1
    Navigation.shift_saturation(-count, schedule_render)
  end

  -- Step size keymaps
  keymaps[get_key("step_down", "-")] = function()
    State.decrease_step_size(schedule_render)
  end
  local step_up_keys = get_key("step_up", { "+", "=" })
  if type(step_up_keys) == "table" then
    for _, k in ipairs(step_up_keys) do
      keymaps[k] = function()
        State.increase_step_size(schedule_render)
      end
    end
  else
    keymaps[step_up_keys] = function()
      State.increase_step_size(schedule_render)
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

return M
