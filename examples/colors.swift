// =============================================================================
// Swift/SwiftUI Color Formats Example
// nvim-colorpicker detects and can replace all these formats
// =============================================================================

import SwiftUI
import UIKit

// SwiftUI Colors (float values 0.0-1.0)
struct AppColors {
    static let primary = Color(red: 0.384, green: 0.000, blue: 0.933)
    static let secondary = Color(red: 0.012, green: 0.855, blue: 0.776)
    static let background = Color(red: 0.071, green: 0.071, blue: 0.071)
    static let surface = Color(red: 0.118, green: 0.118, blue: 0.118)
    static let error = Color(red: 0.812, green: 0.400, blue: 0.475)
    static let onPrimary = Color(red: 1.000, green: 1.000, blue: 1.000)
    static let onBackground = Color(red: 0.882, green: 0.882, blue: 0.882)
}

// With opacity modifier
struct TransparentColors {
    static let overlay = Color(red: 0.000, green: 0.000, blue: 0.000).opacity(0.50)
    static let highlight = Color(red: 0.384, green: 0.000, blue: 0.933).opacity(0.25)
    static let disabled = Color(red: 0.500, green: 0.500, blue: 0.500).opacity(0.40)
}

// UIKit UIColor (with alpha parameter)
class LegacyColors {
    static let primary = UIColor(red: 0.384, green: 0.000, blue: 0.933, alpha: 1.00)
    static let secondary = UIColor(red: 0.012, green: 0.855, blue: 0.776, alpha: 1.00)
    static let background = UIColor(red: 0.071, green: 0.071, blue: 0.071, alpha: 1.00)
    static let semiTransparent = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.50)
    static let subtle = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.10)
}

// Hex extension style (common pattern)
extension Color {
    static let brandPrimary = Color(hex: 0x6200EE)
    static let brandSecondary = Color(hex: 0x03DAC6)
    static let brandAccent = Color(hex: 0xBB86FC)
    static let destructive = Color(hex: 0xCF6679)
}

// UIColor hex extension
extension UIColor {
    static let themePrimary = UIColor(hex: 0x6200EE)
    static let themeSecondary = UIColor(hex: 0x03DAC6)
    static let themeBackground = UIColor(hex: 0x121212)
}

// Gradient colors
struct GradientPalette {
    static let sunset = [
        Color(red: 1.000, green: 0.341, blue: 0.133),
        Color(red: 1.000, green: 0.608, blue: 0.000),
        Color(red: 1.000, green: 0.839, blue: 0.224),
    ]

    static let ocean = [
        Color(red: 0.000, green: 0.749, blue: 1.000),
        Color(red: 0.000, green: 0.467, blue: 0.745),
        Color(red: 0.000, green: 0.275, blue: 0.549),
    ]
}

// Dark mode colors
struct DarkTheme {
    static let background = Color(red: 0.102, green: 0.102, blue: 0.180)
    static let surface = Color(red: 0.086, green: 0.129, blue: 0.243)
    static let accent = Color(red: 0.914, green: 0.271, blue: 0.376)
    static let text = Color(red: 0.918, green: 0.918, blue: 0.918)
}
