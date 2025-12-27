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
  for name, _ in pairs(M) do
    if type(M[name]) == "table" and M[name].colors then
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
  if not preset or not preset.colors then return nil end

  -- Convert array format to dict format for easier lookup
  local result = {}
  for _, color in ipairs(preset.colors) do
    result[color.name] = color.hex
  end
  return result
end

---Get raw preset data (with name and colors array)
---@param name string Preset name
---@return table? preset The raw preset table
function M.get_preset_raw(name)
  return M[name]
end

---Search for a color by name across all presets
---@param query string Search query (partial match)
---@return table[] matches Array of {preset, name, hex}
function M.search(query)
  local matches = {}
  query = query:lower()

  for preset_name, preset in pairs(M) do
    if type(preset) == "table" and preset.colors then
      for _, color in ipairs(preset.colors) do
        if color.name:lower():find(query, 1, true) then
          table.insert(matches, {
            preset = preset_name,
            name = color.name,
            hex = color.hex,
          })
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
  if not preset or not preset.colors then return nil end

  local lower_name = color_name:lower()
  for _, color in ipairs(preset.colors) do
    if color.name:lower() == lower_name then
      return color.hex
    end
  end

  return nil
end

return M
