// =============================================================================
// Go Color Formats Example
// nvim-colorpicker detects and can replace all these formats
// =============================================================================

package colors

import (
	"image/color"
)

// Standard library color.RGBA (premultiplied alpha)
var (
	Primary    = color.RGBA{98, 0, 238, 255}
	Secondary  = color.RGBA{3, 218, 198, 255}
	Background = color.RGBA{18, 18, 18, 255}
	Surface    = color.RGBA{30, 30, 30, 255}
	Error      = color.RGBA{207, 102, 121, 255}
	Success    = color.RGBA{102, 187, 106, 255}
)

// Basic colors
var (
	Red     = color.RGBA{255, 0, 0, 255}
	Green   = color.RGBA{0, 255, 0, 255}
	Blue    = color.RGBA{0, 0, 255, 255}
	Yellow  = color.RGBA{255, 255, 0, 255}
	Cyan    = color.RGBA{0, 255, 255, 255}
	Magenta = color.RGBA{255, 0, 255, 255}
	White   = color.RGBA{255, 255, 255, 255}
	Black   = color.RGBA{0, 0, 0, 255}
)

// Semi-transparent colors
var (
	Overlay   = color.RGBA{0, 0, 0, 128}
	Highlight = color.RGBA{98, 0, 238, 64}
	Glass     = color.RGBA{255, 255, 255, 26}
	Shadow    = color.RGBA{0, 0, 0, 153}
)

// color.NRGBA (non-premultiplied alpha) - more intuitive for UI work
var (
	OverlayN   = color.NRGBA{0, 0, 0, 128}
	HighlightN = color.NRGBA{98, 0, 238, 64}
	GlassN     = color.NRGBA{255, 255, 255, 26}
	ShadowN    = color.NRGBA{0, 0, 0, 153}
)

// Material Design colors
var MaterialColors = struct {
	Red    color.RGBA
	Pink   color.RGBA
	Purple color.RGBA
	Blue   color.RGBA
	Cyan   color.RGBA
	Green  color.RGBA
	Yellow color.RGBA
	Orange color.RGBA
}{
	Red:    color.RGBA{244, 67, 54, 255},
	Pink:   color.RGBA{233, 30, 99, 255},
	Purple: color.RGBA{156, 39, 176, 255},
	Blue:   color.RGBA{33, 150, 243, 255},
	Cyan:   color.RGBA{0, 188, 212, 255},
	Green:  color.RGBA{76, 175, 80, 255},
	Yellow: color.RGBA{255, 235, 59, 255},
	Orange: color.RGBA{255, 152, 0, 255},
}

// Dark theme colors
var DarkTheme = struct {
	Background color.RGBA
	Surface    color.RGBA
	Primary    color.RGBA
	Accent     color.RGBA
	Text       color.RGBA
	TextMuted  color.NRGBA
}{
	Background: color.RGBA{26, 26, 46, 255},
	Surface:    color.RGBA{22, 33, 62, 255},
	Primary:    color.RGBA{15, 52, 96, 255},
	Accent:     color.RGBA{233, 69, 96, 255},
	Text:       color.RGBA{234, 234, 234, 255},
	TextMuted:  color.NRGBA{170, 175, 191, 170},
}

// Game palette
var GamePalette = struct {
	Player      color.RGBA
	Enemy       color.RGBA
	Collectible color.RGBA
	Obstacle    color.RGBA
	Health      color.RGBA
	Mana        color.RGBA
}{
	Player:      color.RGBA{79, 195, 247, 255},
	Enemy:       color.RGBA{239, 83, 80, 255},
	Collectible: color.RGBA{255, 213, 79, 255},
	Obstacle:    color.RGBA{120, 144, 156, 255},
	Health:      color.RGBA{102, 187, 106, 255},
	Mana:        color.RGBA{171, 71, 188, 255},
}

// Gradient colors
func SunsetGradient() []color.RGBA {
	return []color.RGBA{
		{255, 87, 34, 255},
		{255, 152, 0, 255},
		{255, 235, 59, 255},
	}
}

func OceanGradient() []color.RGBA {
	return []color.RGBA{
		{0, 188, 212, 255},
		{33, 150, 243, 255},
		{63, 81, 181, 255},
	}
}

// Helper to create color from hex
func FromHex(hex uint32) color.RGBA {
	return color.RGBA{
		R: uint8((hex >> 16) & 0xFF),
		G: uint8((hex >> 8) & 0xFF),
		B: uint8(hex & 0xFF),
		A: 255,
	}
}

// Hex color constants
const (
	HexRed    = 0xFF5722
	HexPink   = 0xE91E63
	HexPurple = 0x9C27B0
	HexBlue   = 0x2196F3
	HexCyan   = 0x00BCD4
	HexGreen  = 0x4CAF50
	HexYellow = 0xFFEB3B
	HexOrange = 0xFF9800
)
