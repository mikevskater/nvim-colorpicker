# Multi-Language Color Detection Demo
# Demonstrates: Color detection and editing in Go, C++, and Rust
#
# Run: vhs multi-language.tape
# Output: ../multi-language.gif

Output ../multi-language.gif

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
# DEMO 1: Go - color.RGBA{} detection
# ============================================================================

Hide
Type "nvim ../../examples/colors.go"
Enter
Sleep 2s
Show

Sleep 500ms

# Position cursor on Primary color line (color.RGBA{98, 0, 238, 255})
Type ":14"
Enter
Sleep 300ms
Type "f{"
Sleep 100ms
Escape
Sleep 500ms

# Open color picker at cursor - detects color.RGBA format
Type ":ColorPickerAtCursor"
Enter
Sleep 1s

# Adjust the color
Type "llllll"
Sleep 300ms
Type "kkk"
Sleep 300ms
Type "KK"
Sleep 500ms

# Apply - outputs in Go format
Enter
Sleep 800ms

# Show the result (color.RGBA{...} format preserved)
Sleep 600ms

# ============================================================================
# DEMO 2: C++ - QColor detection
# ============================================================================

# Open C++ file
Type ":e ../../examples/colors.cpp"
Enter
Sleep 800ms

# Position cursor on QColor int RGB (line 11: Primary = QColor(98, 0, 238))
Type ":11"
Enter
Sleep 300ms
Type "f("
Sleep 100ms
Escape
Sleep 500ms

# Open color picker - detects QColor format
Type ":ColorPickerAtCursor"
Enter
Sleep 1s

# Adjust color
Type "hhhhhh"
Sleep 300ms
Type "jjj"
Sleep 500ms

# Apply - outputs as QColor(r, g, b)
Enter
Sleep 800ms

# Show result
Sleep 600ms

# ============================================================================
# DEMO 3: C++ - Float struct detection
# ============================================================================

# Position on float struct color (line 87: Primary = {0.384f, 0.000f, 0.933f, 1.00f})
Type ":87"
Enter
Sleep 300ms
Type "f{"
Sleep 100ms
Escape
Sleep 500ms

# Open color picker - detects float struct format
Type ":ColorPickerAtCursor"
Enter
Sleep 1s

# Adjust to a colored value
Type "llllllllll"
Sleep 300ms
Type "kk"
Sleep 300ms
Type "JJ"
Sleep 500ms

# Apply - outputs as {0.xxxf, 0.xxxf, 0.xxxf, 1.00f}
Enter
Sleep 800ms

Sleep 600ms

# ============================================================================
# DEMO 4: Rust - Color::srgb() detection
# ============================================================================

# Open Rust file
Type ":e ../../examples/colors.rs"
Enter
Sleep 800ms

# Position on Color::srgb (line 12: PRIMARY)
Type ":12"
Enter
Sleep 300ms
Type "f("
Sleep 100ms
Escape
Sleep 500ms

# Open color picker - detects Rust Color format
Type ":ColorPickerAtCursor"
Enter
Sleep 1s

# Adjust color
Type "llll"
Sleep 300ms
Type "KKK"
Sleep 500ms

# Apply - outputs as Color::srgb(...)
Enter
Sleep 800ms

# Show final result
Sleep 1s

# Exit
Hide
Type ":qa!"
Enter
