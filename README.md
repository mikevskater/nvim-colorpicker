<div align="center">

# nvim-colorpicker

**A powerful HSL-based color picker for Neovim with visual grid navigation, multi-language support, and real-time preview**

[![Neovim](https://img.shields.io/badge/Neovim-0.9+-57A143?style=for-the-badge&logo=neovim&logoColor=white)](https://neovim.io/)
[![Lua](https://img.shields.io/badge/Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white)](https://www.lua.org/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)

[Features](#features) •
[Installation](#installation) •
[Quick Start](#quick-start) •
[Configuration](#configuration) •
[Keymaps](#keymaps) •
[API](#lua-api)

</div>

---

## Demo

<p align="center">
  <img src="assets/hero.gif" alt="nvim-colorpicker demo" width="800">
</p>

---

## Features

<table>
<tr>
<td width="50%" valign="top">

### Color Picking
- HSL color grid with vim-style navigation
- Multiple picker interfaces (full, mini, slider)
- Real-time color preview
- Alpha channel support with visual feedback
- Step size multipliers for precision

### Multi-Language Support
- Detect colors in 12+ languages
- CSS, JS/TS, Go, C++, Rust, Kotlin, Swift
- Dart, C#, Python, Lua, GLSL/HLSL
- Language-aware output formatting
- Custom pattern definitions

### Buffer Highlighting
- Background, foreground, or virtualtext modes
- Configurable per-filetype
- Real-time highlighting updates

</td>
<td width="50%" valign="top">

### Format Support
- HEX (`#RGB`, `#RRGGBB`, `#RRGGBBAA`)
- RGB/RGBA (`rgb()`, `rgba()`)
- HSL/HSLA (`hsl()`, `hsla()`)
- Language-specific (QColor, vec3, Color.RGBA, etc.)
- Format cycling with `o` key

### Presets & History
- 600+ colors from Web, Material, Tailwind
- Recent colors history
- Searchable preset library
- Clipboard operations

### Integration
- External plugin callbacks
- Custom UI controls injection
- Keyboard layout detection (Colemak/Dvorak)
- Format-preserving replacements

</td>
</tr>
</table>

---

## Requirements

<table>
<tr>
<td>

**Neovim 0.9+** (0.11+ recommended)

</td>
<td>

**[nvim-float](https://github.com/mikevskater/nvim-float)** (UI framework)

</td>
<td>

**termguicolors** enabled

</td>
</tr>
</table>

---

## Installation

### lazy.nvim <sub>(Recommended)</sub>

```lua
{
  "mikevskater/nvim-colorpicker",
  dependencies = { "mikevskater/nvim-float" },
  cmd = { "ColorPicker", "ColorPickerAtCursor", "ColorPickerMini" },
  keys = {
    { "<leader>cp", "<Plug>(colorpicker)", desc = "Color Picker" },
    { "<leader>cc", "<Plug>(colorpicker-at-cursor)", desc = "Pick at Cursor" },
    { "<leader>cm", "<Plug>(colorpicker-mini)", desc = "Mini Picker" },
    { "<leader>ch", "<Plug>(colorpicker-highlight-toggle)", desc = "Toggle Highlighting" },
  },
  opts = {
    alpha_enabled = true,
    presets = { "web", "tailwind" },
    highlight = {
      enable = true,
      filetypes = { "css", "scss", "html" },
    },
  },
}
```

<details>
<summary><b>Other Package Managers</b></summary>

<br>

**packer.nvim**
```lua
use {
  "mikevskater/nvim-colorpicker",
  requires = { "mikevskater/nvim-float" },
  config = function()
    require("nvim-colorpicker").setup()
  end,
}
```

**vim-plug**
```vim
Plug 'mikevskater/nvim-float'
Plug 'mikevskater/nvim-colorpicker'

" After plug#end():
lua require('nvim-colorpicker').setup()
```

**mini.deps**
```lua
add({ source = "mikevskater/nvim-float" })
add({ source = "mikevskater/nvim-colorpicker" })
```

</details>

<details>
<summary><b>Health Check</b></summary>

<br>

After installation, verify everything is working:

```vim
:checkhealth nvim-colorpicker
```

</details>

---

## Quick Start

<table>
<tr>
<td width="33%">

**Setup**

```lua
require("nvim-colorpicker").setup()

-- Recommended keymaps
vim.keymap.set("n", "<leader>cp",
  "<cmd>ColorPicker<cr>")
vim.keymap.set("n", "<leader>cc",
  "<cmd>ColorPickerAtCursor<cr>")
```

</td>
<td width="33%">

**Pick Colors**

```vim
" Open full picker
:ColorPicker

" Pick at cursor
:ColorPickerAtCursor

" Mini picker
:ColorPickerMini
```

</td>
<td width="33%">

**Navigate**

```
h/l       Adjust hue
j/k       Adjust lightness
J/K       Adjust saturation
Enter     Apply color
q/Esc     Cancel
```

</td>
</tr>
</table>

<p align="center">
  <img src="assets/quickstart.gif" alt="Quick start demo" width="640">
</p>

---

## Configuration

<details open>
<summary><b>Default Configuration</b></summary>

```lua
require("nvim-colorpicker").setup({
  -- Default color output format: "hex", "rgb", "hsl", "hsv"
  default_format = "hex",

  -- Hex color case: "upper" or "lower"
  hex_case = "upper",

  -- Enable alpha channel editing by default
  alpha_enabled = false,

  -- Number of recent colors to track in history
  recent_colors_count = 10,

  -- Preset palettes to include: {"web", "material", "tailwind"}
  presets = {},

  -- Auto-detect movement keys from global Neovim keymaps
  -- Useful for Colemak, Dvorak, and other keyboard layouts
  inherit_movement_keys = true,

  -- Inline color highlighting configuration
  highlight = {
    enable = false,
    filetypes = "*",
    exclude_filetypes = {
      "lazy", "mason", "help", "TelescopePrompt",
      "nvim-float", "nvim-float-form", "nvim-float-interactive",
      "nvim-colorpicker-grid", "nvim-colorpicker-info",
    },
    mode = "background",
    swatch_char = "■",
  },

  -- Keymap configuration
  keymaps = {
    nav_left = "h", nav_right = "l",
    nav_up = "k", nav_down = "j",
    sat_up = "K", sat_down = "J",
    step_down = "-", step_up = { "+", "=" },
    reset = "r", hex_input = "#",
    apply = "<CR>", cancel = { "q", "<Esc>" },
    help = "?", cycle_mode = "m", cycle_format = "f",
    alpha_up = "A", alpha_down = "a",
    focus_next = "<Tab>", focus_prev = "<S-Tab>",
  },
})
```

</details>

### Options Reference

| Option | Type | Default | Description |
|:-------|:-----|:--------|:------------|
| `default_format` | string | `"hex"` | Output format: hex, rgb, hsl, hsv |
| `hex_case` | string | `"upper"` | Hex case: upper or lower |
| `alpha_enabled` | boolean | `false` | Enable alpha channel editing |
| `recent_colors_count` | number | `10` | Colors to track in history |
| `presets` | string[] | `{}` | Palettes: web, material, tailwind |
| `inherit_movement_keys` | boolean | `true` | Auto-detect keyboard layout |
| `highlight.enable` | boolean | `false` | Enable auto-highlighting |
| `highlight.filetypes` | string/table | `"*"` | Filetypes to highlight |
| `highlight.mode` | string | `"background"` | background, foreground, virtualtext |

<details>
<summary><b>Example: Web Development Setup</b></summary>

<br>

```lua
require("nvim-colorpicker").setup({
  alpha_enabled = true,
  presets = { "web", "tailwind" },
  highlight = {
    enable = true,
    filetypes = { "css", "scss", "html", "vue", "svelte", "jsx", "tsx" },
    mode = "background",
  },
})
```

</details>

<details>
<summary><b>Example: Custom Color Patterns</b></summary>

<br>

```lua
require("nvim-colorpicker").setup({
  custom_patterns = {
    cpp = {
      {
        pattern = "MyColor%s*%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*%)",
        format = "my_color_rgb",
        priority = 100,
        parse = function(match)
          local r, g, b = match:match("MyColor%s*%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%)")
          if r and g and b then
            return string.format("#%02X%02X%02X", tonumber(r), tonumber(g), tonumber(b))
          end
        end,
        format_color = function(hex, alpha)
          local r = tonumber(hex:sub(2, 3), 16)
          local g = tonumber(hex:sub(4, 5), 16)
          local b = tonumber(hex:sub(6, 7), 16)
          return string.format("MyColor(%d, %d, %d)", r, g, b)
        end,
      },
    },
  },
})
```

</details>

---

## Commands

### Color Picker

| Command | Description |
|:--------|:------------|
| `:ColorPicker [color]` | Open full color picker |
| `:ColorPickerAtCursor` | Detect and replace color at cursor |
| `:ColorPickerMini [color]` | Open compact inline picker |
| `:ColorPickerMiniAtCursor` | Mini picker at cursor |
| `:ColorPickerMiniSlider [color]` | Open mini picker in slider mode |
| `:ColorPickerMiniSliderAtCursor` | Slider mode at cursor |

### Conversion & Clipboard

| Command | Description |
|:--------|:------------|
| `:ColorConvert [format]` | Convert color at cursor (hex, rgb, hsl, hsv) |
| `:ColorYank [format]` | Copy color at cursor to clipboard |
| `:ColorPaste` | Paste color from clipboard |

### Highlighting

| Command | Description |
|:--------|:------------|
| `:ColorHighlight` | Toggle highlighting in current buffer |
| `:ColorHighlight on/off` | Enable/disable highlighting |
| `:ColorHighlight auto` | Enable auto-highlighting for configured filetypes |
| `:ColorHighlight background/foreground/virtualtext` | Set highlight mode |

### Other

| Command | Description |
|:--------|:------------|
| `:ColorHistory [count]` | Display recent colors |
| `:ColorSearch <query>` | Search presets by color name |
| `:ColorPickerTest` | Run built-in test suite |

<details>
<summary><b>Plug Mappings</b></summary>

<br>

| Plug Mapping | Description |
|:-------------|:------------|
| `<Plug>(colorpicker)` | Open full color picker |
| `<Plug>(colorpicker-at-cursor)` | Pick and replace color at cursor |
| `<Plug>(colorpicker-mini)` | Open mini color picker |
| `<Plug>(colorpicker-mini-at-cursor)` | Mini picker at cursor |
| `<Plug>(colorpicker-slider)` | Open picker in slider mode |
| `<Plug>(colorpicker-slider-at-cursor)` | Slider mode at cursor |
| `<Plug>(colorpicker-convert-hex)` | Convert to hex |
| `<Plug>(colorpicker-convert-rgb)` | Convert to rgb |
| `<Plug>(colorpicker-convert-hsl)` | Convert to hsl |
| `<Plug>(colorpicker-highlight-toggle)` | Toggle buffer highlighting |

```lua
vim.keymap.set("n", "<leader>cp", "<Plug>(colorpicker)")
vim.keymap.set("n", "<leader>cc", "<Plug>(colorpicker-at-cursor)")
```

</details>

---

## Keymaps

<details open>
<summary><b>Grid Navigation</b></summary>

| Key | Action |
|:----|:-------|
| `h` / `l` | Adjust hue (left/right) |
| `j` / `k` | Adjust lightness (down/up) |
| `J` / `K` | Adjust saturation (less/more) |
| `-` / `+` | Decrease/increase step multiplier |
| `[count]` | Use count prefix: `10h`, `50k` |

</details>

<details>
<summary><b>Color Mode & Format</b></summary>

| Key | Action |
|:----|:-------|
| `m` | Cycle mode: HEX → HSL → RGB → HSV → CMYK |
| `f` | Toggle format: standard/decimal |
| `o` | Cycle output format (language-aware) |

</details>

<details>
<summary><b>Actions</b></summary>

| Key | Action |
|:----|:-------|
| `#` | Enter hex color manually |
| `r` | Reset to original color |
| `Enter` | Apply and close |
| `q` / `Esc` | Cancel and close |
| `?` | Show help |

</details>

<details>
<summary><b>Tab Navigation (Full Picker)</b></summary>

| Key | Action |
|:----|:-------|
| `g1` | Info tab (sliders) |
| `g2` | History tab |
| `g3` | Presets tab |
| `Tab` / `S-Tab` | Focus next/previous panel |

</details>

<details>
<summary><b>Mini Picker</b></summary>

| Key | Action |
|:----|:-------|
| `s` | Toggle between grid and slider mode |
| `a` / `A` | Decrease/increase alpha |

<p align="center">
  <img src="assets/mini-picker.gif" alt="Mini picker demo" width="640">
</p>

</details>

<details>
<summary><b>Slider Mode</b></summary>

<p align="center">
  <img src="assets/slider-mode.gif" alt="Slider mode demo" width="640">
</p>

</details>

---

## Color Format Support

### Universal Formats

| Format | Pattern | Example |
|:-------|:--------|:--------|
| HEX (6-digit) | `#RRGGBB` | `#FF5500` |
| HEX (3-digit) | `#RGB` | `#F50` |
| HEX (8-digit) | `#RRGGBBAA` | `#FF550080` |
| RGB | `rgb(r, g, b)` | `rgb(255, 85, 0)` |
| RGBA | `rgba(r, g, b, a)` | `rgba(255, 85, 0, 0.5)` |
| HSL | `hsl(h, s%, l%)` | `hsl(20, 100%, 50%)` |
| HSLA | `hsla(h, s%, l%, a)` | `hsla(20, 100%, 50%, 0.5)` |
| Vim highlight | `guifg=#RRGGBB` | `guifg=#FF5500` |

### Language-Specific Formats

<details>
<summary><b>Supported Languages</b></summary>

<br>

| Language | Formats Detected |
|:---------|:-----------------|
| **CSS/SCSS/LESS** | `hex`, `rgb()`, `rgba()`, `hsl()`, `hsla()`, `hwb()`, `lab()`, `lch()`, `oklch()` |
| **JavaScript/TypeScript** | `hex`, `rgb()`, `hsl()`, `0xRRGGBB` |
| **Go** | `color.RGBA{r,g,b,a}`, `color.NRGBA{}`, `{r,g,b,a}`, `0xRRGGBB`, `0xAARRGGBB` |
| **C++/Qt** | `QColor("#hex")`, `QColor(r,g,b)`, `QColor::fromRgbF()`, `{r,g,b,a}`, `{0.5f,0.3f,0.1f}`, `0xRRGGBB` |
| **Rust** | `Color::rgb()`, `Color::rgba()`, `Color::srgb()`, `Srgba::new()`, `hex!()`, `0xRRGGBB` |
| **Kotlin/Android** | `Color(0xAARRGGBB)`, `Color.parseColor()`, `0xAARRGGBB` |
| **Swift/SwiftUI** | `Color(red:green:blue:)`, `UIColor()`, `NSColor()`, `#colorLiteral()` |
| **Dart/Flutter** | `Color(0xAARRGGBB)`, `Color.fromARGB()`, `Color.fromRGBO()`, `Colors.name` |
| **C#/Unity** | `Color(r,g,b,a)`, `Color32(r,g,b,a)`, `new Color()`, `Color.name` |
| **Python** | `(r,g,b)`, `(r,g,b,a)`, `pygame.Color()`, hex strings |
| **Lua/Love2D** | `{r,g,b}`, `{r,g,b,a}`, `love.graphics` colors |
| **GLSL/HLSL/Metal** | `vec3()`, `vec4()`, `float3()`, `float4()` |

</details>

<details>
<summary><b>Multi-Language Detection Demo</b></summary>

<p align="center">
  <img src="assets/multi-language.gif" alt="Multi-language color detection demo" width="640">
</p>

The demo shows:
1. Detecting and editing `color.RGBA{}` in Go
2. Detecting and editing `QColor()` in C++
3. Detecting and editing float struct `{0.384f, 0.000f, 0.933f}` in C++
4. Detecting and editing `Color::srgb()` in Rust

</details>

<details>
<summary><b>Output Format Cycling Demo</b></summary>

<p align="center">
  <img src="assets/output-format.gif" alt="Output format cycling demo" width="640">
</p>

The demo shows:
1. Opening the picker on a Go `color.RGBA{}` color
2. Pressing `o` to cycle through available formats
3. Selecting a different output format before applying
4. The color is replaced using the selected format

</details>

<details>
<summary><b>Format Conversion Demo</b></summary>

<p align="center">
  <img src="assets/conversion.gif" alt="Color conversion demo" width="640">
</p>

</details>

---

## Lua API

```lua
local colorpicker = require("nvim-colorpicker")
```

<details open>
<summary><b>Main Functions</b></summary>

| Function | Description |
|:---------|:------------|
| `colorpicker.setup(opts)` | Initialize with configuration |
| `colorpicker.pick(opts)` | Open picker with options |
| `colorpicker.pick_at_cursor()` | Pick color at cursor |
| `colorpicker.pick_mini(opts)` | Open mini picker |
| `colorpicker.pick_mini_at_cursor()` | Mini picker at cursor |
| `colorpicker.pick_mini_slider(opts)` | Open slider mode |
| `colorpicker.get_color()` | Get current color in open picker |
| `colorpicker.set_color(new, original)` | Set color in open picker |
| `colorpicker.is_open()` | Check if picker is open |
| `colorpicker.is_mini_open()` | Check if mini picker is open |

</details>

<details>
<summary><b>Pick Options</b></summary>

<br>

```lua
colorpicker.pick({
  color = "#ff5500",
  alpha_enabled = true,
  target_filetype = "go",
  original_format = "color_rgba",
  on_select = function(result)
    print("Selected: " .. result.color)
    print("Raw hex: " .. result.hex)
  end,
  on_cancel = function()
    print("Cancelled")
  end,
  on_change = function(result)
    -- Live preview on every change
  end,
})
```

</details>

<details>
<summary><b>Highlighting</b></summary>

<br>

| Function | Description |
|:---------|:------------|
| `colorpicker.toggle_highlight()` | Toggle buffer highlighting |
| `colorpicker.enable_highlight()` | Enable highlighting |
| `colorpicker.disable_highlight()` | Disable highlighting |
| `colorpicker.enable_auto_highlight(patterns)` | Enable for file patterns |
| `colorpicker.set_highlight_mode(mode)` | Set display mode |

<p align="center">
  <img src="assets/highlighting.gif" alt="Highlighting modes demo" width="640">
</p>

</details>

<details>
<summary><b>History & Clipboard</b></summary>

<br>

| Function | Description |
|:---------|:------------|
| `colorpicker.yank(color?, format?)` | Copy color to clipboard |
| `colorpicker.paste()` | Paste color from clipboard |
| `colorpicker.get_recent_colors(count)` | Get recent colors |
| `colorpicker.add_recent_color(color)` | Add to history |

</details>

<details>
<summary><b>Utilities</b></summary>

<br>

```lua
local utils = colorpicker.utils()
local r, g, b = utils.hex_to_rgb("#ff5500")
local hex = utils.rgb_to_hex(255, 85, 0)
```

</details>

---

## External Plugin Integration

nvim-colorpicker can be integrated into other plugins using callbacks and custom controls.

<details>
<summary><b>Integration Demo</b></summary>

<p align="center">
  <img src="assets/external-usage.gif" alt="External plugin integration demo" width="640">
</p>

The demo shows SSNS Theme Editor using the colorpicker with custom controls for foreground/background toggle and bold/italic styling.

</details>

<details>
<summary><b>Basic Integration</b></summary>

<br>

```lua
colorpicker.pick({
  color = initial_color,
  title = "Edit Color",
  on_change = function(result)
    update_preview(result.color)
  end,
  on_select = function(result)
    save_color(result.color)
  end,
  on_cancel = function()
    restore_original()
  end,
})
```

</details>

<details>
<summary><b>Custom Controls</b></summary>

<br>

```lua
colorpicker.pick({
  custom_controls = {
    {
      id = "target",
      type = "select",
      label = "Target",
      options = { "fg", "bg" },
      default = "fg",
      key = "B",
      on_change = function(new_value, old_value)
        -- Handle target switch
      end,
    },
    {
      id = "bold",
      type = "toggle",
      label = "Bold",
      default = false,
      key = "b",
    },
  },
  on_select = function(result)
    local target = result.custom.target
    local bold = result.custom.bold
    -- Use custom values...
  end,
})
```

**Control Types:** `toggle`, `select`, `number`, `text`

</details>

---

## UI Layouts

<details>
<summary><b>Full Picker</b></summary>

```
┌─────────────────────────────────────────────────────────────┐
│  #FF5500 HSL 20° 100% 50% Step: 1x                        │
├────────────────────────────────┬────────────────────────────┤
│                                │  [Info] [History] [Presets]│
│         Color Grid (HSL)       │                            │
│ ██████████████████████████████ │  H: ████████░░░░  20°      │
│ ██████████████████████████████ │  S: ████████████  100%     │
│ ██████████████x ← cursor██████ │  L: ██████░░░░░░  50%      │
│ ██████████████████████████████ │  A: ████████████  100%     │
│ ██████████████████████████████ │                            │
│                                │                            │
├────────────────────────────────│                            │
│───Original────┬────Current──── │                            │
│███████████████│███████████████ │                            │
└────────────────────────────────┴────────────────────────────┘
```

</details>

<details>
<summary><b>Mini Picker</b></summary>

```
┌─ #FF5500 HSL Step: 1x ────────────────┐
│                                         │
│     Color Grid (compact)                │
│              x                          │
│                                         │
│                                         │
├──────Original──────┬──────Current───────┤
│████████████████████│████████████████████│
└─────────────────────────────────────────┘
```

</details>

<details>
<summary><b>Slider Mode</b></summary>

```
┌─ #FF5500 HSL Step: 1x ────────────────┐
│                                         │
│  H: ████████░░░░  20°                   │
│  S: ████████████  100%                  │
│  L: ██████░░░░░░  50%                   │
│                                         │
├──────Original──────┬──────Current───────┤
│████████████████████│████████████████████│
└─────────────────────────────────────────┘
```

</details>

---

## FAQ

<details>
<summary><b>Colors not displaying properly?</b></summary>

<br>

Ensure `termguicolors` is enabled:

```lua
vim.opt.termguicolors = true
```

</details>

<details>
<summary><b>Custom keymaps not working?</b></summary>

<br>

If using custom navigation keys, disable auto-detection:

```lua
require("nvim-colorpicker").setup({
  inherit_movement_keys = false,
  keymaps = { ... },
})
```

</details>

<details>
<summary><b>Highlighting appears in wrong buffers?</b></summary>

<br>

Refine your exclude list:

```lua
highlight = {
  exclude_filetypes = {
    "lazy", "mason", "help", "TelescopePrompt",
    "NvimTree", "neo-tree", "dashboard", "alpha",
  },
}
```

</details>

<details>
<summary><b>How do I run tests?</b></summary>

<br>

```vim
:ColorPickerTest      " Show results in UI
:ColorPickerTest run  " Print to console
:ColorPickerTest last " Show previous results
```

</details>

---

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Commit your changes (`git commit -m 'Add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

---

## Issues

Found a bug or have a feature request? Please open an issue on [GitHub Issues](https://github.com/mikevskater/nvim-colorpicker/issues).

<table>
<tr>
<td>

**When opening an issue, please include:**

- **Bug or Feature** — Label your issue type
- **Description** — Clear description of the issue or feature
- **Steps to Reproduce** — Minimal steps to reproduce (for bugs)
- **Expected Behavior** — What you expected to happen

</td>
</tr>
</table>

---

<div align="center">

## License

MIT License — see [LICENSE](LICENSE) for details.

<br>

Made with Lua for Neovim

</div>
