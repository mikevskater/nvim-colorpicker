// =============================================================================
// C#/Unity Color Formats Example
// nvim-colorpicker detects and can replace all these formats
// =============================================================================

using UnityEngine;
using System.Drawing; // For WPF/WinForms Color

namespace ColorExamples
{
    // Unity Color32 (bytes 0-255) - most common for game dev
    public static class GameColors
    {
        public static readonly Color32 Player = new Color32(79, 195, 247, 255);
        public static readonly Color32 Enemy = new Color32(239, 83, 80, 255);
        public static readonly Color32 Collectible = new Color32(255, 213, 79, 255);
        public static readonly Color32 Obstacle = new Color32(120, 144, 156, 255);
        public static readonly Color32 Health = new Color32(102, 187, 106, 255);
        public static readonly Color32 Mana = new Color32(171, 71, 188, 255);
        public static readonly Color32 UI_Text = new Color32(255, 255, 255, 255);
        public static readonly Color32 UI_Shadow = new Color32(0, 0, 0, 128);
    }

    // Unity Color (floats 0-1) with 'f' suffix
    public static class ThemeColors
    {
        public static readonly Color Primary = new Color(0.384f, 0.000f, 0.933f);
        public static readonly Color Secondary = new Color(0.012f, 0.855f, 0.776f);
        public static readonly Color Background = new Color(0.071f, 0.071f, 0.071f);
        public static readonly Color Surface = new Color(0.118f, 0.118f, 0.118f);
        public static readonly Color Error = new Color(0.812f, 0.400f, 0.475f);
        public static readonly Color Success = new Color(0.400f, 0.733f, 0.416f);
    }

    // Unity Color with alpha (floats)
    public static class TransparentColors
    {
        public static readonly Color Overlay = new Color(0.000f, 0.000f, 0.000f, 0.50f);
        public static readonly Color Highlight = new Color(0.384f, 0.000f, 0.933f, 0.25f);
        public static readonly Color GlassEffect = new Color(1.000f, 1.000f, 1.000f, 0.10f);
        public static readonly Color FadeOut = new Color(0.071f, 0.071f, 0.071f, 0.00f);
    }

    // WPF/WinForms Color.FromArgb (a, r, g, b)
    public static class WpfColors
    {
        public static readonly System.Drawing.Color Primary = System.Drawing.Color.FromArgb(255, 98, 0, 238);
        public static readonly System.Drawing.Color Secondary = System.Drawing.Color.FromArgb(255, 3, 218, 198);
        public static readonly System.Drawing.Color Background = System.Drawing.Color.FromArgb(255, 18, 18, 18);
        public static readonly System.Drawing.Color SemiTransparent = System.Drawing.Color.FromArgb(128, 0, 0, 0);
    }

    // WPF Color.FromRgb (r, g, b)
    public static class SimpleColors
    {
        public static readonly System.Drawing.Color Red = System.Drawing.Color.FromRgb(244, 67, 54);
        public static readonly System.Drawing.Color Green = System.Drawing.Color.FromRgb(76, 175, 80);
        public static readonly System.Drawing.Color Blue = System.Drawing.Color.FromRgb(33, 150, 243);
        public static readonly System.Drawing.Color Yellow = System.Drawing.Color.FromRgb(255, 235, 59);
    }

    // Dark theme for UI
    public static class DarkTheme
    {
        public static readonly Color32 Background = new Color32(26, 26, 46, 255);
        public static readonly Color32 Surface = new Color32(22, 33, 62, 255);
        public static readonly Color32 Primary = new Color32(15, 52, 96, 255);
        public static readonly Color32 Accent = new Color32(233, 69, 96, 255);
        public static readonly Color32 Text = new Color32(234, 234, 234, 255);
        public static readonly Color32 TextMuted = new Color32(170, 175, 191, 170);
    }

    // Particle system colors
    public class ParticleColors
    {
        public Color FireStart = new Color(1.000f, 0.400f, 0.000f, 1.00f);
        public Color FireEnd = new Color(1.000f, 0.000f, 0.000f, 0.00f);
        public Color SmokeStart = new Color(0.300f, 0.300f, 0.300f, 0.80f);
        public Color SmokeEnd = new Color(0.100f, 0.100f, 0.100f, 0.00f);
        public Color MagicStart = new Color(0.733f, 0.533f, 0.969f, 1.00f);
        public Color MagicEnd = new Color(0.400f, 0.200f, 0.800f, 0.00f);
    }
}
