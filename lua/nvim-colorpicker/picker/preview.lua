---@module 'nvim-colorpicker.picker.preview'
---@brief Preview section rendering for the color picker

local Types = require('nvim-colorpicker.picker.types')
local State = require('nvim-colorpicker.picker.state')

local M = {}

-- ============================================================================
-- Local References
-- ============================================================================

local PADDING = Types.PADDING
local ALPHA_CHARS = Types.ALPHA_CHARS

-- ============================================================================
-- Alpha Visualization
-- ============================================================================

---Get the alpha visualization character for a given alpha value
---@param alpha number Alpha value 0-100
---@return string char The character representing the alpha level
function M.get_alpha_char(alpha)
  for _, def in ipairs(ALPHA_CHARS) do
    if alpha >= def.min and alpha <= def.max then
      return def.char
    end
  end
  return "█"
end

-- ============================================================================
-- Preview Rendering
-- ============================================================================

---Render the split Original/Current preview section
---@return string[] lines
---@return table[] highlights
function M.render_preview()
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

  local orig_char = M.get_alpha_char(orig_alpha)
  local curr_char = M.get_alpha_char(curr_alpha)

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

---Clear preview highlight groups
function M.clear_preview_highlights()
  pcall(vim.api.nvim_set_hl, 0, "NvimColorPickerPreview", {})
  pcall(vim.api.nvim_set_hl, 0, "NvimColorPickerOriginalPreview", {})
  pcall(vim.api.nvim_set_hl, 0, "NvimColorPickerCurrentPreview", {})
end

return M
