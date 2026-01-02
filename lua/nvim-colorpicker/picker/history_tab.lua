---@module 'nvim-colorpicker.picker.history_tab'
---@brief History tab rendering for the color picker

local State = require('nvim-colorpicker.picker.state')
local History = require('nvim-colorpicker.history')
local ColorUtils = require('nvim-colorpicker.color')
local ContentBuilder = require('nvim-float.content_builder')

local M = {}

-- Store ContentBuilder for element tracking
M._content_builder = nil

-- ============================================================================
-- Constants
-- ============================================================================

---@type number Maximum history items to display
local MAX_DISPLAY_ITEMS = 10

---@type string Swatch characters (same block char as grid, multiple wide)
local SWATCH_TEXT = "█████"

-- ============================================================================
-- Extmark Namespace
-- ============================================================================

---@type number Namespace for swatch extmarks
local ns = vim.api.nvim_create_namespace('nvim_colorpicker_history_swatches')

-- ============================================================================
-- History Highlight Management
-- ============================================================================

---@type table<string, boolean> Cache of created highlight groups
local created_highlights = {}

---Get or create a highlight group for a color swatch
---@param hex string The hex color
---@return string hl_group The highlight group name
local function get_swatch_highlight(hex)
  hex = ColorUtils.normalize_hex(hex)
  local hl_name = "NvimColorPickerHistory_" .. hex:gsub("#", "")

  if not created_highlights[hl_name] then
    vim.api.nvim_set_hl(0, hl_name, { fg = hex })
    created_highlights[hl_name] = true
  end

  return hl_name
end

-- ============================================================================
-- Element-Based Actions
-- ============================================================================

---Select a history item from element data (called when Enter is pressed)
---Uses element data directly - no cursor index tracking needed
---@param element table The element at cursor (from get_element_at_cursor)
---@param schedule_render fun() Function to trigger re-render
function M.select_element(element, schedule_render)
  local state = State.state
  if not state then return end
  if not element or not element.data or not element.data.item then return end

  local item = element.data.item

  State.set_active_color(item.hex)

  -- Restore alpha from history
  if item.alpha then
    state.alpha = item.alpha
  end

  -- Restore color mode from history (only if not locked by forced_mode)
  if item.format and not state.options.forced_mode then
    state.color_mode = item.format
  end

  -- Update saved HSL for proper grid navigation
  local h, s, _ = ColorUtils.hex_to_hsl(item.hex)
  state.saved_hsl = { h = h, s = s }
  state.lightness_virtual = nil
  state.saturation_virtual = nil

  schedule_render()
end

---Delete a history item from element data
---@param element table The element at cursor (from get_element_at_cursor)
---@param schedule_render fun() Function to trigger re-render
function M.delete_element(element, schedule_render)
  local state = State.state
  if not state then return end
  if not element or not element.data or not element.data.item then return end

  local to_delete = element.data.item

  -- Get all colors and remove the selected one (compare by hex)
  local all_colors = History.get_recent()
  local new_colors = {}
  for _, item in ipairs(all_colors) do
    if item.hex ~= to_delete.hex then
      table.insert(new_colors, item)
    end
  end

  -- Clear and re-add remaining colors (in reverse to maintain order)
  History.clear_recent()
  for i = #new_colors, 1, -1 do
    History.add_recent(new_colors[i].hex, new_colors[i].alpha, new_colors[i].format)
  end

  schedule_render()
end

---Clear all history
---@param schedule_render fun() Function to trigger re-render
function M.clear_all(schedule_render)
  local state = State.state
  if not state then return end

  History.clear_recent()
  schedule_render()
end

-- ============================================================================
-- History Tab Rendering
-- ============================================================================

---Render the history tab content to existing ContentBuilder
---@param cb ContentBuilder The content builder to add content to
function M.render_history_content(cb)
  local state = State.state
  if not state then return end

  local history = History.get_recent(MAX_DISPLAY_ITEMS)

  cb:blank()

  if #history == 0 then
    cb:styled("  No recent colors", "muted")
    cb:blank()
    cb:styled("  Pick colors to add", "muted")
    cb:styled("  them to history.", "muted")
  else
    cb:styled(string.format("  Recent (%d)", #history), "header")
    cb:blank()

    -- Pre-calculate display hex values and find max length for alignment
    local display_items = {}
    local max_hex_len = 0
    for _, item in ipairs(history) do
      local display_hex = item.hex
      if item.alpha and item.alpha < 100 then
        local alpha_byte = math.floor((item.alpha / 100) * 255 + 0.5)
        display_hex = item.hex .. string.format("%02X", alpha_byte)
      end
      table.insert(display_items, display_hex)
      max_hex_len = math.max(max_hex_len, #display_hex)
    end

    -- Render all items - cursor position is the selection indicator
    for i, item in ipairs(history) do
      -- Pad hex to align swatches
      local display_hex = display_items[i]
      local padded_hex = display_hex .. string.rep(" ", max_hex_len - #display_hex)

      -- Format indicator (show if not hex)
      local format_indicator = ""
      if item.format and item.format ~= "hex" then
        format_indicator = " [" .. item.format:upper() .. "]"
      end

      -- Track history item as interactive element (store hex in data for swatch)
      cb:spans({
        {
          text = "  ",
          style = "normal",
          track = {
            name = "history_" .. i,
            type = "action",
            row_based = true,
            hover_style = "emphasis",
            data = {
              index = i,
              item = item,
              hex = item.hex,  -- Store hex for swatch extmarks
            },
          },
        },
        { text = string.format("%2d ", i), style = "value" },
        { text = padded_hex, style = "value" },
        { text = format_indicator, style = "muted" },
      })
    end
  end

  cb:blank()
  cb:styled("  " .. string.rep("─", 16), "muted")
  cb:blank()

  if #history > 0 then
    cb:spans({
      { text = "  ", style = "normal" },
      { text = "Enter", style = "key" },
      { text = "=Select  ", style = "muted" },
      { text = "d", style = "key" },
      { text = "=Del", style = "muted" },
    })
  end
end

---Render the complete history panel (tab bar + history content)
---Uses single ContentBuilder so element positions match buffer positions
---@param multi_state MultiPanelState
---@return string[] lines
---@return table[] highlights
function M.render_history_panel(multi_state)
  local state = State.state
  if not state then return {}, {} end

  local Tabs = require('nvim-colorpicker.picker.tabs')

  -- Single ContentBuilder for everything - element positions are correct
  local cb = ContentBuilder.new()

  -- Add tab bar first
  Tabs.render_tab_bar_to(cb)

  -- Add history content
  M.render_history_content(cb)

  -- Store ContentBuilder for element tracking
  M._content_builder = cb

  return cb:build_lines(), cb:build_highlights()
end

---Get the stored ContentBuilder (for element tracking integration)
---@return ContentBuilder?
function M.get_content_builder()
  return M._content_builder
end

---Apply swatch extmarks to the info panel buffer
---Uses element data from ContentBuilder to find history items and their rows
---@param bufnr number The buffer number to apply extmarks to
function M.apply_swatch_extmarks(bufnr)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then return end
  if not M._content_builder then return end

  -- Clear previous extmarks
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  -- Get elements from ContentBuilder and apply swatches
  local registry = M._content_builder:get_registry()
  if not registry then return end

  for _, element in registry:iter() do
    if element.data and element.data.hex then
      local hl_name = get_swatch_highlight(element.data.hex)
      vim.api.nvim_buf_set_extmark(bufnr, ns, element.row, 0, {
        virt_text = { { " " .. SWATCH_TEXT, hl_name } },
        virt_text_pos = "eol",
      })
    end
  end
end

---Clear swatch extmarks from buffer
---@param bufnr number The buffer number
function M.clear_swatch_extmarks(bufnr)
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  end
end

return M
