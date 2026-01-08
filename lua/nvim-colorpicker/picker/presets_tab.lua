---@module 'nvim-colorpicker.picker.presets_tab'
---@brief Presets tab rendering for the color picker

local State = require('nvim-colorpicker.picker.state')
local Presets = require('nvim-colorpicker.presets')
local ColorUtils = require('nvim-colorpicker.color')
local ContentBuilder = require('nvim-float.content')

local M = {}

-- Store ContentBuilder for element tracking
M._content_builder = nil

-- ============================================================================
-- Constants
-- ============================================================================

---@type string Swatch characters (same block char as grid)
local SWATCH_TEXT = "██"

-- ============================================================================
-- Extmark Namespace
-- ============================================================================

---@type number Namespace for swatch extmarks
local ns = vim.api.nvim_create_namespace('nvim_colorpicker_preset_swatches')

-- ============================================================================
-- Swatch Highlight Management
-- ============================================================================

---@type table<string, boolean> Cache of created highlight groups
local created_highlights = {}

---Get or create a highlight group for a color swatch
---@param hex string The hex color
---@return string hl_group The highlight group name
local function get_swatch_highlight(hex)
  hex = ColorUtils.normalize_hex(hex)
  local hl_name = "NvimColorPickerPreset_" .. hex:gsub("#", "")

  if not created_highlights[hl_name] then
    -- Use fg color for block chars (VHS compatible)
    -- Note: bg would fill entire row, so we only use fg
    vim.api.nvim_set_hl(0, hl_name, { fg = hex })
    created_highlights[hl_name] = true
  end

  return hl_name
end

-- ============================================================================
-- Flat Item List Generation
-- ============================================================================

---@class PresetFlatItem
---@field type "preset"|"group"|"color"
---@field preset_key string Preset key (e.g., "tailwind")
---@field preset_name string? Preset display name
---@field group_name string? Group name
---@field color_name string? Color name
---@field hex string? Color hex value
---@field indent number Indentation level
---@field count number? Color count (for preset/group)
---@field expanded boolean? Whether this node is expanded

---Build a flat list of items for rendering
---@param search string? Optional search filter
---@return PresetFlatItem[] items
local function build_flat_items(search)
  local state = State.state
  if not state then return {} end

  local items = {}
  local preset_names = Presets.get_preset_names()
  local expanded = state.presets_expanded or {}
  search = search and search:lower() or nil

  for _, preset_key in ipairs(preset_names) do
    local preset = Presets.get_preset_raw(preset_key)
    if not preset then goto continue_preset end

    local preset_expanded = expanded[preset_key] or false
    local color_count = Presets.get_color_count(preset_key)

    -- Add preset header
    table.insert(items, {
      type = "preset",
      preset_key = preset_key,
      preset_name = preset.name,
      indent = 0,
      count = color_count,
      expanded = preset_expanded,
    })

    if preset_expanded and preset.groups then
      for _, group in ipairs(preset.groups) do
        local group_key = preset_key .. ":" .. group.name
        local group_expanded = expanded[group_key] or false

        -- Filter by search if active
        local group_colors = group.colors
        if search then
          local filtered = {}
          for _, color in ipairs(group.colors) do
            if color.name:lower():find(search, 1, true) or
               color.hex:lower():find(search, 1, true) then
              table.insert(filtered, color)
            end
          end
          -- Skip group if no matching colors
          if #filtered == 0 then goto continue_group end
          group_colors = filtered
        end

        -- Add group header
        table.insert(items, {
          type = "group",
          preset_key = preset_key,
          group_name = group.name,
          indent = 1,
          count = #group_colors,
          expanded = group_expanded,
        })

        if group_expanded then
          for _, color in ipairs(group_colors) do
            table.insert(items, {
              type = "color",
              preset_key = preset_key,
              group_name = group.name,
              color_name = color.name,
              hex = color.hex,
              indent = 2,
            })
          end
        end

        ::continue_group::
      end
    end

    ::continue_preset::
  end

  return items
end

-- ============================================================================
-- Element-Based Actions
-- ============================================================================

---Perform action on an element (called when Enter is pressed)
---Uses element data directly - no cursor index tracking needed
---@param element table The element at cursor (from get_element_at_cursor)
---@param schedule_render fun() Function to trigger re-render
function M.action_on_element(element, schedule_render)
  local state = State.state
  if not state then return end
  if not element or not element.data or not element.data.item then return end

  local item = element.data.item

  if item.type == "preset" then
    -- Toggle preset expansion
    local key = item.preset_key
    state.presets_expanded[key] = not state.presets_expanded[key]
    schedule_render()

  elseif item.type == "group" then
    -- Toggle group expansion
    local key = item.preset_key .. ":" .. item.group_name
    state.presets_expanded[key] = not state.presets_expanded[key]
    schedule_render()

  elseif item.type == "color" and item.hex then
    -- Select the color
    State.set_active_color(item.hex)

    -- Update saved HSL for proper grid navigation
    local h, s, _ = ColorUtils.hex_to_hsl(item.hex)
    state.saved_hsl = { h = h, s = s }
    state.lightness_virtual = nil
    state.saturation_virtual = nil

    schedule_render()
  end
end

---Toggle expand/collapse on an element
---@param element table The element at cursor
---@param schedule_render fun() Function to trigger re-render
function M.toggle_element(element, schedule_render)
  local state = State.state
  if not state then return end
  if not element or not element.data or not element.data.item then return end

  local item = element.data.item

  if item.type == "preset" then
    local key = item.preset_key
    state.presets_expanded[key] = not state.presets_expanded[key]
    schedule_render()
  elseif item.type == "group" then
    local key = item.preset_key .. ":" .. item.group_name
    state.presets_expanded[key] = not state.presets_expanded[key]
    schedule_render()
  elseif item.type == "color" then
    -- For colors, treat toggle as select
    M.action_on_element(element, schedule_render)
  end
end

---Expand all presets/groups
---@param schedule_render fun() Function to trigger re-render
function M.expand_all(schedule_render)
  local state = State.state
  if not state then return end

  local preset_names = Presets.get_preset_names()
  for _, preset_key in ipairs(preset_names) do
    state.presets_expanded[preset_key] = true
    local preset = Presets.get_preset_raw(preset_key)
    if preset and preset.groups then
      for _, group in ipairs(preset.groups) do
        state.presets_expanded[preset_key .. ":" .. group.name] = true
      end
    end
  end

  schedule_render()
end

---Collapse all presets/groups
---@param schedule_render fun() Function to trigger re-render
function M.collapse_all(schedule_render)
  local state = State.state
  if not state then return end

  state.presets_expanded = {}
  state.presets_cursor = 1

  schedule_render()
end

---Set search query
---@param query string Search query
---@param schedule_render fun() Function to trigger re-render
function M.set_search(query, schedule_render)
  local state = State.state
  if not state then return end

  state.presets_search = query
  state.presets_cursor = 1

  schedule_render()
end

---Clear search query
---@param schedule_render fun() Function to trigger re-render
function M.clear_search(schedule_render)
  M.set_search("", schedule_render)
end

-- ============================================================================
-- Presets Tab Rendering
-- ============================================================================

---Render the presets tab content to existing ContentBuilder
---@param cb ContentBuilder The content builder to add content to
function M.render_presets_content(cb)
  local state = State.state
  if not state then return end

  local items = build_flat_items(state.presets_search)

  cb:blank()

  -- Search indicator if active
  if state.presets_search and state.presets_search ~= "" then
    cb:spans({
      { text = "  Search: ", style = "muted" },
      { text = state.presets_search, style = "value" },
    })
    cb:blank()
  end

  if #items == 0 then
    cb:styled("  No presets found", "muted")
    if state.presets_search and state.presets_search ~= "" then
      cb:styled("  Try a different search", "muted")
    end
  else
    -- Calculate max color name length for alignment
    local max_name_len = 0
    for _, item in ipairs(items) do
      if item.type == "color" and item.color_name then
        max_name_len = math.max(max_name_len, #item.color_name)
      end
    end

    -- Render all items - cursor position is the selection indicator
    for i, item in ipairs(items) do
      local indent = string.rep("  ", item.indent)

      if item.type == "preset" then
        local expand_char = item.expanded and "v" or ">"
        -- Track preset as interactive element
        cb:spans({
          {
            text = string.format("  %s%s %s (%d)", indent, expand_char, item.preset_name, item.count),
            style = "header",
            track = {
              name = "preset_" .. i,
              type = "action",
              row_based = true,
              hover_style = "emphasis",
              data = {
                index = i,
                item = item,
              },
            },
          },
        })

      elseif item.type == "group" then
        local expand_char = item.expanded and "v" or ">"
        -- Track group as interactive element
        cb:spans({
          {
            text = string.format("  %s%s %s (%d)", indent, expand_char, item.group_name, item.count),
            style = "value",
            track = {
              name = "preset_" .. i,
              type = "action",
              row_based = true,
              hover_style = "emphasis",
              data = {
                index = i,
                item = item,
              },
            },
          },
        })

      elseif item.type == "color" then
        -- Pad color name to align swatches
        local padded_name = item.color_name .. string.rep(" ", max_name_len - #item.color_name)

        -- Track color as interactive element (store hex in data for swatch)
        cb:spans({
          {
            text = string.format("  %s", indent),
            style = "normal",
            track = {
              name = "preset_" .. i,
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
          { text = padded_name, style = "normal" },
        })
      end
    end
  end

  cb:blank()
  cb:styled("  " .. string.rep("─", 16), "muted")
  cb:blank()

  cb:spans({
    { text = "  ", style = "normal" },
    { text = "Enter", style = "key" },
    { text = "=Sel  ", style = "muted" },
    { text = "zM/zR", style = "key" },
    { text = "=Fold", style = "muted" },
  })
end

---Render the complete presets panel (tab bar + presets content)
---Uses single ContentBuilder so element positions match buffer positions
---@param multi_state MultiPanelState
---@return string[] lines
---@return table[] highlights
function M.render_presets_panel(multi_state)
  local state = State.state
  if not state then return {}, {} end

  local Tabs = require('nvim-colorpicker.picker.tabs')

  -- Single ContentBuilder for everything - element positions are correct
  local cb = ContentBuilder.new()

  -- Add tab bar first
  Tabs.render_tab_bar_to(cb)

  -- Add presets content
  M.render_presets_content(cb)

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
---Uses element data from ContentBuilder to find color items and their rows
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
