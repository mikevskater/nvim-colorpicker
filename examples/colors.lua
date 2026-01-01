-- =============================================================================
-- Lua Color Formats Example
-- nvim-colorpicker detects and can replace all these formats
-- =============================================================================

-- Neovim colorscheme (hex strings)
local colors = {
  bg = "#1a1b26",
  fg = "#c0caf5",
  black = "#15161e",
  red = "#f7768e",
  green = "#9ece6a",
  yellow = "#e0af68",
  blue = "#7aa2f7",
  magenta = "#bb9af7",
  cyan = "#7dcfff",
  white = "#a9b1d6",
}

-- Neovim highlight groups
vim.api.nvim_set_hl(0, "Normal", { fg = "#c0caf5", bg = "#1a1b26" })
vim.api.nvim_set_hl(0, "Comment", { fg = "#565f89", italic = true })
vim.api.nvim_set_hl(0, "String", { fg = "#9ece6a" })
vim.api.nvim_set_hl(0, "Function", { fg = "#7aa2f7", bold = true })
vim.api.nvim_set_hl(0, "Keyword", { fg = "#bb9af7" })
vim.api.nvim_set_hl(0, "Error", { fg = "#f7768e", undercurl = true })

-- Vim highlight syntax (legacy)
vim.cmd([[
  highlight Normal guifg=#c0caf5 guibg=#1a1b26
  highlight Visual guifg=#1a1b26 guibg=#7aa2f7
  highlight Search guifg=#1a1b26 guibg=#e0af68
  highlight CursorLine guibg=#292e42
]])

-- Love2D colors (float tables 0.0-1.0)
local love_colors = {
  background = {0.102, 0.106, 0.149},
  player = {0.478, 0.635, 0.969},
  enemy = {0.969, 0.463, 0.557},
  collectible = {0.886, 0.686, 0.408},
  ui_text = {0.753, 0.792, 0.961},
}

-- Love2D with alpha
local particles = {
  fire = {1.000, 0.400, 0.200, 0.800},
  smoke = {0.300, 0.300, 0.300, 0.500},
  magic = {0.733, 0.604, 0.969, 0.900},
  heal = {0.400, 0.900, 0.400, 0.700},
}

-- Game theme configuration
local theme = {
  ui = {
    primary = "#7aa2f7",
    secondary = "#bb9af7",
    accent = "#7dcfff",
    background = "#1a1b26",
    surface = "#24283b",
    error = "#f7768e",
    success = "#9ece6a",
  },
  game = {
    sky = {0.529, 0.808, 0.922},
    grass = {0.365, 0.678, 0.329},
    water = {0.255, 0.412, 0.882, 0.800},
  },
}

return {
  colors = colors,
  love_colors = love_colors,
  particles = particles,
  theme = theme,
}
