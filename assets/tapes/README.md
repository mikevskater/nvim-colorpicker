# VHS Tape Files for nvim-colorpicker Demos

These tape files are used to generate GIF demos for the README using [VHS](https://github.com/charmbracelet/vhs).

## Prerequisites

Install VHS:

```bash
# macOS/Linux
brew install vhs

# Windows
scoop install vhs

# Or use Docker
docker run --rm -v $PWD:/vhs ghcr.io/charmbracelet/vhs <tape>.tape
```

VHS requires `ttyd` and `ffmpeg` to be installed.

## Tape Files

| File | Output | Description | Duration |
|------|--------|-------------|----------|
| `hero.tape` | `hero.gif` | Full showcase: grid+sliders, presets, history | ~25s |
| `quickstart.tape` | `quickstart.gif` | Minimal 5-second demo | ~5s |
| `mini-picker.tape` | `mini-picker.gif` | Compact inline picker | ~10s |
| `slider-mode.tape` | `slider-mode.gif` | Grid/slider toggle | ~10s |
| `highlighting.tape` | `highlighting.gif` | Buffer highlighting + live tracking | ~15s |
| `conversion.tape` | `conversion.gif` | Format conversion | ~8s |
| `external-usage.tape` | `external-usage.gif` | Plugin integration (SSNS Theme Editor) | ~12s |

## Generating GIFs

Run from the `assets/tapes` directory:

```bash
# Generate single demo
vhs hero.tape

# Generate all demos
for tape in *.tape; do vhs "$tape"; done
```

Output GIFs are saved to the parent `assets/` directory.

## Customization

### Shell Setting

On Windows, use `cmd` instead of `pwsh` (PowerShell hangs with VHS):
```
Set Shell "cmd"
```

### Tab Switching

Use `g1`/`g2`/`g3` to switch picker tabs (VHS doesn't support Alt keys or F-keys):
```
# Switch to History tab
Type "g2"

# Switch to Presets tab
Type "g3"

# Switch back to Info tab
Type "g1"
```

### Bulk Moves

Use repeated characters with comments for easy adjustment:
```
# Navigate grid (8 right, 3 up)
Type "llllllll"
Sleep 300ms
Type "kkk"

# Adjust slider (6 increments)
Type "++++++"
```

### Change Theme

Edit the `Set Theme` line. Popular options:
- `"Catppuccin Mocha"` (dark, recommended)
- `"Catppuccin Latte"` (light)
- `"Tokyo Night"`
- `"Dracula"`
- `"One Dark"`

### Change Font

```
```

### Adjust Timing

- `Set TypingSpeed 75ms` - Typing delay per character
- `Sleep 500ms` - Pause duration
- `Set PlaybackSpeed 1.5` - Speed up final GIF

### Reduce File Size

1. Lower framerate: `Set Framerate 15`
2. Reduce dimensions: `Set Width 800` / `Set Height 400`
3. Increase playback speed: `Set PlaybackSpeed 1.5`
4. Use shorter Sleep durations

## Sample File

The `sample.css` file provides colors for the demos. Ensure it's in the same directory when running tapes.

## Troubleshooting

**GIF too large?**
- Reduce `Framerate` to 15-20
- Use `Set PlaybackSpeed 1.5` or higher
- Crop dimensions smaller

**Colors look wrong?**
- Ensure `termguicolors` is enabled in your Neovim config
- Check the VHS theme matches your expectations

**Commands not working?**
- Verify nvim-colorpicker is installed and configured
- Check that sample.css exists in the working directory
