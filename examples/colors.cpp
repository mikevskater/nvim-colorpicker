// =============================================================================
// C++ Color Formats Example
// nvim-colorpicker detects and can replace all these formats
// =============================================================================

#include <QColor>
#include <cstdint>

// Qt QColor with integer RGB (0-255)
namespace QtColors {
    const QColor Primary = QColor(98, 0, 238);
    const QColor Secondary = QColor(3, 218, 198);
    const QColor Background = QColor(18, 18, 18);
    const QColor Surface = QColor(30, 30, 30);
    const QColor Error = QColor(207, 102, 121);
    const QColor Success = QColor(102, 187, 106);
}

// Qt QColor with alpha
namespace TransparentColors {
    const QColor Overlay = QColor(0, 0, 0, 128);
    const QColor Highlight = QColor(98, 0, 238, 64);
    const QColor Glass = QColor(255, 255, 255, 26);
    const QColor Shadow = QColor(0, 0, 0, 153);
}

// Qt QColor with float RGB (0.0-1.0)
namespace FloatColors {
    const QColor Primary = QColor::fromRgbF(0.384, 0.000, 0.933);
    const QColor Secondary = QColor::fromRgbF(0.012, 0.855, 0.776);
    const QColor Background = QColor::fromRgbF(0.071, 0.071, 0.071);
}

// Qt QColor with float RGBA
namespace FloatAlphaColors {
    const QColor Overlay = QColor::fromRgbF(0.000, 0.000, 0.000, 0.50);
    const QColor Highlight = QColor::fromRgbF(0.384, 0.000, 0.933, 0.25);
    const QColor Subtle = QColor::fromRgbF(1.000, 1.000, 1.000, 0.10);
}

// Numeric hex format (0xRRGGBB)
namespace HexColors {
    constexpr uint32_t RED = 0xFF5722;
    constexpr uint32_t PINK = 0xE91E63;
    constexpr uint32_t PURPLE = 0x9C27B0;
    constexpr uint32_t BLUE = 0x2196F3;
    constexpr uint32_t CYAN = 0x00BCD4;
    constexpr uint32_t GREEN = 0x4CAF50;
    constexpr uint32_t YELLOW = 0xFFEB3B;
    constexpr uint32_t ORANGE = 0xFF9800;
    constexpr uint32_t WHITE = 0xFFFFFF;
    constexpr uint32_t BLACK = 0x000000;
}

// ARGB format (0xAARRGGBB)
namespace ArgbColors {
    constexpr uint32_t SOLID_RED = 0xFFFF0000;
    constexpr uint32_t SOLID_GREEN = 0xFF00FF00;
    constexpr uint32_t SOLID_BLUE = 0xFF0000FF;
    constexpr uint32_t SEMI_BLACK = 0x80000000;
    constexpr uint32_t TRANSPARENT = 0x00000000;
}

// Struct initializer style
struct Color {
    uint8_t r, g, b, a;
};

namespace StructColors {
    constexpr Color Red = {255, 0, 0, 255};
    constexpr Color Green = {0, 255, 0, 255};
    constexpr Color Blue = {0, 0, 255, 255};
    constexpr Color Yellow = {255, 255, 0, 255};
    constexpr Color Cyan = {0, 255, 255, 255};
    constexpr Color Magenta = {255, 0, 255, 255};
    constexpr Color White = {255, 255, 255, 255};
    constexpr Color Black = {0, 0, 0, 255};
    constexpr Color SemiTransparent = {0, 0, 0, 128};
}

// Float struct style (0.0-1.0)
struct ColorF {
    float r, g, b, a;
};

namespace FloatStructColors {
    constexpr ColorF Primary = {0.384f, 0.000f, 0.933f, 1.00f};
    constexpr ColorF Secondary = {0.012f, 0.855f, 0.776f, 1.00f};
    constexpr ColorF Background = {0.071f, 0.071f, 0.071f, 1.00f};
    constexpr ColorF Overlay = {0.000f, 0.000f, 0.000f, 0.50f};
}

// Dark theme
namespace DarkTheme {
    const QColor Background = QColor(26, 26, 46);
    const QColor Surface = QColor(22, 33, 62);
    const QColor Primary = QColor(15, 52, 96);
    const QColor Accent = QColor(233, 69, 96);
    const QColor Text = QColor(234, 234, 234);
    const QColor TextMuted = QColor(170, 175, 191, 170);
}

// Game colors
namespace GamePalette {
    constexpr Color Player = {79, 195, 247, 255};
    constexpr Color Enemy = {239, 83, 80, 255};
    constexpr Color Collectible = {255, 213, 79, 255};
    constexpr Color Obstacle = {120, 144, 156, 255};
    constexpr Color Health = {102, 187, 106, 255};
    constexpr Color Mana = {171, 71, 188, 255};
}
