---@module 'nvim-colorpicker.presets'
---@brief Color preset palettes for nvim-colorpicker

local M = {}

-- ============================================================================
-- Web/CSS Named Colors
-- ============================================================================

M.web = {
  name = "Web Colors",
  colors = {
    -- Reds
    { name = "indianred", hex = "#CD5C5C" },
    { name = "lightcoral", hex = "#F08080" },
    { name = "salmon", hex = "#FA8072" },
    { name = "darksalmon", hex = "#E9967A" },
    { name = "crimson", hex = "#DC143C" },
    { name = "red", hex = "#FF0000" },
    { name = "firebrick", hex = "#B22222" },
    { name = "darkred", hex = "#8B0000" },

    -- Pinks
    { name = "pink", hex = "#FFC0CB" },
    { name = "lightpink", hex = "#FFB6C1" },
    { name = "hotpink", hex = "#FF69B4" },
    { name = "deeppink", hex = "#FF1493" },
    { name = "mediumvioletred", hex = "#C71585" },
    { name = "palevioletred", hex = "#DB7093" },

    -- Oranges
    { name = "coral", hex = "#FF7F50" },
    { name = "tomato", hex = "#FF6347" },
    { name = "orangered", hex = "#FF4500" },
    { name = "darkorange", hex = "#FF8C00" },
    { name = "orange", hex = "#FFA500" },

    -- Yellows
    { name = "gold", hex = "#FFD700" },
    { name = "yellow", hex = "#FFFF00" },
    { name = "lightyellow", hex = "#FFFFE0" },
    { name = "lemonchiffon", hex = "#FFFACD" },
    { name = "papayawhip", hex = "#FFEFD5" },
    { name = "moccasin", hex = "#FFE4B5" },
    { name = "peachpuff", hex = "#FFDAB9" },
    { name = "palegoldenrod", hex = "#EEE8AA" },
    { name = "khaki", hex = "#F0E68C" },
    { name = "darkkhaki", hex = "#BDB76B" },

    -- Purples
    { name = "lavender", hex = "#E6E6FA" },
    { name = "thistle", hex = "#D8BFD8" },
    { name = "plum", hex = "#DDA0DD" },
    { name = "violet", hex = "#EE82EE" },
    { name = "orchid", hex = "#DA70D6" },
    { name = "fuchsia", hex = "#FF00FF" },
    { name = "magenta", hex = "#FF00FF" },
    { name = "mediumorchid", hex = "#BA55D3" },
    { name = "mediumpurple", hex = "#9370DB" },
    { name = "rebeccapurple", hex = "#663399" },
    { name = "blueviolet", hex = "#8A2BE2" },
    { name = "darkviolet", hex = "#9400D3" },
    { name = "darkorchid", hex = "#9932CC" },
    { name = "darkmagenta", hex = "#8B008B" },
    { name = "purple", hex = "#800080" },
    { name = "indigo", hex = "#4B0082" },

    -- Greens
    { name = "greenyellow", hex = "#ADFF2F" },
    { name = "chartreuse", hex = "#7FFF00" },
    { name = "lawngreen", hex = "#7CFC00" },
    { name = "lime", hex = "#00FF00" },
    { name = "limegreen", hex = "#32CD32" },
    { name = "palegreen", hex = "#98FB98" },
    { name = "lightgreen", hex = "#90EE90" },
    { name = "mediumspringgreen", hex = "#00FA9A" },
    { name = "springgreen", hex = "#00FF7F" },
    { name = "mediumseagreen", hex = "#3CB371" },
    { name = "seagreen", hex = "#2E8B57" },
    { name = "forestgreen", hex = "#228B22" },
    { name = "green", hex = "#008000" },
    { name = "darkgreen", hex = "#006400" },
    { name = "yellowgreen", hex = "#9ACD32" },
    { name = "olivedrab", hex = "#6B8E23" },
    { name = "olive", hex = "#808000" },
    { name = "darkolivegreen", hex = "#556B2F" },
    { name = "mediumaquamarine", hex = "#66CDAA" },
    { name = "darkseagreen", hex = "#8FBC8B" },
    { name = "lightseagreen", hex = "#20B2AA" },
    { name = "darkcyan", hex = "#008B8B" },
    { name = "teal", hex = "#008080" },

    -- Blues
    { name = "aqua", hex = "#00FFFF" },
    { name = "cyan", hex = "#00FFFF" },
    { name = "lightcyan", hex = "#E0FFFF" },
    { name = "paleturquoise", hex = "#AFEEEE" },
    { name = "aquamarine", hex = "#7FFFD4" },
    { name = "turquoise", hex = "#40E0D0" },
    { name = "mediumturquoise", hex = "#48D1CC" },
    { name = "darkturquoise", hex = "#00CED1" },
    { name = "cadetblue", hex = "#5F9EA0" },
    { name = "steelblue", hex = "#4682B4" },
    { name = "lightsteelblue", hex = "#B0C4DE" },
    { name = "powderblue", hex = "#B0E0E6" },
    { name = "lightblue", hex = "#ADD8E6" },
    { name = "skyblue", hex = "#87CEEB" },
    { name = "lightskyblue", hex = "#87CEFA" },
    { name = "deepskyblue", hex = "#00BFFF" },
    { name = "dodgerblue", hex = "#1E90FF" },
    { name = "cornflowerblue", hex = "#6495ED" },
    { name = "royalblue", hex = "#4169E1" },
    { name = "blue", hex = "#0000FF" },
    { name = "mediumblue", hex = "#0000CD" },
    { name = "darkblue", hex = "#00008B" },
    { name = "navy", hex = "#000080" },
    { name = "midnightblue", hex = "#191970" },

    -- Browns
    { name = "cornsilk", hex = "#FFF8DC" },
    { name = "blanchedalmond", hex = "#FFEBCD" },
    { name = "bisque", hex = "#FFE4C4" },
    { name = "navajowhite", hex = "#FFDEAD" },
    { name = "wheat", hex = "#F5DEB3" },
    { name = "burlywood", hex = "#DEB887" },
    { name = "tan", hex = "#D2B48C" },
    { name = "rosybrown", hex = "#BC8F8F" },
    { name = "sandybrown", hex = "#F4A460" },
    { name = "goldenrod", hex = "#DAA520" },
    { name = "darkgoldenrod", hex = "#B8860B" },
    { name = "peru", hex = "#CD853F" },
    { name = "chocolate", hex = "#D2691E" },
    { name = "saddlebrown", hex = "#8B4513" },
    { name = "sienna", hex = "#A0522D" },
    { name = "brown", hex = "#A52A2A" },
    { name = "maroon", hex = "#800000" },

    -- Whites
    { name = "white", hex = "#FFFFFF" },
    { name = "snow", hex = "#FFFAFA" },
    { name = "honeydew", hex = "#F0FFF0" },
    { name = "mintcream", hex = "#F5FFFA" },
    { name = "azure", hex = "#F0FFFF" },
    { name = "aliceblue", hex = "#F0F8FF" },
    { name = "ghostwhite", hex = "#F8F8FF" },
    { name = "whitesmoke", hex = "#F5F5F5" },
    { name = "seashell", hex = "#FFF5EE" },
    { name = "beige", hex = "#F5F5DC" },
    { name = "oldlace", hex = "#FDF5E6" },
    { name = "floralwhite", hex = "#FFFAF0" },
    { name = "ivory", hex = "#FFFFF0" },
    { name = "antiquewhite", hex = "#FAEBD7" },
    { name = "linen", hex = "#FAF0E6" },
    { name = "lavenderblush", hex = "#FFF0F5" },
    { name = "mistyrose", hex = "#FFE4E1" },

    -- Grays
    { name = "gainsboro", hex = "#DCDCDC" },
    { name = "lightgray", hex = "#D3D3D3" },
    { name = "silver", hex = "#C0C0C0" },
    { name = "darkgray", hex = "#A9A9A9" },
    { name = "gray", hex = "#808080" },
    { name = "dimgray", hex = "#696969" },
    { name = "lightslategray", hex = "#778899" },
    { name = "slategray", hex = "#708090" },
    { name = "darkslategray", hex = "#2F4F4F" },
    { name = "black", hex = "#000000" },
  },
}

-- ============================================================================
-- Material Design Colors
-- ============================================================================

M.material = {
  name = "Material Design",
  colors = {
    -- Red
    { name = "red-50", hex = "#FFEBEE" },
    { name = "red-100", hex = "#FFCDD2" },
    { name = "red-200", hex = "#EF9A9A" },
    { name = "red-300", hex = "#E57373" },
    { name = "red-400", hex = "#EF5350" },
    { name = "red-500", hex = "#F44336" },
    { name = "red-600", hex = "#E53935" },
    { name = "red-700", hex = "#D32F2F" },
    { name = "red-800", hex = "#C62828" },
    { name = "red-900", hex = "#B71C1C" },

    -- Pink
    { name = "pink-50", hex = "#FCE4EC" },
    { name = "pink-100", hex = "#F8BBD0" },
    { name = "pink-200", hex = "#F48FB1" },
    { name = "pink-300", hex = "#F06292" },
    { name = "pink-400", hex = "#EC407A" },
    { name = "pink-500", hex = "#E91E63" },
    { name = "pink-600", hex = "#D81B60" },
    { name = "pink-700", hex = "#C2185B" },
    { name = "pink-800", hex = "#AD1457" },
    { name = "pink-900", hex = "#880E4F" },

    -- Purple
    { name = "purple-50", hex = "#F3E5F5" },
    { name = "purple-100", hex = "#E1BEE7" },
    { name = "purple-200", hex = "#CE93D8" },
    { name = "purple-300", hex = "#BA68C8" },
    { name = "purple-400", hex = "#AB47BC" },
    { name = "purple-500", hex = "#9C27B0" },
    { name = "purple-600", hex = "#8E24AA" },
    { name = "purple-700", hex = "#7B1FA2" },
    { name = "purple-800", hex = "#6A1B9A" },
    { name = "purple-900", hex = "#4A148C" },

    -- Deep Purple
    { name = "deep-purple-50", hex = "#EDE7F6" },
    { name = "deep-purple-100", hex = "#D1C4E9" },
    { name = "deep-purple-200", hex = "#B39DDB" },
    { name = "deep-purple-300", hex = "#9575CD" },
    { name = "deep-purple-400", hex = "#7E57C2" },
    { name = "deep-purple-500", hex = "#673AB7" },
    { name = "deep-purple-600", hex = "#5E35B1" },
    { name = "deep-purple-700", hex = "#512DA8" },
    { name = "deep-purple-800", hex = "#4527A0" },
    { name = "deep-purple-900", hex = "#311B92" },

    -- Indigo
    { name = "indigo-50", hex = "#E8EAF6" },
    { name = "indigo-100", hex = "#C5CAE9" },
    { name = "indigo-200", hex = "#9FA8DA" },
    { name = "indigo-300", hex = "#7986CB" },
    { name = "indigo-400", hex = "#5C6BC0" },
    { name = "indigo-500", hex = "#3F51B5" },
    { name = "indigo-600", hex = "#3949AB" },
    { name = "indigo-700", hex = "#303F9F" },
    { name = "indigo-800", hex = "#283593" },
    { name = "indigo-900", hex = "#1A237E" },

    -- Blue
    { name = "blue-50", hex = "#E3F2FD" },
    { name = "blue-100", hex = "#BBDEFB" },
    { name = "blue-200", hex = "#90CAF9" },
    { name = "blue-300", hex = "#64B5F6" },
    { name = "blue-400", hex = "#42A5F5" },
    { name = "blue-500", hex = "#2196F3" },
    { name = "blue-600", hex = "#1E88E5" },
    { name = "blue-700", hex = "#1976D2" },
    { name = "blue-800", hex = "#1565C0" },
    { name = "blue-900", hex = "#0D47A1" },

    -- Light Blue
    { name = "light-blue-50", hex = "#E1F5FE" },
    { name = "light-blue-100", hex = "#B3E5FC" },
    { name = "light-blue-200", hex = "#81D4FA" },
    { name = "light-blue-300", hex = "#4FC3F7" },
    { name = "light-blue-400", hex = "#29B6F6" },
    { name = "light-blue-500", hex = "#03A9F4" },
    { name = "light-blue-600", hex = "#039BE5" },
    { name = "light-blue-700", hex = "#0288D1" },
    { name = "light-blue-800", hex = "#0277BD" },
    { name = "light-blue-900", hex = "#01579B" },

    -- Cyan
    { name = "cyan-50", hex = "#E0F7FA" },
    { name = "cyan-100", hex = "#B2EBF2" },
    { name = "cyan-200", hex = "#80DEEA" },
    { name = "cyan-300", hex = "#4DD0E1" },
    { name = "cyan-400", hex = "#26C6DA" },
    { name = "cyan-500", hex = "#00BCD4" },
    { name = "cyan-600", hex = "#00ACC1" },
    { name = "cyan-700", hex = "#0097A7" },
    { name = "cyan-800", hex = "#00838F" },
    { name = "cyan-900", hex = "#006064" },

    -- Teal
    { name = "teal-50", hex = "#E0F2F1" },
    { name = "teal-100", hex = "#B2DFDB" },
    { name = "teal-200", hex = "#80CBC4" },
    { name = "teal-300", hex = "#4DB6AC" },
    { name = "teal-400", hex = "#26A69A" },
    { name = "teal-500", hex = "#009688" },
    { name = "teal-600", hex = "#00897B" },
    { name = "teal-700", hex = "#00796B" },
    { name = "teal-800", hex = "#00695C" },
    { name = "teal-900", hex = "#004D40" },

    -- Green
    { name = "green-50", hex = "#E8F5E9" },
    { name = "green-100", hex = "#C8E6C9" },
    { name = "green-200", hex = "#A5D6A7" },
    { name = "green-300", hex = "#81C784" },
    { name = "green-400", hex = "#66BB6A" },
    { name = "green-500", hex = "#4CAF50" },
    { name = "green-600", hex = "#43A047" },
    { name = "green-700", hex = "#388E3C" },
    { name = "green-800", hex = "#2E7D32" },
    { name = "green-900", hex = "#1B5E20" },

    -- Light Green
    { name = "light-green-50", hex = "#F1F8E9" },
    { name = "light-green-100", hex = "#DCEDC8" },
    { name = "light-green-200", hex = "#C5E1A5" },
    { name = "light-green-300", hex = "#AED581" },
    { name = "light-green-400", hex = "#9CCC65" },
    { name = "light-green-500", hex = "#8BC34A" },
    { name = "light-green-600", hex = "#7CB342" },
    { name = "light-green-700", hex = "#689F38" },
    { name = "light-green-800", hex = "#558B2F" },
    { name = "light-green-900", hex = "#33691E" },

    -- Lime
    { name = "lime-50", hex = "#F9FBE7" },
    { name = "lime-100", hex = "#F0F4C3" },
    { name = "lime-200", hex = "#E6EE9C" },
    { name = "lime-300", hex = "#DCE775" },
    { name = "lime-400", hex = "#D4E157" },
    { name = "lime-500", hex = "#CDDC39" },
    { name = "lime-600", hex = "#C0CA33" },
    { name = "lime-700", hex = "#AFB42B" },
    { name = "lime-800", hex = "#9E9D24" },
    { name = "lime-900", hex = "#827717" },

    -- Yellow
    { name = "yellow-50", hex = "#FFFDE7" },
    { name = "yellow-100", hex = "#FFF9C4" },
    { name = "yellow-200", hex = "#FFF59D" },
    { name = "yellow-300", hex = "#FFF176" },
    { name = "yellow-400", hex = "#FFEE58" },
    { name = "yellow-500", hex = "#FFEB3B" },
    { name = "yellow-600", hex = "#FDD835" },
    { name = "yellow-700", hex = "#FBC02D" },
    { name = "yellow-800", hex = "#F9A825" },
    { name = "yellow-900", hex = "#F57F17" },

    -- Amber
    { name = "amber-50", hex = "#FFF8E1" },
    { name = "amber-100", hex = "#FFECB3" },
    { name = "amber-200", hex = "#FFE082" },
    { name = "amber-300", hex = "#FFD54F" },
    { name = "amber-400", hex = "#FFCA28" },
    { name = "amber-500", hex = "#FFC107" },
    { name = "amber-600", hex = "#FFB300" },
    { name = "amber-700", hex = "#FFA000" },
    { name = "amber-800", hex = "#FF8F00" },
    { name = "amber-900", hex = "#FF6F00" },

    -- Orange
    { name = "orange-50", hex = "#FFF3E0" },
    { name = "orange-100", hex = "#FFE0B2" },
    { name = "orange-200", hex = "#FFCC80" },
    { name = "orange-300", hex = "#FFB74D" },
    { name = "orange-400", hex = "#FFA726" },
    { name = "orange-500", hex = "#FF9800" },
    { name = "orange-600", hex = "#FB8C00" },
    { name = "orange-700", hex = "#F57C00" },
    { name = "orange-800", hex = "#EF6C00" },
    { name = "orange-900", hex = "#E65100" },

    -- Deep Orange
    { name = "deep-orange-50", hex = "#FBE9E7" },
    { name = "deep-orange-100", hex = "#FFCCBC" },
    { name = "deep-orange-200", hex = "#FFAB91" },
    { name = "deep-orange-300", hex = "#FF8A65" },
    { name = "deep-orange-400", hex = "#FF7043" },
    { name = "deep-orange-500", hex = "#FF5722" },
    { name = "deep-orange-600", hex = "#F4511E" },
    { name = "deep-orange-700", hex = "#E64A19" },
    { name = "deep-orange-800", hex = "#D84315" },
    { name = "deep-orange-900", hex = "#BF360C" },

    -- Brown
    { name = "brown-50", hex = "#EFEBE9" },
    { name = "brown-100", hex = "#D7CCC8" },
    { name = "brown-200", hex = "#BCAAA4" },
    { name = "brown-300", hex = "#A1887F" },
    { name = "brown-400", hex = "#8D6E63" },
    { name = "brown-500", hex = "#795548" },
    { name = "brown-600", hex = "#6D4C41" },
    { name = "brown-700", hex = "#5D4037" },
    { name = "brown-800", hex = "#4E342E" },
    { name = "brown-900", hex = "#3E2723" },

    -- Grey
    { name = "grey-50", hex = "#FAFAFA" },
    { name = "grey-100", hex = "#F5F5F5" },
    { name = "grey-200", hex = "#EEEEEE" },
    { name = "grey-300", hex = "#E0E0E0" },
    { name = "grey-400", hex = "#BDBDBD" },
    { name = "grey-500", hex = "#9E9E9E" },
    { name = "grey-600", hex = "#757575" },
    { name = "grey-700", hex = "#616161" },
    { name = "grey-800", hex = "#424242" },
    { name = "grey-900", hex = "#212121" },

    -- Blue Grey
    { name = "blue-grey-50", hex = "#ECEFF1" },
    { name = "blue-grey-100", hex = "#CFD8DC" },
    { name = "blue-grey-200", hex = "#B0BEC5" },
    { name = "blue-grey-300", hex = "#90A4AE" },
    { name = "blue-grey-400", hex = "#78909C" },
    { name = "blue-grey-500", hex = "#607D8B" },
    { name = "blue-grey-600", hex = "#546E7A" },
    { name = "blue-grey-700", hex = "#455A64" },
    { name = "blue-grey-800", hex = "#37474F" },
    { name = "blue-grey-900", hex = "#263238" },
  },
}

-- ============================================================================
-- Tailwind CSS Colors
-- ============================================================================

M.tailwind = {
  name = "Tailwind CSS",
  colors = {
    -- Slate
    { name = "slate-50", hex = "#F8FAFC" },
    { name = "slate-100", hex = "#F1F5F9" },
    { name = "slate-200", hex = "#E2E8F0" },
    { name = "slate-300", hex = "#CBD5E1" },
    { name = "slate-400", hex = "#94A3B8" },
    { name = "slate-500", hex = "#64748B" },
    { name = "slate-600", hex = "#475569" },
    { name = "slate-700", hex = "#334155" },
    { name = "slate-800", hex = "#1E293B" },
    { name = "slate-900", hex = "#0F172A" },
    { name = "slate-950", hex = "#020617" },

    -- Gray
    { name = "gray-50", hex = "#F9FAFB" },
    { name = "gray-100", hex = "#F3F4F6" },
    { name = "gray-200", hex = "#E5E7EB" },
    { name = "gray-300", hex = "#D1D5DB" },
    { name = "gray-400", hex = "#9CA3AF" },
    { name = "gray-500", hex = "#6B7280" },
    { name = "gray-600", hex = "#4B5563" },
    { name = "gray-700", hex = "#374151" },
    { name = "gray-800", hex = "#1F2937" },
    { name = "gray-900", hex = "#111827" },
    { name = "gray-950", hex = "#030712" },

    -- Zinc
    { name = "zinc-50", hex = "#FAFAFA" },
    { name = "zinc-100", hex = "#F4F4F5" },
    { name = "zinc-200", hex = "#E4E4E7" },
    { name = "zinc-300", hex = "#D4D4D8" },
    { name = "zinc-400", hex = "#A1A1AA" },
    { name = "zinc-500", hex = "#71717A" },
    { name = "zinc-600", hex = "#52525B" },
    { name = "zinc-700", hex = "#3F3F46" },
    { name = "zinc-800", hex = "#27272A" },
    { name = "zinc-900", hex = "#18181B" },
    { name = "zinc-950", hex = "#09090B" },

    -- Neutral
    { name = "neutral-50", hex = "#FAFAFA" },
    { name = "neutral-100", hex = "#F5F5F5" },
    { name = "neutral-200", hex = "#E5E5E5" },
    { name = "neutral-300", hex = "#D4D4D4" },
    { name = "neutral-400", hex = "#A3A3A3" },
    { name = "neutral-500", hex = "#737373" },
    { name = "neutral-600", hex = "#525252" },
    { name = "neutral-700", hex = "#404040" },
    { name = "neutral-800", hex = "#262626" },
    { name = "neutral-900", hex = "#171717" },
    { name = "neutral-950", hex = "#0A0A0A" },

    -- Red
    { name = "red-50", hex = "#FEF2F2" },
    { name = "red-100", hex = "#FEE2E2" },
    { name = "red-200", hex = "#FECACA" },
    { name = "red-300", hex = "#FCA5A5" },
    { name = "red-400", hex = "#F87171" },
    { name = "red-500", hex = "#EF4444" },
    { name = "red-600", hex = "#DC2626" },
    { name = "red-700", hex = "#B91C1C" },
    { name = "red-800", hex = "#991B1B" },
    { name = "red-900", hex = "#7F1D1D" },
    { name = "red-950", hex = "#450A0A" },

    -- Orange
    { name = "orange-50", hex = "#FFF7ED" },
    { name = "orange-100", hex = "#FFEDD5" },
    { name = "orange-200", hex = "#FED7AA" },
    { name = "orange-300", hex = "#FDBA74" },
    { name = "orange-400", hex = "#FB923C" },
    { name = "orange-500", hex = "#F97316" },
    { name = "orange-600", hex = "#EA580C" },
    { name = "orange-700", hex = "#C2410C" },
    { name = "orange-800", hex = "#9A3412" },
    { name = "orange-900", hex = "#7C2D12" },
    { name = "orange-950", hex = "#431407" },

    -- Amber
    { name = "amber-50", hex = "#FFFBEB" },
    { name = "amber-100", hex = "#FEF3C7" },
    { name = "amber-200", hex = "#FDE68A" },
    { name = "amber-300", hex = "#FCD34D" },
    { name = "amber-400", hex = "#FBBF24" },
    { name = "amber-500", hex = "#F59E0B" },
    { name = "amber-600", hex = "#D97706" },
    { name = "amber-700", hex = "#B45309" },
    { name = "amber-800", hex = "#92400E" },
    { name = "amber-900", hex = "#78350F" },
    { name = "amber-950", hex = "#451A03" },

    -- Yellow
    { name = "yellow-50", hex = "#FEFCE8" },
    { name = "yellow-100", hex = "#FEF9C3" },
    { name = "yellow-200", hex = "#FEF08A" },
    { name = "yellow-300", hex = "#FDE047" },
    { name = "yellow-400", hex = "#FACC15" },
    { name = "yellow-500", hex = "#EAB308" },
    { name = "yellow-600", hex = "#CA8A04" },
    { name = "yellow-700", hex = "#A16207" },
    { name = "yellow-800", hex = "#854D0E" },
    { name = "yellow-900", hex = "#713F12" },
    { name = "yellow-950", hex = "#422006" },

    -- Lime
    { name = "lime-50", hex = "#F7FEE7" },
    { name = "lime-100", hex = "#ECFCCB" },
    { name = "lime-200", hex = "#D9F99D" },
    { name = "lime-300", hex = "#BEF264" },
    { name = "lime-400", hex = "#A3E635" },
    { name = "lime-500", hex = "#84CC16" },
    { name = "lime-600", hex = "#65A30D" },
    { name = "lime-700", hex = "#4D7C0F" },
    { name = "lime-800", hex = "#3F6212" },
    { name = "lime-900", hex = "#365314" },
    { name = "lime-950", hex = "#1A2E05" },

    -- Green
    { name = "green-50", hex = "#F0FDF4" },
    { name = "green-100", hex = "#DCFCE7" },
    { name = "green-200", hex = "#BBF7D0" },
    { name = "green-300", hex = "#86EFAC" },
    { name = "green-400", hex = "#4ADE80" },
    { name = "green-500", hex = "#22C55E" },
    { name = "green-600", hex = "#16A34A" },
    { name = "green-700", hex = "#15803D" },
    { name = "green-800", hex = "#166534" },
    { name = "green-900", hex = "#14532D" },
    { name = "green-950", hex = "#052E16" },

    -- Emerald
    { name = "emerald-50", hex = "#ECFDF5" },
    { name = "emerald-100", hex = "#D1FAE5" },
    { name = "emerald-200", hex = "#A7F3D0" },
    { name = "emerald-300", hex = "#6EE7B7" },
    { name = "emerald-400", hex = "#34D399" },
    { name = "emerald-500", hex = "#10B981" },
    { name = "emerald-600", hex = "#059669" },
    { name = "emerald-700", hex = "#047857" },
    { name = "emerald-800", hex = "#065F46" },
    { name = "emerald-900", hex = "#064E3B" },
    { name = "emerald-950", hex = "#022C22" },

    -- Teal
    { name = "teal-50", hex = "#F0FDFA" },
    { name = "teal-100", hex = "#CCFBF1" },
    { name = "teal-200", hex = "#99F6E4" },
    { name = "teal-300", hex = "#5EEAD4" },
    { name = "teal-400", hex = "#2DD4BF" },
    { name = "teal-500", hex = "#14B8A6" },
    { name = "teal-600", hex = "#0D9488" },
    { name = "teal-700", hex = "#0F766E" },
    { name = "teal-800", hex = "#115E59" },
    { name = "teal-900", hex = "#134E4A" },
    { name = "teal-950", hex = "#042F2E" },

    -- Cyan
    { name = "cyan-50", hex = "#ECFEFF" },
    { name = "cyan-100", hex = "#CFFAFE" },
    { name = "cyan-200", hex = "#A5F3FC" },
    { name = "cyan-300", hex = "#67E8F9" },
    { name = "cyan-400", hex = "#22D3EE" },
    { name = "cyan-500", hex = "#06B6D4" },
    { name = "cyan-600", hex = "#0891B2" },
    { name = "cyan-700", hex = "#0E7490" },
    { name = "cyan-800", hex = "#155E75" },
    { name = "cyan-900", hex = "#164E63" },
    { name = "cyan-950", hex = "#083344" },

    -- Sky
    { name = "sky-50", hex = "#F0F9FF" },
    { name = "sky-100", hex = "#E0F2FE" },
    { name = "sky-200", hex = "#BAE6FD" },
    { name = "sky-300", hex = "#7DD3FC" },
    { name = "sky-400", hex = "#38BDF8" },
    { name = "sky-500", hex = "#0EA5E9" },
    { name = "sky-600", hex = "#0284C7" },
    { name = "sky-700", hex = "#0369A1" },
    { name = "sky-800", hex = "#075985" },
    { name = "sky-900", hex = "#0C4A6E" },
    { name = "sky-950", hex = "#082F49" },

    -- Blue
    { name = "blue-50", hex = "#EFF6FF" },
    { name = "blue-100", hex = "#DBEAFE" },
    { name = "blue-200", hex = "#BFDBFE" },
    { name = "blue-300", hex = "#93C5FD" },
    { name = "blue-400", hex = "#60A5FA" },
    { name = "blue-500", hex = "#3B82F6" },
    { name = "blue-600", hex = "#2563EB" },
    { name = "blue-700", hex = "#1D4ED8" },
    { name = "blue-800", hex = "#1E40AF" },
    { name = "blue-900", hex = "#1E3A8A" },
    { name = "blue-950", hex = "#172554" },

    -- Indigo
    { name = "indigo-50", hex = "#EEF2FF" },
    { name = "indigo-100", hex = "#E0E7FF" },
    { name = "indigo-200", hex = "#C7D2FE" },
    { name = "indigo-300", hex = "#A5B4FC" },
    { name = "indigo-400", hex = "#818CF8" },
    { name = "indigo-500", hex = "#6366F1" },
    { name = "indigo-600", hex = "#4F46E5" },
    { name = "indigo-700", hex = "#4338CA" },
    { name = "indigo-800", hex = "#3730A3" },
    { name = "indigo-900", hex = "#312E81" },
    { name = "indigo-950", hex = "#1E1B4B" },

    -- Violet
    { name = "violet-50", hex = "#F5F3FF" },
    { name = "violet-100", hex = "#EDE9FE" },
    { name = "violet-200", hex = "#DDD6FE" },
    { name = "violet-300", hex = "#C4B5FD" },
    { name = "violet-400", hex = "#A78BFA" },
    { name = "violet-500", hex = "#8B5CF6" },
    { name = "violet-600", hex = "#7C3AED" },
    { name = "violet-700", hex = "#6D28D9" },
    { name = "violet-800", hex = "#5B21B6" },
    { name = "violet-900", hex = "#4C1D95" },
    { name = "violet-950", hex = "#2E1065" },

    -- Purple
    { name = "purple-50", hex = "#FAF5FF" },
    { name = "purple-100", hex = "#F3E8FF" },
    { name = "purple-200", hex = "#E9D5FF" },
    { name = "purple-300", hex = "#D8B4FE" },
    { name = "purple-400", hex = "#C084FC" },
    { name = "purple-500", hex = "#A855F7" },
    { name = "purple-600", hex = "#9333EA" },
    { name = "purple-700", hex = "#7E22CE" },
    { name = "purple-800", hex = "#6B21A8" },
    { name = "purple-900", hex = "#581C87" },
    { name = "purple-950", hex = "#3B0764" },

    -- Fuchsia
    { name = "fuchsia-50", hex = "#FDF4FF" },
    { name = "fuchsia-100", hex = "#FAE8FF" },
    { name = "fuchsia-200", hex = "#F5D0FE" },
    { name = "fuchsia-300", hex = "#F0ABFC" },
    { name = "fuchsia-400", hex = "#E879F9" },
    { name = "fuchsia-500", hex = "#D946EF" },
    { name = "fuchsia-600", hex = "#C026D3" },
    { name = "fuchsia-700", hex = "#A21CAF" },
    { name = "fuchsia-800", hex = "#86198F" },
    { name = "fuchsia-900", hex = "#701A75" },
    { name = "fuchsia-950", hex = "#4A044E" },

    -- Pink
    { name = "pink-50", hex = "#FDF2F8" },
    { name = "pink-100", hex = "#FCE7F3" },
    { name = "pink-200", hex = "#FBCFE8" },
    { name = "pink-300", hex = "#F9A8D4" },
    { name = "pink-400", hex = "#F472B6" },
    { name = "pink-500", hex = "#EC4899" },
    { name = "pink-600", hex = "#DB2777" },
    { name = "pink-700", hex = "#BE185D" },
    { name = "pink-800", hex = "#9D174D" },
    { name = "pink-900", hex = "#831843" },
    { name = "pink-950", hex = "#500724" },

    -- Rose
    { name = "rose-50", hex = "#FFF1F2" },
    { name = "rose-100", hex = "#FFE4E6" },
    { name = "rose-200", hex = "#FECDD3" },
    { name = "rose-300", hex = "#FDA4AF" },
    { name = "rose-400", hex = "#FB7185" },
    { name = "rose-500", hex = "#F43F5E" },
    { name = "rose-600", hex = "#E11D48" },
    { name = "rose-700", hex = "#BE123C" },
    { name = "rose-800", hex = "#9F1239" },
    { name = "rose-900", hex = "#881337" },
    { name = "rose-950", hex = "#4C0519" },
  },
}

-- ============================================================================
-- Utility Functions
-- ============================================================================

---Get all available preset names
---@return string[] names List of preset names
function M.get_preset_names()
  local names = {}
  for name, _ in pairs(M) do
    if type(M[name]) == "table" and M[name].colors then
      table.insert(names, name)
    end
  end
  table.sort(names)
  return names
end

---Get a preset by name
---@param name string Preset name (e.g., "web", "material", "tailwind")
---@return table? preset The preset table with name and colors
function M.get_preset(name)
  return M[name]
end

---Search for a color by name across all presets
---@param query string Search query (partial match)
---@return table[] matches Array of {preset, name, hex}
function M.search(query)
  local matches = {}
  query = query:lower()

  for preset_name, preset in pairs(M) do
    if type(preset) == "table" and preset.colors then
      for _, color in ipairs(preset.colors) do
        if color.name:lower():find(query, 1, true) then
          table.insert(matches, {
            preset = preset_name,
            name = color.name,
            hex = color.hex,
          })
        end
      end
    end
  end

  return matches
end

---Get color by exact name from a preset
---@param preset_name string Preset name
---@param color_name string Color name
---@return string? hex The hex color or nil
function M.get_color(preset_name, color_name)
  local preset = M[preset_name]
  if not preset or not preset.colors then return nil end

  for _, color in ipairs(preset.colors) do
    if color.name == color_name then
      return color.hex
    end
  end

  return nil
end

return M
