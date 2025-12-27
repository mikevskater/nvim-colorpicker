---@module 'nvim-colorpicker.presets'
---@brief Color preset palettes for nvim-colorpicker

local M = {}

-- Load preset data from submodules
M.web = require('nvim-colorpicker.presets.web')
M.material = require('nvim-colorpicker.presets.material')
M.tailwind = require('nvim-colorpicker.presets.tailwind')

-- ============================================================================
-- Utility Functions
-- ============================================================================

---Get all available preset names
---@return string[] names List of preset names
function M.get_preset_names()
  local names = {}
  for name, preset in pairs(M) do
    if type(preset) == "table" and preset.groups then
      table.insert(names, name)
    end
  end
  table.sort(names)
  return names
end

---Get a preset by name (returns dict of color_name -> hex)
---@param name string Preset name (e.g., "web", "material", "tailwind")
---@return table<string, string>? preset Dict of color names to hex values
function M.get_preset(name)
  local preset = M[name]
  if not preset or not preset.groups then return nil end

  -- Flatten groups into dict format for easier lookup
  local result = {}
  for _, group in ipairs(preset.groups) do
    for _, color in ipairs(group.colors) do
      result[color.name] = color.hex
    end
  end
  return result
end

---Get raw preset data (with name and groups array)
---@param name string Preset name
---@return table? preset The raw preset table
function M.get_preset_raw(name)
  return M[name]
end

---Get all groups for a preset
---@param preset_name string Preset name
---@return table[]? groups Array of group tables with name and colors
function M.get_groups(preset_name)
  local preset = M[preset_name]
  if not preset or not preset.groups then return nil end
  return preset.groups
end

---Get total color count for a preset
---@param preset_name string Preset name
---@return number count Total number of colors
function M.get_color_count(preset_name)
  local preset = M[preset_name]
  if not preset or not preset.groups then return 0 end

  local count = 0
  for _, group in ipairs(preset.groups) do
    count = count + #group.colors
  end
  return count
end

---Search for a color by name across all presets
---@param query string Search query (partial match)
---@return table[] matches Array of {preset, group, name, hex}
function M.search(query)
  local matches = {}
  query = query:lower()

  for preset_name, preset in pairs(M) do
    if type(preset) == "table" and preset.groups then
      for _, group in ipairs(preset.groups) do
        for _, color in ipairs(group.colors) do
          if color.name:lower():find(query, 1, true) then
            table.insert(matches, {
              preset = preset_name,
              group = group.name,
              name = color.name,
              hex = color.hex,
            })
          end
        end
      end
    end
  end

  return matches
end

---Get color by name from a preset (case-insensitive)
---@param preset_name string Preset name
---@param color_name string Color name
---@return string? hex The hex color or nil
function M.get_color(preset_name, color_name)
  local preset = M[preset_name]
  if not preset or not preset.groups then return nil end

  local lower_name = color_name:lower()
  for _, group in ipairs(preset.groups) do
    for _, color in ipairs(group.colors) do
      if color.name:lower() == lower_name then
        return color.hex
      end
    end
  end

  return nil
end

return M
