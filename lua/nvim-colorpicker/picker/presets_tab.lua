---@module 'nvim-colorpicker.picker.presets_tab'
---@brief Presets tab rendering for the color picker

local State = require('nvim-colorpicker.picker.state')
local Presets = require('nvim-colorpicker.presets')
local ColorUtils = require('nvim-colorpicker.color')
local ContentBuilder = require('nvim-float.content_builder')

local M = {}

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
    vim.api.nvim_set_hl(0, hl_name, { bg = hex })
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
-- Presets Navigation
-- ============================================================================

---Move cursor up in presets
---@param schedule_render fun() Function to trigger re-render
function M.cursor_up(schedule_render)
  local state = State.state
  if not state then return end

  local items = build_flat_items(state.presets_search)
  if #items == 0 then return end

  state.presets_cursor = state.presets_cursor - 1
  if state.presets_cursor < 1 then
    state.presets_cursor = #items
  end

  schedule_render()
end

---Move cursor down in presets
---@param schedule_render fun() Function to trigger re-render
function M.cursor_down(schedule_render)
  local state = State.state
  if not state then return end

  local items = build_flat_items(state.presets_search)
  if #items == 0 then return end

  state.presets_cursor = state.presets_cursor + 1
  if state.presets_cursor > #items then
    state.presets_cursor = 1
  end

  schedule_render()
end

---Toggle expand/collapse of current item
---@param schedule_render fun() Function to trigger re-render
function M.toggle_expand(schedule_render)
  local state = State.state
  if not state then return end

  local items = build_flat_items(state.presets_search)
  if #items == 0 or state.presets_cursor > #items then return end

  local item = items[state.presets_cursor]
  if item.type == "preset" then
    local key = item.preset_key
    state.presets_expanded[key] = not state.presets_expanded[key]
  elseif item.type == "group" then
    local key = item.preset_key .. ":" .. item.group_name
    state.presets_expanded[key] = not state.presets_expanded[key]
  elseif item.type == "color" then
    -- Selecting a color
    M.select_current(schedule_render)
    return
  end

  schedule_render()
end

---Select the currently highlighted color
---@param schedule_render fun() Function to trigger re-render
function M.select_current(schedule_render)
  local state = State.state
  if not state then return end

  local items = build_flat_items(state.presets_search)
  if #items == 0 or state.presets_cursor > #items then return end

  local item = items[state.presets_cursor]
  if item.type == "color" and item.hex then
    State.set_active_color(item.hex)

    -- Update saved HSL for proper grid navigation
    local h, s, _ = ColorUtils.hex_to_hsl(item.hex)
    state.saved_hsl = { h = h, s = s }
    state.lightness_virtual = nil
    state.saturation_virtual = nil

    schedule_render()
  elseif item.type == "preset" or item.type == "group" then
    -- Toggle expand for non-color items
    M.toggle_expand(schedule_render)
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

---Render the presets tab content (without tab bar)
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
    -- Render all items - nvim-float handles scrolling
    for i, item in ipairs(items) do
      local is_selected = i == state.presets_cursor
      local prefix_char = is_selected and ">" or " "
      local indent = string.rep("  ", item.indent)

      if item.type == "preset" then
        local expand_char = item.expanded and "v" or ">"
        local style = is_selected and "emphasis" or "header"
        cb:styled(string.format(" %s%s%s %s (%d)",
          prefix_char, indent, expand_char, item.preset_name, item.count), style)

      elseif item.type == "group" then
        local expand_char = item.expanded and "v" or ">"
        local style = is_selected and "emphasis" or "value"
        cb:styled(string.format(" %s%s%s %s (%d)",
          prefix_char, indent, expand_char, item.group_name, item.count), style)

      elseif item.type == "color" then
        local style = is_selected and "emphasis" or "normal"
        local swatch_hl = get_swatch_highlight(item.hex)

        cb:spans({
          { text = string.format(" %s%s", prefix_char, indent), style = style },
          { text = item.color_name, style = style },
          { text = " ", style = "normal" },
          { text = "  ", hl_group = swatch_hl },
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
---@param multi_state MultiPanelState
---@return string[] lines
---@return table[] highlights
function M.render_presets_panel(multi_state)
  local state = State.state
  if not state then return {}, {} end

  local Tabs = require('nvim-colorpicker.picker.tabs')

  local all_lines = {}
  local all_highlights = {}

  -- Add tab bar
  local tab_lines, tab_highlights = Tabs.render_tab_bar()
  for _, line in ipairs(tab_lines) do
    table.insert(all_lines, line)
  end
  for _, hl in ipairs(tab_highlights) do
    table.insert(all_highlights, hl)
  end
  local line_offset = #all_lines

  -- Add presets content
  local cb = ContentBuilder.new()
  M.render_presets_content(cb)

  local content_lines = cb:build_lines()
  local content_highlights = cb:build_highlights()

  for _, line in ipairs(content_lines) do
    table.insert(all_lines, line)
  end
  for _, hl in ipairs(content_highlights) do
    table.insert(all_highlights, {
      line = hl.line + line_offset,
      col_start = hl.col_start,
      col_end = hl.col_end,
      hl_group = hl.hl_group,
    })
  end

  return all_lines, all_highlights
end

return M
