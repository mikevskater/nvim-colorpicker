---@module 'nvim-colorpicker.history'
---@brief Color history and clipboard integration

local M = {}

local utils = require('nvim-colorpicker.color')

-- ============================================================================
-- State
-- ============================================================================

---@type string[] Recent colors (most recent first)
local recent_colors = {}

---@type number Maximum colors to track
local max_recent = 10

-- ============================================================================
-- Recent Colors
-- ============================================================================

---Add a color to recent history
---@param hex string Hex color
function M.add_recent(hex)
  if not hex or not utils.is_valid_hex(hex) then return end

  hex = utils.normalize_hex(hex)

  -- Remove if already exists (to move to front)
  for i = #recent_colors, 1, -1 do
    if recent_colors[i] == hex then
      table.remove(recent_colors, i)
    end
  end

  -- Add to front
  table.insert(recent_colors, 1, hex)

  -- Trim to max size
  while #recent_colors > max_recent do
    table.remove(recent_colors)
  end
end

---Get recent colors
---@param count number? Maximum colors to return (default: all)
---@return string[] colors Recent hex colors (most recent first)
function M.get_recent(count)
  count = count or #recent_colors
  local result = {}
  for i = 1, math.min(count, #recent_colors) do
    table.insert(result, recent_colors[i])
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
    recent_colors = data.recent
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
