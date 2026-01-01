// =============================================================================
// Rust Color Formats Example
// nvim-colorpicker detects and can replace all these formats
// =============================================================================

use bevy::prelude::*;

// Bevy srgb format (floats 0.0-1.0)
pub mod bevy_colors {
    use super::*;

    pub const PRIMARY: Color = Color::srgb(0.384, 0.000, 0.933);
    pub const SECONDARY: Color = Color::srgb(0.012, 0.855, 0.776);
    pub const BACKGROUND: Color = Color::srgb(0.071, 0.071, 0.071);
    pub const SURFACE: Color = Color::srgb(0.118, 0.118, 0.118);
    pub const ERROR: Color = Color::srgb(0.812, 0.400, 0.475);
    pub const SUCCESS: Color = Color::srgb(0.400, 0.733, 0.416);
}

// Bevy srgba format (with alpha)
pub mod transparent_colors {
    use super::*;

    pub const OVERLAY: Color = Color::srgba(0.000, 0.000, 0.000, 0.50);
    pub const HIGHLIGHT: Color = Color::srgba(0.384, 0.000, 0.933, 0.25);
    pub const GLASS: Color = Color::srgba(1.000, 1.000, 1.000, 0.10);
    pub const SHADOW: Color = Color::srgba(0.000, 0.000, 0.000, 0.60);
    pub const FADE: Color = Color::srgba(0.071, 0.071, 0.071, 0.00);
}

// Bevy hex format
pub mod hex_colors {
    use super::*;

    pub const RED: Color = Color::hex("#FF5722").unwrap();
    pub const PINK: Color = Color::hex("#E91E63").unwrap();
    pub const PURPLE: Color = Color::hex("#9C27B0").unwrap();
    pub const BLUE: Color = Color::hex("#2196F3").unwrap();
    pub const CYAN: Color = Color::hex("#00BCD4").unwrap();
    pub const GREEN: Color = Color::hex("#4CAF50").unwrap();
    pub const YELLOW: Color = Color::hex("#FFEB3B").unwrap();
    pub const ORANGE: Color = Color::hex("#FF9800").unwrap();

    // Without # prefix
    pub const WHITE: Color = Color::hex("FFFFFF").unwrap();
    pub const BLACK: Color = Color::hex("000000").unwrap();

    // With alpha
    pub const SEMI_RED: Color = Color::hex("#80FF5722").unwrap();
}

// Dark theme
pub mod dark_theme {
    use super::*;

    pub const BACKGROUND: Color = Color::srgb(0.102, 0.102, 0.180);
    pub const SURFACE: Color = Color::srgb(0.086, 0.129, 0.243);
    pub const PRIMARY: Color = Color::srgb(0.059, 0.204, 0.376);
    pub const ACCENT: Color = Color::srgb(0.914, 0.271, 0.376);
    pub const TEXT: Color = Color::srgb(0.918, 0.918, 0.918);
    pub const TEXT_MUTED: Color = Color::srgba(0.667, 0.686, 0.749, 0.667);
}

// Game colors
pub mod game_palette {
    use super::*;

    pub const PLAYER: Color = Color::srgb(0.310, 0.765, 0.969);
    pub const ENEMY: Color = Color::srgb(0.937, 0.325, 0.314);
    pub const COLLECTIBLE: Color = Color::srgb(1.000, 0.835, 0.310);
    pub const OBSTACLE: Color = Color::srgb(0.471, 0.565, 0.612);
    pub const HEALTH: Color = Color::srgb(0.400, 0.733, 0.416);
    pub const MANA: Color = Color::srgb(0.671, 0.278, 0.737);
}

// Macroquad style (if using macroquad crate)
#[cfg(feature = "macroquad")]
pub mod macroquad_colors {
    use macroquad::prelude::*;

    pub const RED: Color = Color::new(1.00, 0.00, 0.00, 1.00);
    pub const GREEN: Color = Color::new(0.00, 1.00, 0.00, 1.00);
    pub const BLUE: Color = Color::new(0.00, 0.00, 1.00, 1.00);
    pub const YELLOW: Color = Color::new(1.00, 1.00, 0.00, 1.00);
    pub const CYAN: Color = Color::new(0.00, 1.00, 1.00, 1.00);
    pub const MAGENTA: Color = Color::new(1.00, 0.00, 1.00, 1.00);

    // Semi-transparent
    pub const GLASS: Color = Color::new(0.80, 0.90, 1.00, 0.20);
    pub const SHADOW: Color = Color::new(0.00, 0.00, 0.00, 0.50);
}

// Gradient colors
pub fn sunset_gradient() -> Vec<Color> {
    vec![
        Color::srgb(1.000, 0.341, 0.133),
        Color::srgb(1.000, 0.596, 0.000),
        Color::srgb(1.000, 0.922, 0.231),
    ]
}

pub fn ocean_gradient() -> Vec<Color> {
    vec![
        Color::srgb(0.000, 0.737, 0.831),
        Color::srgb(0.129, 0.588, 0.953),
        Color::srgb(0.247, 0.318, 0.710),
    ]
}
