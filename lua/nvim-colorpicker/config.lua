---@class NvimColorPickerConfig
---@field keymaps NvimColorPickerKeymaps Keymap configuration
---@field default_format "hex"|"rgb"|"hsl"|"hsv" Default color format
---@field hex_case "upper"|"lower" Hex color case for normalize_hex output
---@field alpha_enabled boolean Enable alpha channel editing
---@field recent_colors_count number Number of recent colors to track
---@field presets string[] Preset palettes to include
---@field highlight NvimColorPickerHighlightConfig Inline color highlighting options

---@class NvimColorPickerHighlightConfig
---@field enable boolean Enable auto-highlighting on buffer enter
---@field filetypes string[]|"*" Filetypes to enable highlighting ("*" for all)
---@field exclude_filetypes string[] Filetypes to exclude from highlighting
---@field mode "background"|"foreground"|"virtualtext" Highlight display mode
---@field swatch_char string Character to use for virtualtext swatch (default: "■")

---@class NvimColorPickerKeymaps
---@field nav_left string|string[] Move left in grid (decrease hue)
---@field nav_right string|string[] Move right in grid (increase hue)
---@field nav_up string|string[] Move up in grid (increase lightness)
---@field nav_down string|string[] Move down in grid (decrease lightness)
---@field sat_up string|string[] Increase saturation
---@field sat_down string|string[] Decrease saturation
---@field step_down string|string[] Decrease step size
---@field step_up string|string[] Increase step size
---@field reset string|string[] Reset to original color
---@field hex_input string|string[] Enter hex color manually
---@field apply string|string[] Apply and close
---@field cancel string|string[] Cancel and close
---@field help string|string[] Show help
---@field cycle_mode string|string[] Cycle color mode (HSL/RGB/HSV/CMYK)
---@field cycle_format string|string[] Cycle value format
---@field alpha_up string|string[] Increase alpha
---@field alpha_down string|string[] Decrease alpha
---@field focus_next string|string[] Focus next panel
---@field focus_prev string|string[] Focus previous panel

local M = {}

---Default configuration
---@type NvimColorPickerConfig
M.defaults = {
  default_format = 'hex',
  hex_case = 'upper',  -- "upper" or "lower" for normalized hex output
  alpha_enabled = false,
  recent_colors_count = 10,
  presets = {},

  -- Inline color highlighting
  highlight = {
    enable = false,  -- Set to true to enable auto-highlighting
    filetypes = '*', -- '*' for all filetypes, or list like {'css', 'html', 'lua'}
    exclude_filetypes = { 'lazy', 'mason', 'help', 'TelescopePrompt' },
    mode = 'background', -- 'background', 'foreground', or 'virtualtext'
    swatch_char = '■',   -- Character for virtualtext swatch (e.g., '●', '▓', '█', '◼')
  },

  keymaps = {
    -- Grid navigation (hue and lightness)
    nav_left = 'h',
    nav_right = 'l',
    nav_up = 'k',
    nav_down = 'j',

    -- Saturation adjustment
    sat_up = 'K',
    sat_down = 'J',

    -- Step size adjustment
    step_down = '-',
    step_up = { '+', '=' },

    -- Actions
    reset = 'r',
    hex_input = '#',
    apply = '<CR>',
    cancel = { 'q', '<Esc>' },
    help = '?',

    -- Mode and format cycling
    cycle_mode = 'm',
    cycle_format = 'f',

    -- Alpha adjustment
    alpha_up = 'A',
    alpha_down = 'a',

    -- Panel focus
    focus_next = '<Tab>',
    focus_prev = '<S-Tab>',
  },
}

---Current configuration (merged with user config)
---@type NvimColorPickerConfig
M.config = vim.deepcopy(M.defaults)

---Setup configuration
---@param opts NvimColorPickerConfig? User configuration options
function M.setup(opts)
  opts = opts or {}
  M.config = vim.tbl_deep_extend('force', M.defaults, opts)
end

---Get current configuration
---@return NvimColorPickerConfig
function M.get()
  return M.config
end

---Get keymaps configuration
---@return NvimColorPickerKeymaps
function M.get_keymaps()
  return M.config.keymaps
end

return M
