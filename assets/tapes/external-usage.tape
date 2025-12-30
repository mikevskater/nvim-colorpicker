# External Plugin Integration Demo
# Demonstrates: Using nvim-colorpicker in SSNS Theme Editor
#
# Run: vhs external-usage.tape
# Output: ../external-usage.gif

Output ../external-usage.gif

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

# Start fresh neovim
Hide
Type "nvim"
Enter
Sleep 2s
Show

# Open SSNS Theme Editor
Sleep 500ms
Type ":SSNSThemeEditor"
Enter
Sleep 1000ms

# Navigate to first custom theme (press j once)
Type "j"
Sleep 600ms

# Enter edit mode with Tab
Type "	"
Sleep 600ms

# Navigate down to "databases" item (7 moves)
Type "jjjjjjj"
Sleep 500ms

# Open color picker to edit this item
Enter
Sleep 800ms

# Move around the color grid to change FG color (5 right, 3 up, 2 sat up)
Type "lllll"
Sleep 300ms
Type "kkk"
Sleep 300ms
Type "KK"
Sleep 400ms

# Toggle to background color mode
Type "B"
Sleep 800ms

# Bring saturation up - bg starts at 0 (10 sat up)
Type "KKKKKKKKKK"
Sleep 400ms

# Move around to pick a background color (10 left, 5 down)
Type "hhhhhhhhhh"
Sleep 300ms
Type "jjjjj"
Sleep 400ms

# Toggle italic
Type "i"
Sleep 500ms

# Toggle bold
Type "b"
Sleep 500ms

# Apply the color changes
Enter
Sleep 600ms

# Move down so highlight doesn't cover the changed row
Type "j"
Sleep 1000ms

# Exit
Hide
Type ":q!"
Enter
