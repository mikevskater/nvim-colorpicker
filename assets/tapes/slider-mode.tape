# Slider Mode Demo - Mini Picker Slider Toggle
# Demonstrates: Toggle between grid and slider mode, precise adjustments
#
# Run: vhs slider-mode.tape
# Output: ../slider-mode.gif

Output ../slider-mode.gif

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

# Position cursor on a color
Sleep 500ms
Type ":14"
Enter
Sleep 300ms
Type "f#"
Sleep 500ms

# Open mini picker at cursor (starts in grid mode)
Type ":ColorPickerMiniAtCursor"
Enter
Sleep 800ms

# Navigate grid briefly (3 right, 1 up)
Type "lll"
Sleep 300ms
Type "k"
Sleep 400ms

# Toggle to slider mode
Type "s"
Sleep 800ms

# Navigate sliders - move down to saturation slider (1 down)
Type "j"
Sleep 300ms

# Adjust slider value (3 up)
Type "+++"
Sleep 300ms

# Move to lightness slider (1 down)
Type "j"
Sleep 300ms

# Adjust lightness (2 down)
Type "--"
Sleep 300ms

# Move back to hue slider (2 up)
Type "kk"
Sleep 300ms

# Adjust hue (4 up)
Type "++++"
Sleep 300ms

# Toggle back to grid mode
Type "s"
Sleep 800ms

# Show grid reflects changes
Sleep 400ms

# Apply
Enter
Sleep 800ms

# Show result
Sleep 800ms

# Exit
Hide
Type ":q!"
Enter
