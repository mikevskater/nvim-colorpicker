# Output Format Cycling Demo
# Demonstrates: Using 'o' key to cycle through available output formats
#
# Run: vhs output-format.tape
# Output: ../output-format.gif

Output ../output-format.gif

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

# ============================================================================
# DEMO: Output Format Cycling in Go
# ============================================================================

Hide
Type "nvim ../../examples/colors.go"
Enter
Sleep 2s
Show

Sleep 500ms

# Position cursor on Primary (color.RGBA{98, 0, 238, 255})
Type ":14"
Enter
Sleep 300ms
Type "f{"
Sleep 100ms
Escape
Sleep 500ms

# Open color picker at cursor
Type ":ColorPickerAtCursor"
Enter
Sleep 1s

# Show the info panel with output preview
# The "Out:" line shows the current output format
Sleep 500ms

# Cycle output format with 'o' key
# Go adapter has: color_rgba, color_rgba_named, color_nrgba, struct_rgba, hex_numeric, hex
Type "o"
Sleep 800ms

Type "o"
Sleep 800ms

Type "o"
Sleep 800ms

Type "o"
Sleep 800ms

Type "o"
Sleep 800ms

# Back to original format
Type "o"
Sleep 800ms

# Now adjust the color
Type "llllll"
Sleep 300ms
Type "kkk"
Sleep 500ms

# Cycle to a different output format before applying
Type "oo"
Sleep 600ms

# Apply with the selected format
Enter
Sleep 800ms

# Show the result - color is now in the selected format
Sleep 1s

# ============================================================================
# DEMO 2: Output Format Cycling in C++
# ============================================================================

# Open C++ file
Type ":e ../../examples/colors.cpp"
Enter
Sleep 800ms

# Position on QColor with RGB (line 11)
Type ":11"
Enter
Sleep 300ms
Type "f("
Sleep 100ms
Escape
Sleep 500ms

# Open color picker
Type ":ColorPickerAtCursor"
Enter
Sleep 1s

# Cycle through C++ formats
# C++ adapter has: qcolor_hex, qcolor_rgb, qcolor_rgba, qcolor_fromrgbf, struct_rgb, hex_numeric, hex
Type "o"
Sleep 700ms

Type "o"
Sleep 700ms

Type "o"
Sleep 700ms

Type "o"
Sleep 700ms

# Select a format and apply
Enter
Sleep 800ms

# Show result
Sleep 1s

# Exit
Hide
Type ":qa!"
Enter
