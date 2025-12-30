# Color Conversion Demo - Format Cycling and Conversion
# Demonstrates: Convert colors between hex, rgb, hsl formats
#
# Run: vhs conversion.tape
# Output: ../conversion.gif

Output ../conversion.gif

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

# Position on a hex color
Sleep 500ms
Type ":5"
Enter
Sleep 300ms
Type "f#"
Sleep 500ms

# Convert to RGB
Type ":ColorConvert rgb"
Enter
Sleep 1000ms

# Show the converted color
Sleep 500ms

# Convert to HSL
Type ":ColorConvert hsl"
Enter
Sleep 1000ms

# Show the HSL format
Sleep 500ms

# Convert back to hex
Type ":ColorConvert hex"
Enter
Sleep 1000ms

# Move to another color
Type ":6"
Enter
Sleep 300ms
Type "f#"
Sleep 400ms

# Yank to clipboard as RGB
Type ":ColorYank rgb"
Enter
Sleep 800ms

# Show message
Sleep 600ms

# Exit
Hide
Type ":q!"
Enter
