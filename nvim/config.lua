-- nvim-colorpicker lazy.nvim configuration
-- Add this to your lazy.nvim plugin specs

return {
  "mikevskater/nvim-colorpicker",
  dependencies = {
    "mikevskater/nvim-float",
  },
  cmd = {
    "ColorPicker",
    "ColorPickerAtCursor",
    "ColorConvert",
  },
  keys = {
    { "<leader>cp", "<cmd>ColorPicker<cr>", desc = "Open Color Picker" },
    { "<leader>cc", "<cmd>ColorPickerAtCursor<cr>", desc = "Pick Color at Cursor" },
  },
  opts = {
    -- Default color format: "hex", "rgb", "hsl", "hsv"
    default_format = "hex",

    -- Enable alpha channel editing
    alpha_enabled = false,

    -- Number of recent colors to track
    recent_colors_count = 10,

    -- Keymaps (defaults shown, customize as needed)
    keymaps = {
      -- Grid navigation (hue and lightness)
      nav_left = "h",
      nav_right = "l",
      nav_up = "k",
      nav_down = "j",

      -- Saturation adjustment
      sat_up = "K",
      sat_down = "J",

      -- Step size adjustment
      step_down = "-",
      step_up = { "+", "=" },

      -- Style toggles
      toggle_bold = "b",
      toggle_italic = "i",
      toggle_bg = "B",
      clear_bg = "x",

      -- Actions
      reset = "r",
      hex_input = "#",
      apply = "<CR>",
      cancel = { "q", "<Esc>" },
      help = "?",

      -- Mode and format cycling
      cycle_mode = "m",
      cycle_format = "f",

      -- Alpha adjustment
      alpha_up = "A",
      alpha_down = "a",

      -- Panel focus (multipanel mode)
      focus_next = "<Tab>",
      focus_prev = "<S-Tab>",
    },
  },
  config = function(_, opts)
    require("nvim-colorpicker").setup(opts)
  end,
}
