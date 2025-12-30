# Mini Picker Demo - Compact Inline Color Picker
# Demonstrates: Mini picker, quick color adjustments
#
# Run: vhs mini-picker.tape
# Output: ../mini-picker.gif

Output ../mini-picker.gif

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

# Position cursor on a color (line 17: background-color: #3b82f6)
Sleep 500ms
Type ":14"
Enter
Sleep 300ms
Type "f#"
Sleep 500ms

# Open mini picker at cursor
Type ":ColorPickerMiniAtCursor"
Enter
Sleep 800ms

# Navigate the mini grid (4 right, 2 up, 1 sat up)
Type "llll"
Sleep 300ms
Type "kk"
Sleep 300ms
Type "K"
Sleep 300ms

# Adjust hue more (3 right, 1 down)
Type "lll"
Sleep 300ms
Type "j"
Sleep 300ms

# Show step size change (2 right with larger step)
Type "+"
Sleep 300ms
Type "ll"
Sleep 400ms

# Apply
Enter
Sleep 800ms

# Show the changed color
Sleep 500ms

# Move to another color (line 21: background: #313244)
Type ":21"
Enter
Sleep 300ms
Type "f#"
Sleep 400ms

# Open mini picker again
Type ":ColorPickerMiniAtCursor"
Enter
Sleep 600ms

# Quick adjustment (5 left, 2 up, 1 sat down)
Type "hhhhh"
Sleep 300ms
Type "kk"
Sleep 300ms
Type "J"
Sleep 300ms

# Cancel this one
Type "q"
Sleep 600ms

# Show original preserved
Sleep 800ms

# Exit
Hide
Type ":q!"
Enter
