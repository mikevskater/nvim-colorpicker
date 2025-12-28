---@module 'nvim-colorpicker.picker.mini'
---@brief Compact inline color picker

local State = require('nvim-colorpicker.picker.state')
local Grid = require('nvim-colorpicker.picker.grid')
local Preview = require('nvim-colorpicker.picker.preview')
local Navigation = require('nvim-colorpicker.picker.navigation')
local ColorUtils = require('nvim-colorpicker.color')
local Types = require('nvim-colorpicker.picker.types')
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
local MINI_CONTROLS = {
  {
    header = "Navigation",
    keys = {
      { key = "h/l", desc = "Adjust hue (left/right)" },
      { key = "j/k", desc = "Adjust lightness (down/up)" },
      { key = "J/K", desc = "Adjust saturation" },
      { key = "a/A", desc = "Adjust alpha (if enabled)" },
      { key = "-/+", desc = "Decrease/increase step size" },
    },
  },
  {
    header = "Display",
    keys = {
      { key = "m", desc = "Cycle color mode (hex/hsl/rgb/hsv/cmyk)" },
      { key = "f", desc = "Toggle value format (percent/decimal)" },
      { key = "#", desc = "Enter hex color directly" },
    },
  },
  {
    header = "Actions",
    keys = {
      { key = "r", desc = "Reset to original color" },
      { key = "Enter", desc = "Apply color and close" },
      { key = "q/Esc", desc = "Cancel and close" },
    },
  },
}

-- ============================================================================
-- Header Formatting
-- ============================================================================

-- Mini picker color modes (includes hex)
local MINI_COLOR_MODES = { "hex", "hsl", "rgb", "hsv", "cmyk" }

---Format color value for header based on current mode and value format
---@param hex string The hex color
---@param mode string Color mode (hex, hsl, rgb, hsv, cmyk)
---@param alpha number? Alpha value 0-100
---@param alpha_enabled boolean Whether alpha is enabled
---@param value_format "standard"|"decimal" Value display format
---@return string formatted The formatted color string
local function format_header_color(hex, mode, alpha, alpha_enabled, value_format)
  local r, g, b = ColorUtils.hex_to_rgb(hex)
  local h, s, l = ColorUtils.hex_to_hsl(hex)
  local hv, sv, v = ColorUtils.hex_to_hsv(hex)
  local c, m, y, k = ColorUtils.hex_to_cmyk(hex)

  local is_decimal = value_format == "decimal"

  -- Alpha as 0-255 for hex, 0-100 for others, 0.0-1.0 for decimal
  local alpha_hex = alpha_enabled and string.format("%02X", math.floor((alpha / 100) * 255 + 0.5)) or ""

  if mode == "hex" then
    if alpha_enabled then
      return hex .. alpha_hex
    else
      return hex
    end
  elseif mode == "hsl" then
    if is_decimal then
      local hd, sd, ld = h / 360, s / 100, l / 100
      local ad = alpha / 100
      if alpha_enabled then
        return string.format("hsla(%.2f, %.2f, %.2f, %.2f)", hd, sd, ld, ad)
      else
        return string.format("hsl(%.2f, %.2f, %.2f)", hd, sd, ld)
      end
    else
      if alpha_enabled then
        return string.format("hsla(%d, %d%%, %d%%, %d%%)", math.floor(h), math.floor(s), math.floor(l), alpha)
      else
        return string.format("hsl(%d, %d%%, %d%%)", math.floor(h), math.floor(s), math.floor(l))
      end
    end
  elseif mode == "rgb" then
    if is_decimal then
      local rd, gd, bd = r / 255, g / 255, b / 255
      local ad = alpha / 100
      if alpha_enabled then
        return string.format("rgba(%.2f, %.2f, %.2f, %.2f)", rd, gd, bd, ad)
      else
        return string.format("rgb(%.2f, %.2f, %.2f)", rd, gd, bd)
      end
    else
      if alpha_enabled then
        return string.format("rgba(%d, %d, %d, %d%%)", r, g, b, alpha)
      else
        return string.format("rgb(%d, %d, %d)", r, g, b)
      end
    end
  elseif mode == "hsv" then
    if is_decimal then
      local hvd, svd, vd = hv / 360, sv / 100, v / 100
      local ad = alpha / 100
      if alpha_enabled then
        return string.format("hsva(%.2f, %.2f, %.2f, %.2f)", hvd, svd, vd, ad)
      else
        return string.format("hsv(%.2f, %.2f, %.2f)", hvd, svd, vd)
      end
    else
      if alpha_enabled then
        return string.format("hsva(%d, %d%%, %d%%, %d%%)", math.floor(hv), math.floor(sv), math.floor(v), alpha)
      else
        return string.format("hsv(%d, %d%%, %d%%)", math.floor(hv), math.floor(sv), math.floor(v))
      end
    end
  elseif mode == "cmyk" then
    if is_decimal then
      local cd, md, yd, kd = c / 100, m / 100, y / 100, k / 100
      return string.format("cmyk(%.2f, %.2f, %.2f, %.2f)", cd, md, yd, kd)
    else
      return string.format("cmyk(%d, %d, %d, %d)", math.floor(c), math.floor(m), math.floor(y), math.floor(k))
    end
  else
    -- Fallback to hex
    if alpha_enabled then
      return hex .. alpha_hex
    else
      return hex
    end
  end
end

---Cycle through mini picker color modes
---@param schedule_render fun() Function to schedule a render
local function cycle_mini_mode(schedule_render)
  local state = State.state
  if not state then return end

  local current_idx = 1
  for i, mode in ipairs(MINI_COLOR_MODES) do
    if mode == state.color_mode then
      current_idx = i
      break
    end
  end

  local next_idx = (current_idx % #MINI_COLOR_MODES) + 1
  state.color_mode = MINI_COLOR_MODES[next_idx]
  schedule_render()
end

---Build the title string with color and step size
---@return string title
local function build_title()
  local state = State.state
  if not state then return "Pick Color" end

  local color_str = format_header_color(
    state.current.color,
    state.color_mode,
    state.alpha,
    state.alpha_enabled,
    state.value_format or "standard"
  )
  local step_label = State.get_step_label()

  return string.format(" %s | %s ", color_str, step_label)
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
end

---Schedule a render
local function schedule_render()
  vim.schedule(render)
end

-- ============================================================================
-- Actions
-- ============================================================================

---Apply and close
local function apply()
  local state = State.state
  if not state then return end

  local result = vim.deepcopy(state.current)
  result.alpha = state.alpha_enabled and state.alpha or nil
  local on_select = state.options.on_select

  M.close()

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

  M.close()
end

-- ============================================================================
-- Public API
-- ============================================================================

---Close the mini picker
function M.close()
  local state = State.state

  if state then
    local grid_height = state.grid_height or 5
    local grid_width = state.grid_width or 15
    Grid.clear_grid_highlights(grid_height, grid_width)
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

  -- Initialize state
  local initial = { color = initial_color }

  -- Create minimal options for state
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
    {},  -- keymaps (use defaults)
    nil, -- no multipanel
    nil, -- no grid_buf
    nil  -- no grid_win
  )

  -- Build keymaps
  local keymaps = {
    ["h"] = function()
      local count = vim.v.count1
      Navigation.shift_hue(-count, schedule_render)
    end,
    ["l"] = function()
      local count = vim.v.count1
      Navigation.shift_hue(count, schedule_render)
    end,
    ["k"] = function()
      local count = vim.v.count1
      Navigation.shift_lightness(count, schedule_render)
    end,
    ["j"] = function()
      local count = vim.v.count1
      Navigation.shift_lightness(-count, schedule_render)
    end,
    ["K"] = function()
      local count = vim.v.count1
      Navigation.shift_saturation(count, schedule_render)
    end,
    ["J"] = function()
      local count = vim.v.count1
      Navigation.shift_saturation(-count, schedule_render)
    end,
    ["-"] = function()
      State.decrease_step_size(schedule_render)
    end,
    ["+"] = function()
      State.increase_step_size(schedule_render)
    end,
    ["="] = function()
      State.increase_step_size(schedule_render)
    end,
    ["m"] = function()
      cycle_mini_mode(schedule_render)
    end,
    ["f"] = function()
      Navigation.cycle_format(schedule_render)
    end,
    ["r"] = function()
      Navigation.reset_color(schedule_render)
    end,
    ["#"] = function()
      Navigation.enter_hex_input(schedule_render)
    end,
    ["<CR>"] = apply,
    ["q"] = cancel,
    ["<Esc>"] = cancel,
  }

  -- Add alpha keymaps if enabled
  if alpha_enabled then
    keymaps["a"] = function()
      local count = vim.v.count1
      Navigation.adjust_alpha(-count, schedule_render)
    end
    keymaps["A"] = function()
      local count = vim.v.count1
      Navigation.adjust_alpha(count, schedule_render)
    end
  end

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
    controls = MINI_CONTROLS,
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
