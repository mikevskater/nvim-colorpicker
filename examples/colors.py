# =============================================================================
# Python Color Formats Example
# nvim-colorpicker detects and can replace all these formats
# =============================================================================

# Hex strings (common in many Python libraries)
PRIMARY_COLOR = "#FF5500"
SECONDARY_COLOR = "#3498db"
BACKGROUND = "#1a1a2e"

# RGB tuples (Pygame, PIL, Tkinter)
RED = (255, 0, 0)
GREEN = (0, 255, 0)
BLUE = (0, 0, 255)
ORANGE = (255, 85, 0)
PURPLE = (128, 0, 128)

# RGBA tuples (with alpha)
SEMI_TRANSPARENT = (255, 85, 0, 128)
OVERLAY = (0, 0, 0, 200)
GLASS = (255, 255, 255, 50)

# Pygame example
class GameColors:
    """Color palette for a Pygame game"""
    PLAYER = (52, 152, 219)
    ENEMY = (231, 76, 60)
    BACKGROUND = (26, 26, 46)
    UI_TEXT = (255, 255, 255)
    UI_SHADOW = (0, 0, 0, 128)
    HEALTH_BAR = (46, 204, 113)
    MANA_BAR = (155, 89, 182)

# Pillow/PIL example
def create_gradient():
    from PIL import Image
    colors = [
        (102, 126, 234),  # Start color
        (118, 75, 162),   # End color
    ]
    return colors

# Tkinter example
TKINTER_THEME = {
    "bg": "#2c3e50",
    "fg": "#ecf0f1",
    "accent": "#3498db",
    "button_bg": "#34495e",
    "button_active": "#1abc9c",
    "error": "#e74c3c",
    "success": "#27ae60",
}

# Matplotlib colors
PLOT_COLORS = [
    "#1f77b4",  # Blue
    "#ff7f0e",  # Orange
    "#2ca02c",  # Green
    "#d62728",  # Red
    "#9467bd",  # Purple
    "#8c564b",  # Brown
    "#e377c2",  # Pink
    "#7f7f7f",  # Gray
]

# Color constants for a dark theme
class DarkTheme:
    BG_PRIMARY = (30, 30, 46)
    BG_SECONDARY = (45, 45, 68)
    TEXT = (205, 214, 244)
    TEXT_MUTED = (147, 153, 178)
    ACCENT = (137, 180, 250)
    SUCCESS = (166, 227, 161)
    WARNING = (249, 226, 175)
    ERROR = (243, 139, 168)
