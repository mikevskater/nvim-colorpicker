---@module 'nvim-colorpicker.color.grid'
---@brief Color grid generation for the color picker

local manipulation = require('nvim-colorpicker.color.manipulation')

local M = {}

---Default step sizes for color navigation
M.STEPS = {
  hue = 3,        -- degrees per step
  saturation = 2, -- percent per step
  lightness = 2,  -- percent per step
}

---Generate a row of colors varying by hue
---@param base_hex string Center color
---@param count number Total colors in row (should be odd)
---@param hue_step number Hue change per cell
---@param lightness_offset number Additional lightness offset for this row
---@param saturation_offset number Additional saturation offset
---@return string[] colors Array of hex colors
function M.generate_hue_row(base_hex, count, hue_step, lightness_offset, saturation_offset)
  local colors = {}
  local half = math.floor(count / 2)

  for i = 1, count do
    local hue_offset = (i - half - 1) * hue_step
    local color = manipulation.get_offset_color(base_hex, hue_offset, lightness_offset, saturation_offset)
    table.insert(colors, color)
  end

  return colors
end

---Generate full color grid
---@param center_hex string Center color of grid
---@param width number Grid width (columns, should be odd)
---@param height number Grid height (rows, should be odd)
---@param hue_step number Hue change per horizontal cell
---@param lightness_step number Lightness change per vertical cell
---@return string[][] grid 2D array of hex colors [row][col]
function M.generate_color_grid(center_hex, width, height, hue_step, lightness_step)
  local grid = {}
  local half_height = math.floor(height / 2)

  for row = 1, height do
    local lightness_offset = (half_height + 1 - row) * lightness_step
    local row_colors = M.generate_hue_row(center_hex, width, hue_step, lightness_offset, 0)
    table.insert(grid, row_colors)
  end

  return grid
end

return M
