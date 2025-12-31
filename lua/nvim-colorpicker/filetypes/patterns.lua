---@module 'nvim-colorpicker.filetypes.patterns'
---@brief Shared pattern definitions for color detection

local M = {}

-- ============================================================================
-- Universal Patterns (work in most languages)
-- ============================================================================

---Hex color patterns (#RGB, #RRGGBB, #RRGGBBAA)
M.universal = {
  { pattern = "#%x%x%x%x%x%x%x%x", format = "hex8", priority = 100 },
  { pattern = "#%x%x%x%x%x%x", format = "hex", priority = 90 },
  { pattern = "#%x%x%x", format = "hex3", priority = 80 },
}

-- ============================================================================
-- CSS Function Patterns
-- ============================================================================

---CSS-style function patterns (rgb, hsl, etc.)
M.css_functions = {
  { pattern = "rgba%s*%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*[,/]%s*[%d%.]+%s*%)", format = "rgb", priority = 95 },
  { pattern = "rgb%s*%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*%)", format = "rgb", priority = 90 },
  { pattern = "hsla%s*%(%s*%d+%s*,%s*%d+%%%s*,%s*%d+%%%s*[,/]%s*[%d%.]+%s*%)", format = "hsl", priority = 95 },
  { pattern = "hsl%s*%(%s*%d+%s*,%s*%d+%%%s*,%s*%d+%%%s*%)", format = "hsl", priority = 90 },
  { pattern = "hsva%s*%(%s*%d+%s*,%s*%d+%%%s*,%s*%d+%%%s*[,/]%s*[%d%.]+%s*%)", format = "hsv", priority = 85 },
  { pattern = "hsv%s*%(%s*%d+%s*,%s*%d+%%%s*,%s*%d+%%%s*%)", format = "hsv", priority = 80 },
  { pattern = "hwb%s*%(%s*%d+%s*,%s*%d+%%%s*,%s*%d+%%%s*%)", format = "hwb", priority = 75 },
  { pattern = "lab%s*%(%s*[%d%.]+%%%s+[%-?%d%.]+%s+[%-?%d%.]+%s*%)", format = "lab", priority = 75 },
  { pattern = "lch%s*%(%s*[%d%.]+%%%s+[%d%.]+%s+[%d%.]+%s*%)", format = "lch", priority = 75 },
  { pattern = "oklch%s*%(%s*[%d%.]+%s+[%d%.]+%s+[%d%.]+%s*%)", format = "oklch", priority = 75 },
}

-- ============================================================================
-- Numeric Hex Patterns (0xRRGGBB style)
-- ============================================================================

---Numeric hex patterns (common in Android, Flutter, game engines)
M.numeric_hex = {
  { pattern = "0x%x%x%x%x%x%x%x%x", format = "hex_numeric_argb", priority = 100 },
  { pattern = "0x%x%x%x%x%x%x", format = "hex_numeric", priority = 90 },
}

-- ============================================================================
-- Tuple Patterns
-- ============================================================================

---Integer tuple patterns (r, g, b) - common in Python
M.tuples = {
  { pattern = "%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*,%s*%d+%s*%)", format = "tuple_rgba", priority = 85 },
  { pattern = "%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*%)", format = "tuple_rgb", priority = 80 },
}

---Float tuple patterns {r, g, b} - common in Lua/Love2D, shaders
M.float_tuples = {
  { pattern = "%{%s*[%d%.]+%s*,%s*[%d%.]+%s*,%s*[%d%.]+%s*,%s*[%d%.]+%s*%}", format = "float_tuple_alpha", priority = 85 },
  { pattern = "%{%s*[%d%.]+%s*,%s*[%d%.]+%s*,%s*[%d%.]+%s*%}", format = "float_tuple", priority = 80 },
}

-- ============================================================================
-- Constructor Patterns
-- ============================================================================

---Color constructor patterns (Color(), Color.new(), etc.)
M.constructors = {
  { pattern = "Color%s*%(%s*0x%x+%s*%)", format = "color_constructor_hex", priority = 95 },
  { pattern = "Color%.fromRGB%s*%([^)]+%)", format = "color_from_rgb", priority = 90 },
  { pattern = "Color%.fromHex%s*%([^)]+%)", format = "color_from_hex", priority = 90 },
  { pattern = "Color%.fromARGB%s*%([^)]+%)", format = "color_from_argb", priority = 90 },
  { pattern = "Color%.fromRGBO%s*%([^)]+%)", format = "color_from_rgbo", priority = 90 },
  { pattern = "Color%.new%s*%([^)]+%)", format = "color_new", priority = 85 },
  { pattern = "Color%s*%([^)]+%)", format = "color_constructor", priority = 80 },
}

-- ============================================================================
-- Shader Vector Patterns
-- ============================================================================

---GLSL vector patterns
M.glsl_vectors = {
  { pattern = "vec4%s*%([^)]+%)", format = "vec4", priority = 85 },
  { pattern = "vec3%s*%([^)]+%)", format = "vec3", priority = 80 },
}

---HLSL/Metal float patterns
M.hlsl_vectors = {
  { pattern = "float4%s*%([^)]+%)", format = "float4", priority = 85 },
  { pattern = "float3%s*%([^)]+%)", format = "float3", priority = 80 },
}

-- ============================================================================
-- Vim/Neovim Patterns
-- ============================================================================

---Vim highlight patterns
M.vim_highlight = {
  { pattern = "gui[fb]g=#%x%x%x%x%x%x", format = "vim", priority = 100 },
}

---Neovim Lua highlight patterns (fg/bg = "#RRGGBB")
M.nvim_lua_highlight = {
  { pattern = '[fb]g%s*=%s*"#%x%x%x%x%x%x"', format = "nvim_lua", priority = 95 },
  { pattern = "[fb]g%s*=%s*'#%x%x%x%x%x%x'", format = "nvim_lua", priority = 95 },
}

-- ============================================================================
-- Unity C# Patterns
-- ============================================================================

---Unity Color patterns
M.unity_color = {
  { pattern = "Color32%s*%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*,%s*%d+%s*%)", format = "color32", priority = 95 },
  { pattern = "new%s+Color%s*%([^)]+%)", format = "unity_color", priority = 90 },
  { pattern = "Color%.%w+", format = "unity_named", priority = 80 },
}

-- ============================================================================
-- Roblox/Luau Patterns
-- ============================================================================

---Roblox Color3 patterns
M.roblox_color = {
  { pattern = "Color3%.fromRGB%s*%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*%)", format = "color3_rgb", priority = 95 },
  { pattern = 'Color3%.fromHex%s*%([^)]+%)', format = "color3_hex", priority = 90 },
  { pattern = "Color3%.new%s*%([^)]+%)", format = "color3_new", priority = 85 },
}

-- ============================================================================
-- Godot GDScript Patterns
-- ============================================================================

---Godot Color patterns
M.godot_color = {
  { pattern = 'Color%.html%s*%([^)]+%)', format = "godot_html", priority = 95 },
  { pattern = "Color%s*%([^)]+%)", format = "godot_color", priority = 85 },
}

-- ============================================================================
-- Helper Functions
-- ============================================================================

---Combine multiple pattern tables
---@vararg table Pattern tables to combine
---@return PatternDef[] combined Combined patterns
function M.combine(...)
  local result = {}
  for _, tbl in ipairs({ ... }) do
    for _, pattern in ipairs(tbl) do
      table.insert(result, pattern)
    end
  end
  -- Sort by priority (higher first)
  table.sort(result, function(a, b)
    return (a.priority or 0) > (b.priority or 0)
  end)
  return result
end

---Create a copy of patterns with modified priorities
---@param patterns PatternDef[] Source patterns
---@param priority_offset number Amount to add/subtract from priority
---@return PatternDef[] modified Modified patterns
function M.with_priority(patterns, priority_offset)
  local result = {}
  for _, p in ipairs(patterns) do
    table.insert(result, {
      pattern = p.pattern,
      format = p.format,
      priority = (p.priority or 0) + priority_offset,
    })
  end
  return result
end

return M
