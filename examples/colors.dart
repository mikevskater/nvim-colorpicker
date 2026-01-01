// =============================================================================
// Dart/Flutter Color Formats Example
// nvim-colorpicker detects and can replace all these formats
// =============================================================================

import 'package:flutter/material.dart';

// Flutter Color constructor (0xAARRGGBB format - most common)
class AppColors {
  static const Color primary = Color(0xFF6200EE);
  static const Color primaryVariant = Color(0xFF3700B3);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryVariant = Color(0xFF018786);
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color error = Color(0xFFCF6679);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFF000000);
  static const Color onBackground = Color(0xFFE1E1E1);
  static const Color onSurface = Color(0xFFE1E1E1);
  static const Color onError = Color(0xFF000000);
}

// With transparency
class OverlayColors {
  static const Color scrim = Color(0x80000000);
  static const Color modalBg = Color(0xCC1E1E1E);
  static const Color tooltip = Color(0xE6333333);
  static const Color selection = Color(0x406200EE);
  static const Color disabled = Color(0x61000000);
}

// Color.fromARGB (a, r, g, b) - explicit components
class ExplicitColors {
  static const Color red = Color.fromARGB(255, 244, 67, 54);
  static const Color pink = Color.fromARGB(255, 233, 30, 99);
  static const Color purple = Color.fromARGB(255, 156, 39, 176);
  static const Color blue = Color.fromARGB(255, 33, 150, 243);
  static const Color cyan = Color.fromARGB(255, 0, 188, 212);
  static const Color green = Color.fromARGB(255, 76, 175, 80);
  static const Color yellow = Color.fromARGB(255, 255, 235, 59);
  static const Color orange = Color.fromARGB(255, 255, 152, 0);

  // Semi-transparent
  static const Color semiRed = Color.fromARGB(128, 244, 67, 54);
  static const Color semiBlue = Color.fromARGB(128, 33, 150, 243);
}

// Color.fromRGBO (r, g, b, opacity) - opacity as 0.0-1.0
class OpacityColors {
  static const Color overlay = Color.fromRGBO(0, 0, 0, 0.50);
  static const Color highlight = Color.fromRGBO(98, 0, 238, 0.25);
  static const Color backdrop = Color.fromRGBO(18, 18, 18, 0.90);
  static const Color subtle = Color.fromRGBO(255, 255, 255, 0.10);
  static const Color focus = Color.fromRGBO(3, 218, 198, 0.40);
}

// Dark theme
class DarkTheme {
  static const Color background = Color(0xFF1A1A2E);
  static const Color surface = Color(0xFF16213E);
  static const Color primary = Color(0xFF0F3460);
  static const Color accent = Color(0xFFE94560);
  static const Color text = Color(0xFFEAEAEA);
  static const Color textMuted = Color(0xAAAAAFBF);
}

// Gradient colors
final List<Color> sunsetGradient = [
  Color(0xFFFF5722),
  Color(0xFFFF9800),
  Color(0xFFFFEB3B),
];

final List<Color> oceanGradient = [
  Color(0xFF00BCD4),
  Color(0xFF2196F3),
  Color(0xFF3F51B5),
];

// Game colors
class GamePalette {
  static const player = Color(0xFF4FC3F7);
  static const enemy = Color(0xFFEF5350);
  static const collectible = Color(0xFFFFD54F);
  static const obstacle = Color(0xFF78909C);
  static const health = Color(0xFF66BB6A);
  static const mana = Color(0xFFAB47BC);
}
