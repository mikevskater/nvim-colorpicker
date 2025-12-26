-- ============================================================================
-- Lua Colors Test File - nvim-colorpicker
-- ============================================================================
--
-- TEST INSTRUCTIONS:
-- 1. Run :ColorHighlight to see inline color previews
-- 2. Position cursor on any color value
-- 3. Run :ColorPickerAtCursor to open picker and replace
-- 4. Run :ColorYank to copy color to clipboard
--
-- This file simulates typical Neovim plugin/config color usage
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Section 1: Simple Hex Strings
-- Test: Basic hex color detection in Lua strings
-- ----------------------------------------------------------------------------

local colors = {
  red = "#FF0000",
  green = "#00FF00",
  blue = "#0000FF",
  orange = "#FF5500",
  purple = "#9B59B6",
  cyan = "#00FFFF",
  magenta = "#FF00FF",
  yellow = "#FFFF00",
}

-- Lowercase hex
local lowercase_colors = {
  primary = "#3498db",
  secondary = "#2ecc71",
  accent = "#e74c3c",
  muted = "#95a5a6",
}

-- ----------------------------------------------------------------------------
-- Section 2: Neovim Highlight Definitions
-- Test: Colors in vim.api.nvim_set_hl calls
-- ----------------------------------------------------------------------------

-- Basic highlight setup
vim.api.nvim_set_hl(0, "MyHighlight", { fg = "#FF5500", bg = "#1E1E1E" })
vim.api.nvim_set_hl(0, "MyBold", { fg = "#3498DB", bold = true })
vim.api.nvim_set_hl(0, "MyItalic", { fg = "#2ECC71", italic = true })

-- With sp (special/underline color)
vim.api.nvim_set_hl(0, "MyUnderline", {
  fg = "#FFFFFF",
  sp = "#E74C3C",
  underline = true,
})

-- Multiple highlights in sequence
vim.api.nvim_set_hl(0, "Normal", { fg = "#D4D4D4", bg = "#1E1E1E" })
vim.api.nvim_set_hl(0, "Comment", { fg = "#6A9955", italic = true })
vim.api.nvim_set_hl(0, "String", { fg = "#CE9178" })
vim.api.nvim_set_hl(0, "Number", { fg = "#B5CEA8" })
vim.api.nvim_set_hl(0, "Keyword", { fg = "#569CD6", bold = true })
vim.api.nvim_set_hl(0, "Function", { fg = "#DCDCAA" })
vim.api.nvim_set_hl(0, "Type", { fg = "#4EC9B0" })

-- ----------------------------------------------------------------------------
-- Section 3: Theme Configuration Tables
-- Test: Nested color tables
-- ----------------------------------------------------------------------------

local theme = {
  name = "My Custom Theme",
  colors = {
    -- UI Colors
    ui = {
      bg = "#1E1E1E",
      fg = "#D4D4D4",
      border = "#3C3C3C",
      selection = "#264F78",
      cursor = "#AEAFAD",
      line_nr = "#858585",
      line_nr_current = "#C6C6C6",
    },
    -- Syntax Colors
    syntax = {
      comment = "#6A9955",
      string = "#CE9178",
      number = "#B5CEA8",
      keyword = "#569CD6",
      ["function"] = "#DCDCAA",
      variable = "#9CDCFE",
      type = "#4EC9B0",
      constant = "#4FC1FF",
      operator = "#D4D4D4",
    },
    -- Git Colors
    git = {
      added = "#587C0C",
      modified = "#0C7D9D",
      deleted = "#94151B",
    },
    -- Diagnostic Colors
    diagnostic = {
      error = "#F44747",
      warning = "#CCA700",
      info = "#3794FF",
      hint = "#B0B0B0",
    },
  },
}

-- ----------------------------------------------------------------------------
-- Section 4: Plugin Configuration
-- Test: Colors in plugin setup calls
-- ----------------------------------------------------------------------------

-- Lualine-style config
local lualine_theme = {
  normal = {
    a = { fg = "#1E1E1E", bg = "#569CD6", gui = "bold" },
    b = { fg = "#D4D4D4", bg = "#3C3C3C" },
    c = { fg = "#858585", bg = "#1E1E1E" },
  },
  insert = {
    a = { fg = "#1E1E1E", bg = "#4EC9B0", gui = "bold" },
  },
  visual = {
    a = { fg = "#1E1E1E", bg = "#C586C0", gui = "bold" },
  },
  command = {
    a = { fg = "#1E1E1E", bg = "#CE9178", gui = "bold" },
  },
}

-- Telescope-style config
local telescope_colors = {
  TelescopeNormal = { bg = "#1E1E1E" },
  TelescopeBorder = { fg = "#3C3C3C", bg = "#1E1E1E" },
  TelescopePromptNormal = { bg = "#252526" },
  TelescopePromptBorder = { fg = "#569CD6", bg = "#252526" },
  TelescopePromptTitle = { fg = "#1E1E1E", bg = "#569CD6" },
  TelescopeSelection = { bg = "#264F78" },
  TelescopeMatching = { fg = "#CE9178", bold = true },
}

-- ----------------------------------------------------------------------------
-- Section 5: Color Utility Functions
-- Test: Colors in function arguments
-- ----------------------------------------------------------------------------

local function apply_highlight(name, fg, bg)
  vim.api.nvim_set_hl(0, name, { fg = fg, bg = bg })
end

apply_highlight("MyCustom1", "#FF5500", "#1E1E1E")
apply_highlight("MyCustom2", "#3498DB", "#252526")
apply_highlight("MyCustom3", "#2ECC71", nil)

-- ----------------------------------------------------------------------------
-- Section 6: Inline Comments with Colors
-- Test: Colors mentioned in comments
-- ----------------------------------------------------------------------------

-- Primary brand color: #3498DB (blue)
-- Secondary color: #2ECC71 (green)
-- Accent color: #E74C3C (red)
-- Background: #1E1E1E (dark gray)

local config = {
  -- TODO: Change this to #FF5500 for better visibility
  highlight_color = "#FFCC00",
  -- The old color was #808080, now using brighter
  border_color = "#5C5C5C",
}

-- ----------------------------------------------------------------------------
-- Section 7: String Concatenation
-- Test: Colors in string operations
-- ----------------------------------------------------------------------------

local primary = "#3498DB"
local secondary = "#2ECC71"

local css_output = string.format([[
  .primary { color: %s; }
  .secondary { color: %s; }
]], primary, secondary)

-- Color in print/log statements
print("Using color: #FF5500")
vim.notify("Theme color: #569CD6", vim.log.levels.INFO)

-- ----------------------------------------------------------------------------
-- Section 8: Conditional Colors
-- Test: Colors in conditional expressions
-- ----------------------------------------------------------------------------

local is_dark_mode = true

local bg_color = is_dark_mode and "#1E1E1E" or "#FFFFFF"
local fg_color = is_dark_mode and "#D4D4D4" or "#1E1E1E"

local status_color = (function()
  local status = "error"
  if status == "success" then
    return "#2ECC71"
  elseif status == "warning" then
    return "#F1C40F"
  elseif status == "error" then
    return "#E74C3C"
  else
    return "#95A5A6"
  end
end)()

-- ----------------------------------------------------------------------------
-- Section 9: Array of Colors
-- Test: Multiple colors in array format
-- ----------------------------------------------------------------------------

local rainbow = {
  "#FF0000", -- Red
  "#FF7F00", -- Orange
  "#FFFF00", -- Yellow
  "#00FF00", -- Green
  "#0000FF", -- Blue
  "#4B0082", -- Indigo
  "#9400D3", -- Violet
}

local gradient_stops = { "#FF5500", "#FF8800", "#FFBB00", "#FFEE00" }

-- ----------------------------------------------------------------------------
-- Section 10: Real Plugin Example
-- Test: Simulated plugin setup
-- ----------------------------------------------------------------------------

require("my-plugin").setup({
  theme = {
    background = "#0D1117",
    foreground = "#C9D1D9",
    selection = "#388BFD",
    comment = "#8B949E",
    red = "#FF7B72",
    orange = "#FFA657",
    yellow = "#D29922",
    green = "#3FB950",
    cyan = "#39C5CF",
    blue = "#58A6FF",
    purple = "#BC8CFF",
  },
  highlights = {
    border = "#30363D",
    cursor_line = "#161B22",
    visual = "#264F78",
  },
})
