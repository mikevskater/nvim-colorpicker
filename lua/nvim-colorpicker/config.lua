---@class NvimColorPickerConfig
---@field keymaps NvimColorPickerKeymaps Keymap configuration
---@field default_format "hex"|"rgb"|"hsl"|"hsv" Default color format
---@field hex_case "upper"|"lower" Hex color case for normalize_hex output
---@field alpha_enabled boolean Enable alpha channel editing
---@field recent_colors_count number Number of recent colors to track
---@field presets string[] Preset palettes to include
---@field highlight NvimColorPickerHighlightConfig Inline color highlighting options
---@field custom_patterns table<string, NvimColorPickerCustomPattern[]> Custom color patterns by filetype

---Custom color pattern definition for user-defined color formats
---@class NvimColorPickerCustomPattern
---@field pattern string Lua pattern to match the color (e.g., "MyColor%s*%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*%)")
---@field format string Unique format identifier (e.g., "my_color_rgb")
---@field priority number? Detection priority (higher = checked first, default: 100)
---@field parse fun(match: string): string?, number? Parse matched string to hex and optional alpha (0-100)
---@field format_color fun(hex: string, alpha: number?): string Format hex (and optional alpha) back to color string

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

-- ============================================================================
-- Global Keymap Detection
-- ============================================================================

---Detect movement keys from global Neovim keymaps using nvim_get_keymap API
---Looks for any key that maps TO h/j/k/l movement commands
---@return table<string, string> Detected movement keys
local function detect_global_movement_keys()
  local detected = {
    nav_left = 'h',
    nav_right = 'l',
    nav_up = 'k',
    nav_down = 'j',
  }

  -- Get all normal mode global mappings
  local mappings = vim.api.nvim_get_keymap('n')

  -- Look for mappings where rhs is a movement key
  for _, map in ipairs(mappings) do
    local lhs = map.lhs
    local rhs = map.rhs or ''

    -- Skip if lhs is not a single character (we want simple key remaps)
    if #lhs ~= 1 then
      goto continue
    end

    -- Normalize rhs: trim whitespace, handle simple cases
    rhs = rhs:gsub('^%s+', ''):gsub('%s+$', '')

    -- Check if this key maps directly to a movement command
    if rhs == 'h' then
      detected.nav_left = lhs
    elseif rhs == 'j' then
      detected.nav_down = lhs
    elseif rhs == 'k' then
      detected.nav_up = lhs
    elseif rhs == 'l' then
      detected.nav_right = lhs
    end

    ::continue::
  end

  -- Derive saturation keys (uppercase versions of detected nav keys)
  detected.sat_up = detected.nav_up:upper()
  detected.sat_down = detected.nav_down:upper()

  return detected
end

---Default configuration
---@type NvimColorPickerConfig
M.defaults = {
  default_format = 'hex',
  hex_case = 'upper',  -- "upper" or "lower" for normalized hex output
  alpha_enabled = false,
  recent_colors_count = 10,
  presets = {},

  -- Custom color patterns by filetype
  -- Example:
  -- custom_patterns = {
  --   cpp = {
  --     {
  --       pattern = "MyColor%s*%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*%)",
  --       format = "my_color_rgb",
  --       priority = 100,
  --       parse = function(match)
  --         local r, g, b = match:match("MyColor%s*%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%)")
  --         if r and g and b then
  --           return string.format("#%02X%02X%02X", tonumber(r), tonumber(g), tonumber(b))
  --         end
  --       end,
  --       format_color = function(hex, alpha)
  --         local r = tonumber(hex:sub(2, 3), 16)
  --         local g = tonumber(hex:sub(4, 5), 16)
  --         local b = tonumber(hex:sub(6, 7), 16)
  --         return string.format("MyColor(%d, %d, %d)", r, g, b)
  --       end,
  --     },
  --   },
  -- },
  custom_patterns = {},

  -- Auto-detect movement keys from global Neovim keymaps
  -- If true, checks for remapped h/j/k/l keys and uses those
  -- Useful for alternative keyboard layouts (Colemak, Dvorak, etc.)
  inherit_movement_keys = true,

  -- Inline color highlighting
  highlight = {
    enable = false,  -- Set to true to enable auto-highlighting
    filetypes = '*', -- '*' for all filetypes, or list like {'css', 'html', 'lua'}
    exclude_filetypes = {
      'lazy', 'mason', 'help', 'TelescopePrompt',
      -- Exclude nvim-float and nvim-colorpicker UI buffers
      'nvim-float', 'nvim-float-form', 'nvim-float-interactive',
      'nvim-colorpicker-grid', 'nvim-colorpicker-info',
    },
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

  -- Start with defaults
  M.config = vim.tbl_deep_extend('force', M.defaults, opts)

  -- Auto-detect movement keys if enabled and user didn't override them
  if M.config.inherit_movement_keys then
    local detected = detect_global_movement_keys()

    -- Only apply detected keys if user didn't explicitly set them
    local user_keymaps = opts.keymaps or {}

    if not user_keymaps.nav_left then
      M.config.keymaps.nav_left = detected.nav_left
    end
    if not user_keymaps.nav_right then
      M.config.keymaps.nav_right = detected.nav_right
    end
    if not user_keymaps.nav_up then
      M.config.keymaps.nav_up = detected.nav_up
    end
    if not user_keymaps.nav_down then
      M.config.keymaps.nav_down = detected.nav_down
    end
    if not user_keymaps.sat_up then
      M.config.keymaps.sat_up = detected.sat_up
    end
    if not user_keymaps.sat_down then
      M.config.keymaps.sat_down = detected.sat_down
    end
  end
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

---Get custom patterns for a filetype
---@param filetype string The filetype to get patterns for
---@return NvimColorPickerCustomPattern[] patterns Custom patterns for this filetype
function M.get_custom_patterns(filetype)
  local patterns = {}

  -- Add filetype-specific patterns
  if M.config.custom_patterns[filetype] then
    for _, p in ipairs(M.config.custom_patterns[filetype]) do
      table.insert(patterns, p)
    end
  end

  -- Add patterns for all filetypes ("_all" key)
  if M.config.custom_patterns["_all"] then
    for _, p in ipairs(M.config.custom_patterns["_all"]) do
      table.insert(patterns, p)
    end
  end

  return patterns
end

return M
