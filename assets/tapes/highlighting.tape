# Buffer Highlighting Demo - Three Highlighting Modes
# Demonstrates: background, foreground, and virtualtext highlighting
#
# Run: vhs highlighting.tape
# Output: ../highlighting.gif

Output ../highlighting.gif

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

# Show the file without highlighting first
Sleep 800ms

# Enable background highlighting (default mode)
Type ":ColorHighlight background"
Enter
Sleep 1200ms

# Go to line 10 and add a new color to show live tracking
Type ":10"
Enter
Sleep 400ms
Type "o"
Sleep 300ms
Type "--new-color: #e91e63;"
Sleep 800ms
Escape
Sleep 600ms

# Edit an existing color to show live update
Type ":5"
Enter
Sleep 400ms
Type "f#"
Sleep 200ms
Type "l"
Sleep 200ms
Type "v5l"
Sleep 400ms
Type "c"
Sleep 200ms
Type "22c55e"
Sleep 600ms
Escape
Sleep 1000ms

# Switch to foreground mode
Type ":ColorHighlight foreground"
Enter
Sleep 1200ms

# Switch to virtualtext mode
Type ":ColorHighlight virtualtext"
Enter
Sleep 1200ms

# Turn off highlighting
Type ":ColorHighlight off"
Enter
Sleep 1000ms

# Exit
Hide
Type ":q!"
Enter
