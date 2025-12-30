# Quick Start Demo - Simple 5-second showcase
# Demonstrates: The core workflow in minimal time
#
# Run: vhs quickstart.tape
# Output: ../quickstart.gif

Output ../quickstart.gif

# Terminal settings
Set Shell "cmd"
Set FontSize 14
Set Width 1280
Set Height 720
Set Padding 20

# Recording settings
Set TypingSpeed 75ms
Set Framerate 15
Set PlaybackSpeed 1.0
Set CursorBlink false

# Setup
Hide
Type "nvim sample.css"
Enter
Sleep 2s
Type ":14"
Enter
Type "f#"
Show

Sleep 400ms

# Open picker
Type ":ColorPickerAtCursor"
Enter
Sleep 600ms

# Quick adjustments (5 right, 2 up, 1 sat up)
Type "lllll"
Sleep 250ms
Type "kk"
Sleep 250ms
Type "K"
Sleep 350ms

# Apply
Enter
Sleep 600ms

# Show result
Sleep 500ms

# Exit
Hide
Type ":q!"
Enter
