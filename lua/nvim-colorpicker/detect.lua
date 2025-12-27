---@module 'nvim-colorpicker.detect'
---@brief Cursor color detection and replacement
---
---This module handles detecting colors in buffer text and replacing them.

local M = {}

local utils = require('nvim-colorpicker.utils')

-- Color patterns to detect (order matters - more specific patterns first)
local PATTERNS = {
  -- Vim highlight guifg/guibg (must come before hex to avoid double-matching)
  { pattern = "gui[fb]g=#%x%x%x%x%x%x", format = "vim" },

  -- CSS rgb/rgba
  { pattern = "rgba?%s*%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*[,/]?%s*[%d%.]*%s*%)", format = "rgb" },

  -- CSS hsl/hsla
  { pattern = "hsla?%s*%(%s*%d+%s*,%s*%d+%%%s*,%s*%d+%%%s*[,/]?%s*[%d%.]*%s*%)", format = "hsl" },

  -- Hex colors: #RGB, #RRGGBB, #RRGGBBAA (least specific, check last)
  { pattern = "#%x%x%x%x%x%x%x%x", format = "hex8" },
  { pattern = "#%x%x%x%x%x%x", format = "hex" },
  { pattern = "#%x%x%x", format = "hex3" },
}

---@class NvimColorPickerColorInfo
---@field color string The parsed hex color (without alpha)
---@field start_col number Start column (0-indexed)
---@field end_col number End column (0-indexed)
---@field format string Original format type
---@field original string Original matched string
---@field line number Line number (1-indexed)
---@field alpha number? Alpha value 0-100 (nil means opaque/100)

---Extract alpha value from a color string
---@param matched string The matched color string
---@param format string The format type
---@return number? alpha Alpha value 0-100, or nil if no alpha
local function extract_alpha(matched, format)
  if format == "hex8" then
    -- #RRGGBBAA - last two chars are alpha (00-FF -> 0-100)
    local alpha_hex = matched:sub(8, 9)
    local alpha_int = tonumber(alpha_hex, 16)
    if alpha_int then
      return math.floor((alpha_int / 255) * 100 + 0.5)
    end
  elseif format == "rgb" then
    -- rgba(r, g, b, a) - alpha is 0-1 decimal
    local alpha = matched:match("rgba%s*%([^,]+,[^,]+,[^,]+[,/]%s*([%d%.]+)%s*%)")
    if alpha then
      return math.floor(tonumber(alpha) * 100 + 0.5)
    end
  elseif format == "hsl" then
    -- hsla(h, s%, l%, a) - alpha is 0-1 decimal
    local alpha = matched:match("hsla%s*%([^,]+,[^,]+,[^,]+[,/]%s*([%d%.]+)%s*%)")
    if alpha then
      return math.floor(tonumber(alpha) * 100 + 0.5)
    end
  end
  return nil
end

---Get color at cursor position
---@return NvimColorPickerColorInfo? color_info Color info or nil if no color found
function M.get_color_at_cursor()
  local line = vim.api.nvim_get_current_line()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1]
  local col = cursor[2] -- 0-indexed

  -- Try each pattern
  for _, pat_info in ipairs(PATTERNS) do
    local start_pos = 1
    while true do
      local match_start, match_end = line:find(pat_info.pattern, start_pos)
      if not match_start then break end

      -- Check if cursor is within this match (convert to 0-indexed)
      local start_col = match_start - 1
      local end_col = match_end

      if col >= start_col and col < end_col then
        local matched = line:sub(match_start, match_end)
        local hex = M.parse_to_hex(matched, pat_info.format)

        if hex then
          return {
            color = hex,
            start_col = start_col,
            end_col = end_col,
            format = pat_info.format,
            original = matched,
            line = row,
            alpha = extract_alpha(matched, pat_info.format),
          }
        end
      end

      start_pos = match_end + 1
    end
  end

  return nil
end

---Get all colors in a line
---@param line string? Line content (defaults to current line)
---@param row number? Line number (defaults to cursor row)
---@return NvimColorPickerColorInfo[] colors Array of color info
function M.get_colors_in_line(line, row)
  line = line or vim.api.nvim_get_current_line()
  row = row or vim.api.nvim_win_get_cursor(0)[1]
  local colors = {}
  local covered = {} -- Track which positions are already covered

  for _, pat_info in ipairs(PATTERNS) do
    local start_pos = 1
    while true do
      local match_start, match_end = line:find(pat_info.pattern, start_pos)
      if not match_start then break end

      -- Check if this position is already covered by a previous match
      local already_covered = false
      for _, range in ipairs(covered) do
        -- Skip if this match overlaps with an existing one
        if match_start >= range[1] and match_start <= range[2] then
          already_covered = true
          break
        end
      end

      if not already_covered then
        local matched = line:sub(match_start, match_end)
        local hex = M.parse_to_hex(matched, pat_info.format)

        if hex then
          table.insert(colors, {
            color = hex,
            start_col = match_start - 1,
            end_col = match_end,
            format = pat_info.format,
            original = matched,
            line = row,
          })
          table.insert(covered, { match_start, match_end })
        end
      end

      start_pos = match_end + 1
    end
  end

  return colors
end

---Parse matched string to hex color
---@param matched string The matched string
---@param format string The format type
---@return string? hex Hex color or nil
function M.parse_to_hex(matched, format)
  if format == "hex" then
    return utils.normalize_hex(matched)
  elseif format == "hex3" then
    -- Expand #RGB to #RRGGBB
    local short = matched:gsub("^#", "")
    if #short == 3 then
      local expanded = short:sub(1, 1):rep(2) .. short:sub(2, 2):rep(2) .. short:sub(3, 3):rep(2)
      return "#" .. expanded:upper()
    end
  elseif format == "hex8" then
    -- Strip alpha from #RRGGBBAA
    return "#" .. matched:sub(2, 7):upper()
  elseif format == "rgb" then
    -- Match both rgb() and rgba() - extract first 3 numbers
    local r, g, b = matched:match("rgba?%s*%(%s*(%d+)%s*[,/]?%s*(%d+)%s*[,/]?%s*(%d+)")
    if r and g and b then
      return utils.rgb_to_hex(tonumber(r), tonumber(g), tonumber(b))
    end
  elseif format == "hsl" then
    -- Match both hsl() and hsla() - extract h, s%, l%
    local h, s, l = matched:match("hsla?%s*%(%s*(%d+)%s*[,/]?%s*(%d+)%%%s*[,/]?%s*(%d+)%%")
    if h and s and l then
      return utils.hsl_to_hex(tonumber(h), tonumber(s), tonumber(l))
    end
  elseif format == "vim" then
    local hex = matched:match("#(%x%x%x%x%x%x)")
    if hex then
      return "#" .. hex:upper()
    end
  end

  return nil
end

---Format hex color to target format
---@param hex string Hex color
---@param format string Target format
---@param alpha number? Alpha value 0-100 (nil or 100 means opaque)
---@return string formatted Formatted color string
function M.format_color(hex, format, alpha)
  local has_alpha = alpha and alpha < 100

  if format == "hex8" then
    -- Always output with alpha for hex8 format
    local alpha_val = alpha or 100
    local alpha_hex = string.format("%02X", math.floor((alpha_val / 100) * 255 + 0.5))
    return hex .. alpha_hex
  elseif format == "hex" or format == "hex3" then
    -- For hex/hex3, only add alpha if present and not fully opaque
    if has_alpha then
      local alpha_hex = string.format("%02X", math.floor((alpha / 100) * 255 + 0.5))
      return hex .. alpha_hex
    end
    return hex
  elseif format == "rgb" then
    local r, g, b = utils.hex_to_rgb(hex)
    if has_alpha then
      return string.format("rgba(%d, %d, %d, %.2f)",
        math.floor(r + 0.5), math.floor(g + 0.5), math.floor(b + 0.5), alpha / 100)
    end
    return string.format("rgb(%d, %d, %d)", math.floor(r + 0.5), math.floor(g + 0.5), math.floor(b + 0.5))
  elseif format == "hsl" then
    local h, s, l = utils.hex_to_hsl(hex)
    if has_alpha then
      return string.format("hsla(%d, %d%%, %d%%, %.2f)",
        math.floor(h + 0.5), math.floor(s + 0.5), math.floor(l + 0.5), alpha / 100)
    end
    return string.format("hsl(%d, %d%%, %d%%)", math.floor(h + 0.5), math.floor(s + 0.5), math.floor(l + 0.5))
  elseif format == "vim" then
    -- Preserve guifg= or guibg= prefix (vim doesn't support alpha)
    return hex
  end

  return hex
end

---Replace color at cursor with new color
---@param new_color string New hex color
---@param color_info NvimColorPickerColorInfo Original color info from get_color_at_cursor
---@param alpha number? Alpha value 0-100 (nil means use original or 100)
function M.replace_color_at_cursor(new_color, color_info, alpha)
  if not color_info then return end

  -- Format the new color to match original format
  local formatted
  if color_info.format == "vim" then
    -- Preserve guifg= or guibg= prefix (vim doesn't support alpha)
    local prefix = color_info.original:match("^(gui[fb]g=)")
    formatted = (prefix or "") .. new_color
  else
    formatted = M.format_color(new_color, color_info.format, alpha)
  end

  -- Get the line and replace
  local line = vim.api.nvim_get_current_line()
  local new_line = line:sub(1, color_info.start_col) .. formatted .. line:sub(color_info.end_col + 1)

  vim.api.nvim_set_current_line(new_line)
end

return M
