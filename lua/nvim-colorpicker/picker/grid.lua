---@module 'nvim-colorpicker.picker.grid'
---@brief Grid generation and rendering for the color picker

local Types = require('nvim-colorpicker.picker.types')
local State = require('nvim-colorpicker.picker.state')
local ColorUtils = require('nvim-colorpicker.color')

local M = {}

-- ============================================================================
-- Local References
-- ============================================================================

local PADDING = Types.PADDING
local HEADER_HEIGHT = Types.HEADER_HEIGHT
local PREVIEW_BORDERS = Types.PREVIEW_BORDERS
local PREVIEW_RATIO = Types.PREVIEW_RATIO
local BASE_STEP_HUE = Types.BASE_STEP_HUE
local BASE_STEP_LIGHTNESS = Types.BASE_STEP_LIGHTNESS

-- ============================================================================
-- Grid Utilities
-- ============================================================================

---Map a virtual position to actual 0-100 value with bounce (triangular wave)
---@param virtual number Virtual position (unbounded)
---@return number actual Actual value (0-100)
function M.virtual_to_actual(virtual)
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
function M.calculate_grid_size(win_width, win_height)
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
function M.get_cell_hl_group(row, col)
  return string.format("NvimColorPickerCell_%d_%d", row, col)
end

-- ============================================================================
-- Grid Generation
-- ============================================================================

---Generate color grid with virtual lightness positions for continuous scrolling
---@return string[][] grid 2D array of hex colors [row][col]
function M.generate_virtual_grid()
  local state = State.state
  if not state then return {} end

  local center_color = State.get_active_color()
  local h, s, l = ColorUtils.hex_to_hsl(center_color)

  if state.saved_hsl and (l < 2 or l > 98) then
    h = state.saved_hsl.h
    s = state.saved_hsl.s
  end

  local virtual_l = state.lightness_virtual or l

  local grid = {}
  local half_height = math.floor(state.grid_height / 2)
  local half_width = math.floor(state.grid_width / 2)
  local hue_step = BASE_STEP_HUE * State.get_step_multiplier()
  local lightness_step = BASE_STEP_LIGHTNESS * State.get_step_multiplier()

  for row = 1, state.grid_height do
    local row_colors = {}
    local row_offset = half_height + 1 - row
    local row_virtual_l = virtual_l + (row_offset * lightness_step)
    local row_actual_l = M.virtual_to_actual(row_virtual_l)

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

---Create highlight groups for the color grid
---@param grid string[][] The color grid
function M.create_grid_highlights(grid)
  local state = State.state
  if not state then return end

  local center_row = math.ceil(#grid / 2)
  local center_col = math.ceil(#grid[1] / 2)

  for row_idx, row in ipairs(grid) do
    for col_idx, color in ipairs(row) do
      local hl_name = M.get_cell_hl_group(row_idx, col_idx)
      local hl_def

      if row_idx == center_row and col_idx == center_col then
        -- Center cell: use bg color with contrasting fg for cursor marker
        hl_def = {
          fg = ColorUtils.get_contrast_color(color),
          bg = color,
          bold = true,
        }
      else
        -- Non-center cells: use fg color with block character (fixes VHS rendering)
        hl_def = { fg = color }
      end

      vim.api.nvim_set_hl(0, hl_name, hl_def)
    end
  end
end

---Render the color grid to buffer
---@return string[] lines
---@return table[] highlights
function M.render_grid()
  local state = State.state
  if not state then return {}, {} end

  local lines = {}
  local highlights = {}

  local grid = M.generate_virtual_grid()
  M.create_grid_highlights(grid)

  local center_row = math.ceil(#grid / 2)
  local center_col = math.ceil(#grid[1] / 2)

  local pad = string.rep(" ", PADDING)

  -- Character constants with their byte lengths
  local BLOCK_CHAR = "█"
  local BLOCK_CHAR_LEN = #BLOCK_CHAR  -- 3 bytes in UTF-8
  local CURSOR_CHAR = "X"
  local CURSOR_CHAR_LEN = #CURSOR_CHAR  -- 1 byte

  for row_idx, row in ipairs(grid) do
    local line_chars = {}
    local line_hls = {}
    local byte_pos = PADDING  -- Start after padding (spaces are 1 byte each)

    for col_idx, _ in ipairs(row) do
      local char, char_len
      if row_idx == center_row and col_idx == center_col then
        char = CURSOR_CHAR
        char_len = CURSOR_CHAR_LEN
      else
        char = BLOCK_CHAR
        char_len = BLOCK_CHAR_LEN
      end
      table.insert(line_chars, char)

      table.insert(line_hls, {
        col_start = byte_pos,
        col_end = byte_pos + char_len,
        hl_group = M.get_cell_hl_group(row_idx, col_idx),
      })

      byte_pos = byte_pos + char_len
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

---Clear grid highlight groups
---@param grid_height number
---@param grid_width number
function M.clear_grid_highlights(grid_height, grid_width)
  for row = 1, grid_height do
    for col = 1, grid_width do
      pcall(vim.api.nvim_set_hl, 0, M.get_cell_hl_group(row, col), {})
    end
  end
end

return M
