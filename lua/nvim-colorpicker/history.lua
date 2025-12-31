---@module 'nvim-colorpicker.history'
---@brief Color history and clipboard integration

local M = {}

local utils = require('nvim-colorpicker.color')

-- ============================================================================
-- Types
-- ============================================================================

---@class HistoryItem
---@field hex string Hex color value
---@field alpha number Alpha value (0-100 percentage)
---@field format string? Original color format ("hex"|"rgb"|"hsl"|"hsv")

-- ============================================================================
-- State
-- ============================================================================

---@type HistoryItem[] Recent colors (most recent first)
local recent_colors = {}

---@type number Maximum colors to track
local max_recent = 10

-- ============================================================================
-- Recent Colors
-- ============================================================================

---Add a color to recent history
---@param hex string Hex color
---@param alpha number? Alpha value (0-100 percentage, default: 100)
---@param format string? Original color format ("hex"|"rgb"|"hsl"|"hsv")
function M.add_recent(hex, alpha, format)
  if not hex or not utils.is_valid_hex(hex) then return end

  hex = utils.normalize_hex(hex)
  alpha = alpha or 100

  -- Remove if already exists (to move to front)
  for i = #recent_colors, 1, -1 do
    local item = recent_colors[i]
    -- Handle both old string format and new table format
    local item_hex = type(item) == "table" and item.hex or item
    if item_hex == hex then
      table.remove(recent_colors, i)
    end
  end

  -- Add to front as table with hex, alpha, and format
  table.insert(recent_colors, 1, { hex = hex, alpha = alpha, format = format })

  -- Trim to max size
  while #recent_colors > max_recent do
    table.remove(recent_colors)
  end
end

---Get recent colors with alpha values
---@param count number? Maximum colors to return (default: all)
---@return HistoryItem[] items Recent colors with alpha (most recent first)
function M.get_recent(count)
  count = count or #recent_colors
  local result = {}
  for i = 1, math.min(count, #recent_colors) do
    local item = recent_colors[i]
    -- Handle both old string format and new table format for backwards compatibility
    if type(item) == "string" then
      table.insert(result, { hex = item, alpha = 100 })
    else
      table.insert(result, item)
    end
  end
  return result
end

---Get recent hex colors only (convenience method)
---@param count number? Maximum colors to return (default: all)
---@return string[] colors Recent hex colors (most recent first)
function M.get_recent_hex(count)
  local items = M.get_recent(count)
  local result = {}
  for _, item in ipairs(items) do
    table.insert(result, item.hex)
  end
  return result
end

---Clear recent colors
function M.clear_recent()
  recent_colors = {}
end

---Set maximum recent colors to track
---@param count number Maximum count
function M.set_max_recent(count)
  max_recent = count or 10
  -- Trim if needed
  while #recent_colors > max_recent do
    table.remove(recent_colors)
  end
end

---Get recent colors count
---@return number count
function M.get_recent_count()
  return #recent_colors
end

-- ============================================================================
-- Clipboard Integration
-- ============================================================================

---Copy color to system clipboard
---@param hex string Hex color
---@param format "hex"|"rgb"|"hsl"|"hsv"? Format (default: hex)
function M.yank(hex, format)
  if not hex or not utils.is_valid_hex(hex) then
    vim.notify("Invalid color to copy", vim.log.levels.WARN)
    return
  end

  hex = utils.normalize_hex(hex)
  local text = hex

  -- Convert to requested format
  if format and format ~= "hex" then
    text = utils.convert_format(hex, format) or hex
  end

  -- Copy to clipboard
  vim.fn.setreg('+', text)
  vim.fn.setreg('"', text)

  vim.notify("Copied: " .. text, vim.log.levels.INFO)
end

---Paste color from system clipboard
---@return string? hex Parsed hex color or nil
function M.paste()
  local text = vim.fn.getreg('+')
  if not text or text == "" then
    text = vim.fn.getreg('"')
  end

  if not text or text == "" then
    vim.notify("Clipboard is empty", vim.log.levels.WARN)
    return nil
  end

  -- Try to parse as color
  local hex = utils.parse_color_string(text:match("^%s*(.-)%s*$"))
  if hex then
    vim.notify("Pasted: " .. hex, vim.log.levels.INFO)
    return hex
  end

  vim.notify("Clipboard does not contain a valid color: " .. text, vim.log.levels.WARN)
  return nil
end

---Copy current color at cursor to clipboard
---@param format "hex"|"rgb"|"hsl"|"hsv"? Format (default: hex)
function M.yank_at_cursor(format)
  local detect = require('nvim-colorpicker.detect')
  local color_info = detect.get_color_at_cursor()

  if not color_info then
    vim.notify("No color at cursor", vim.log.levels.WARN)
    return
  end

  M.yank(color_info.color, format)
end

-- ============================================================================
-- Persistence (Optional)
-- ============================================================================

---Get data for persistence
---@return table data
function M.get_persist_data()
  return {
    recent = recent_colors,
  }
end

---Restore from persisted data
---@param data table
function M.restore_persist_data(data)
  if data and data.recent then
    -- Convert old string format to new table format if needed
    recent_colors = {}
    for _, item in ipairs(data.recent) do
      if type(item) == "string" then
        table.insert(recent_colors, { hex = item, alpha = 100 })
      else
        table.insert(recent_colors, item)
      end
    end
    -- Trim to max
    while #recent_colors > max_recent do
      table.remove(recent_colors)
    end
  end
end

---Save history to file (optional)
---@param path string? File path (default: stdpath cache)
function M.save(path)
  path = path or vim.fn.stdpath('cache') .. '/nvim-colorpicker-history.json'

  local data = M.get_persist_data()
  local json = vim.fn.json_encode(data)

  local file = io.open(path, 'w')
  if file then
    file:write(json)
    file:close()
  end
end

---Load history from file (optional)
---@param path string? File path (default: stdpath cache)
function M.load(path)
  path = path or vim.fn.stdpath('cache') .. '/nvim-colorpicker-history.json'

  local file = io.open(path, 'r')
  if not file then return end

  local content = file:read('*all')
  file:close()

  if content and content ~= "" then
    local ok, data = pcall(vim.fn.json_decode, content)
    if ok and data then
      M.restore_persist_data(data)
    end
  end
end

return M
