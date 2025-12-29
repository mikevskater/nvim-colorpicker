# nvim-colorpicker Interactive Tests

This directory contains example files for testing nvim-colorpicker features interactively.

## Setup

Make sure the plugin is loaded:
```lua
require('nvim-colorpicker').setup()
```

## Test Files

| File | Purpose |
|------|---------|
| `css_colors.css` | CSS color formats (hex, rgb, rgba, hsl, hsla) |
| `lua_colors.lua` | Lua/Neovim config colors |
| `js_colors.js` | JavaScript/TypeScript colors |
| `html_colors.html` | HTML inline styles |
| `tailwind.html` | Tailwind CSS classes (preset testing) |
| `vim_highlights.vim` | Vim highlight commands (guifg/guibg) |

## Commands to Test

### Color Picker
```vim
:ColorPicker              " Open picker with default color
:ColorPickerAtCursor      " Pick color under cursor and replace
```

### Buffer Highlighting
```vim
:ColorHighlight           " Toggle color highlighting in buffer
:ColorHighlightEnable     " Enable highlighting
:ColorHighlightDisable    " Disable highlighting
```

### Clipboard Operations
```vim
:ColorYank                " Copy color at cursor to clipboard
:ColorYank rgb            " Copy as rgb format
:ColorYank hsl            " Copy as hsl format
:ColorPaste               " Paste color from clipboard
```

### Format Conversion
```vim
:ColorConvert rgb         " Convert color at cursor to rgb
:ColorConvert hsl         " Convert color at cursor to hsl
:ColorConvert hex         " Convert color at cursor to hex
```

## Testing Checklist

### 1. Color Detection
- [ ] Cursor on hex color (#RRGGBB) detected
- [ ] Cursor on short hex (#RGB) detected
- [ ] Cursor on rgb() detected
- [ ] Cursor on rgba() detected
- [ ] Cursor on hsl() detected
- [ ] Cursor on hsla() detected
- [ ] Cursor on guifg=#RRGGBB detected

### 2. Color Picker UI
- [ ] Opens centered on screen
- [ ] Grid shows color variations
- [ ] h/l changes hue
- [ ] j/k changes lightness
- [ ] J/K changes saturation
- [ ] Enter confirms selection
- [ ] q/Esc cancels
- [ ] ? shows help

### 3. In-Place Replacement
- [ ] Hex replaced with new hex
- [ ] rgb() replaced with new rgb()
- [ ] hsl() replaced with new hsl()
- [ ] Format preserved after replacement

### 4. Buffer Highlighting
- [ ] Colors show inline preview
- [ ] Multiple colors on same line work
- [ ] Highlighting toggles on/off
- [ ] Works with different file types

### 5. Clipboard
- [ ] Yank copies correct color
- [ ] Yank with format converts correctly
- [ ] Paste inserts color
- [ ] Paste from external clipboard works

### 6. Presets
- [ ] Search finds web colors
- [ ] Search finds tailwind colors
- [ ] Search finds material colors
