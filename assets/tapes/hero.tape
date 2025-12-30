# Hero Demo - Full Color Picker Showcase
# Demonstrates: Grid navigation, slider adjustments, presets, and history
#
# Run: vhs hero.tape
# Output: ../hero.gif

Output ../hero.gif

# Terminal settings
Set Shell "cmd"
Set FontSize 14
Set Width 1280
Set Height 720
Set Padding 20
Set WindowBar Colorful
Set BorderRadius 8
Set Theme "Catppuccin Mocha"

# Recording settings
Set TypingSpeed 75ms
Set Framerate 15
Set PlaybackSpeed 1.0
Set CursorBlink false

# Setup - open neovim with sample file
Hide
Type "nvim sample.css"
Enter
Sleep 2s
Show

# ============================================================================
# DEMO 1: Grid Navigation + Slider Adjustments
# ============================================================================

# Position cursor on first color (line 4: --primary)
Sleep 500ms
Type ":4"
Enter
Sleep 300ms
Type "f#"
Sleep 100ms
Escape
Sleep 500ms

# Open color picker at cursor
Type ":ColorPickerAtCursor"
Enter
Sleep 1s

# Navigate the color grid (8 right, 3 up, 2 sat up)
Type "llllllll"
Sleep 400ms
Type "kkk"
Sleep 400ms
Type "KK"
Sleep 500ms

# Tab to info panel (sliders)
Tab
Sleep 600ms

# Navigate to saturation slider (2 down)
Type "jj"
Sleep 300ms

# Adjust saturation with h/l
Type "--------"
Sleep 400ms

# Navigate to lightness slider (1 down)
Type "j"
Sleep 300ms

# Adjust lightness
Type "++++++"
Sleep 500ms

# Navigate to alpha slider (1 down)
Type "j"
Sleep 300ms

# Adjust alpha
Type "--------"
Sleep 400ms

# Tab back to grid
Tab
Sleep 600ms

# Apply the color (adds to history)
Enter
Sleep 800ms

# Show result
Sleep 600ms

# ============================================================================
# DEMO 2: Presets - Browse and Select
# ============================================================================

# Position cursor on second color (line 5: --secondary)
Type ":5"
Enter
Sleep 300ms
Type "f#"
Sleep 100ms
Escape
Sleep 500ms

# Open color picker
Type ":ColorPickerAtCursor"
Enter
Sleep 800ms

# Switch to Presets tab (g3)
Type "g3"
Sleep 600ms

# Tab to focus on presets panel
Tab
Sleep 500ms

# Navigate down to a preset category (3 down)
Type "jj"
Sleep 200ms

# Expand the category
Enter
Sleep 500ms

# Navigate into expanded color category (2 down)
Type "jj"
Sleep 200ms

# Select category
Enter
Sleep 500ms

# Navigate into items (2 down)
Type "jj"
Sleep 200ms

# Select item
Enter
Sleep 200ms

# Tab back to grid
Tab
Sleep 500ms

# Apply the color (adds to history)
Enter
Sleep 800ms

# Show result
Sleep 600ms

# ============================================================================
# DEMO 3: History - Reuse Previous Colors
# ============================================================================

# Position cursor on third color (line 6: --accent)
Type ":6"
Enter
Sleep 300ms
Type "f#"
Sleep 100ms
Escape
Sleep 500ms

# Open color picker
Type ":ColorPickerAtCursor"
Enter
Sleep 800ms

# Switch to History tab (g2)
Type "g2"
Sleep 600ms

# Tab to focus on history panel
Tab
Sleep 500ms

# Navigate to a history item (1 down - pick first color we edited)
Type "j"
Sleep 400ms

# Select from history - jumps to that color
Enter
Sleep 600ms

# Tab back to grid
Tab
Sleep 500ms

# Apply the color
Enter
Sleep 800ms

# Show final result
Sleep 1s

# Exit
Hide
Type ":q!"
Enter
