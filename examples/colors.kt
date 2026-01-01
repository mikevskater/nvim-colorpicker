// =============================================================================
// Kotlin/Android Color Formats Example
// nvim-colorpicker detects and can replace all these formats
// =============================================================================

package com.example.colors

import androidx.compose.ui.graphics.Color

// Jetpack Compose colors (0xAARRGGBB format)
object AppColors {
    val Primary = Color(0xFF6200EE)
    val PrimaryVariant = Color(0xFF3700B3)
    val Secondary = Color(0xFF03DAC6)
    val SecondaryVariant = Color(0xFF018786)
    val Background = Color(0xFF121212)
    val Surface = Color(0xFF1E1E1E)
    val Error = Color(0xFFCF6679)
    val OnPrimary = Color(0xFFFFFFFF)
    val OnSecondary = Color(0xFF000000)
    val OnBackground = Color(0xFFE1E1E1)
    val OnSurface = Color(0xFFE1E1E1)
    val OnError = Color(0xFF000000)
}

// With transparency
object OverlayColors {
    val Scrim = Color(0x80000000)
    val ModalBackground = Color(0xCC1E1E1E)
    val TooltipBg = Color(0xE6333333)
    val SelectionHighlight = Color(0x406200EE)
}

// Color.parseColor style (Android View system)
object LegacyColors {
    val red = Color.parseColor("#FF5722")
    val pink = Color.parseColor("#E91E63")
    val purple = Color.parseColor("#9C27B0")
    val blue = Color.parseColor("#2196F3")
    val cyan = Color.parseColor("#00BCD4")
    val green = Color.parseColor("#4CAF50")
    val yellow = Color.parseColor("#FFEB3B")
    val orange = Color.parseColor("#FF9800")

    // With alpha
    val semiTransparent = Color.parseColor("#80FF5722")
}

// Numeric hex (standalone)
object RawColors {
    const val WHITE = 0xFFFFFFFF
    const val BLACK = 0xFF000000
    const val RED = 0xFFFF0000
    const val GREEN = 0xFF00FF00
    const val BLUE = 0xFF0000FF
    const val TRANSPARENT = 0x00000000
}

// Dark theme palette
object DarkTheme {
    val background = Color(0xFF1A1A2E)
    val surface = Color(0xFF16213E)
    val primary = Color(0xFF0F3460)
    val accent = Color(0xFFE94560)
    val text = Color(0xFFEAEAEA)
    val textMuted = Color(0xAAAAAFBF)
}

// Gradient colors for Compose
val gradientColors = listOf(
    Color(0xFF667EEA),
    Color(0xFF764BA2),
    Color(0xFFF093FB),
)
