---@module 'nvim-colorpicker.filetypes.adapters.cpp'
---@brief C/C++ adapter for Qt, OpenGL, and general C++

local base = require('nvim-colorpicker.filetypes.base')
local patterns = require('nvim-colorpicker.filetypes.patterns')

---@class CppAdapter : BaseAdapter
local CppAdapter = base.BaseAdapter.new({
  filetypes = { "cpp", "c", "h", "hpp", "cc", "cxx", "hxx" },
  default_format = "hex",
  value_range = "0-255",
  patterns = patterns.combine(
    -- Qt QColor patterns
    {
      -- QColor("#RRGGBB") or QColor("#AARRGGBB")
      { pattern = 'QColor%s*%(%s*"#%x%x%x%x%x%x%x?%x?"%s*%)', format = "qcolor_hex", priority = 100 },
      -- QColor(r, g, b, a)
      { pattern = "QColor%s*%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*,%s*%d+%s*%)", format = "qcolor_rgba", priority = 95 },
      -- QColor(r, g, b)
      { pattern = "QColor%s*%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*%)", format = "qcolor_rgb", priority = 90 },
      -- QColor::fromRgbF(r, g, b, a) - float values 0.0-1.0
      { pattern = "QColor::fromRgbF%s*%(%s*[%d%.]+%s*,%s*[%d%.]+%s*,%s*[%d%.]+%s*,%s*[%d%.]+%s*%)", format = "qcolor_fromrgbf_a", priority = 95 },
      -- QColor::fromRgbF(r, g, b) - float values 0.0-1.0
      { pattern = "QColor::fromRgbF%s*%(%s*[%d%.]+%s*,%s*[%d%.]+%s*,%s*[%d%.]+%s*%)", format = "qcolor_fromrgbf", priority = 90 },
      -- Float struct initializer {r, g, b, a} with optional 'f' suffix (0.0-1.0 range)
      { pattern = "%{%s*[%d%.]+f?%s*,%s*[%d%.]+f?%s*,%s*[%d%.]+f?%s*,%s*[%d%.]+f?%s*%}", format = "struct_float_rgba", priority = 88 },
      -- Float struct initializer {r, g, b} with optional 'f' suffix
      { pattern = "%{%s*[%d%.]+f?%s*,%s*[%d%.]+f?%s*,%s*[%d%.]+f?%s*%}", format = "struct_float_rgb", priority = 83 },
      -- Integer struct initializer {r, g, b, a}
      { pattern = "%{%s*%d+%s*,%s*%d+%s*,%s*%d+%s*,%s*%d+%s*%}", format = "struct_rgba", priority = 85 },
      -- Integer struct initializer {r, g, b}
      { pattern = "%{%s*%d+%s*,%s*%d+%s*,%s*%d+%s*%}", format = "struct_rgb", priority = 80 },
    },
    -- Numeric hex
    patterns.numeric_hex,
    -- Standard hex patterns
    patterns.universal
  ),
})

---Format a hex color to C++ format
---@param hex string The hex color
---@param format string Target format
---@param alpha number? Alpha value 0-100
---@return string formatted The formatted color string
function CppAdapter:format_color(hex, format, alpha)
  local r, g, b = self:hex_to_rgb(hex)
  local a = alpha and self:alpha_to_byte(alpha) or 255

  if format == "qcolor_hex" then
    if alpha and alpha < 100 then
      -- Qt uses ARGB order: #AARRGGBB
      return string.format('QColor("#%02X%s")', a, hex:sub(2):upper())
    end
    return string.format('QColor("#%s")', hex:sub(2):upper())
  elseif format == "qcolor_rgb" then
    if alpha and alpha < 100 then
      return string.format("QColor(%d, %d, %d, %d)", r, g, b, a)
    end
    return string.format("QColor(%d, %d, %d)", r, g, b)
  elseif format == "qcolor_rgba" then
    return string.format("QColor(%d, %d, %d, %d)", r, g, b, a)
  elseif format == "qcolor_fromrgbf" then
    local rf, gf, bf = self:rgb_to_float(r, g, b)
    if alpha and alpha < 100 then
      return string.format("QColor::fromRgbF(%.3f, %.3f, %.3f, %.3f)", rf, gf, bf, self:alpha_to_decimal(alpha))
    end
    return string.format("QColor::fromRgbF(%.3f, %.3f, %.3f)", rf, gf, bf)
  elseif format == "qcolor_fromrgbf_a" then
    local rf, gf, bf = self:rgb_to_float(r, g, b)
    local af = alpha and self:alpha_to_decimal(alpha) or 1.0
    return string.format("QColor::fromRgbF(%.3f, %.3f, %.3f, %.3f)", rf, gf, bf, af)
  elseif format == "struct_rgb" then
    if alpha and alpha < 100 then
      return string.format("{%d, %d, %d, %d}", r, g, b, a)
    end
    return string.format("{%d, %d, %d}", r, g, b)
  elseif format == "struct_rgba" then
    return string.format("{%d, %d, %d, %d}", r, g, b, a)
  elseif format == "struct_float_rgb" then
    local rf, gf, bf = self:rgb_to_float(r, g, b)
    if alpha and alpha < 100 then
      return string.format("{%.3ff, %.3ff, %.3ff, %.2ff}", rf, gf, bf, self:alpha_to_decimal(alpha))
    end
    return string.format("{%.3ff, %.3ff, %.3ff}", rf, gf, bf)
  elseif format == "struct_float_rgba" then
    local rf, gf, bf = self:rgb_to_float(r, g, b)
    local af = alpha and self:alpha_to_decimal(alpha) or 1.0
    return string.format("{%.3ff, %.3ff, %.3ff, %.2ff}", rf, gf, bf, af)
  elseif format == "hex_numeric" then
    return string.format("0x%s", hex:sub(2):upper())
  elseif format == "hex_numeric_argb" then
    return string.format("0x%02X%s", a, hex:sub(2):upper())
  elseif format == "hex" or format == "hex8" then
    if alpha and alpha < 100 then
      return hex .. string.format("%02X", a)
    end
    return hex
  end

  return hex
end

---Parse a C++ color string to hex
---@param match string The matched string
---@param format string The format type
---@return string? hex Hex color
---@return number? alpha Alpha value 0-100
function CppAdapter:parse_color(match, format)
  if format == "qcolor_hex" then
    local hex_str = match:match('QColor%s*%(%s*"#(%x+)"%s*%)')
    if hex_str then
      if #hex_str == 8 then
        -- #AARRGGBB (Qt uses ARGB order)
        local a = tonumber(hex_str:sub(1, 2), 16)
        local alpha = self:byte_to_alpha(a)
        return "#" .. hex_str:sub(3, 8):upper(), alpha
      elseif #hex_str == 6 then
        return "#" .. hex_str:upper(), nil
      end
    end
  elseif format == "qcolor_rgb" then
    local r, g, b = match:match("QColor%s*%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%)")
    if r and g and b then
      return self:rgb_to_hex(tonumber(r), tonumber(g), tonumber(b)), nil
    end
  elseif format == "qcolor_rgba" then
    local r, g, b, a = match:match("QColor%s*%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%)")
    if r and g and b and a then
      local alpha = self:byte_to_alpha(tonumber(a))
      return self:rgb_to_hex(tonumber(r), tonumber(g), tonumber(b)), alpha
    end
  elseif format == "qcolor_fromrgbf" then
    local rf, gf, bf = match:match("QColor::fromRgbF%s*%(%s*([%d%.]+)%s*,%s*([%d%.]+)%s*,%s*([%d%.]+)%s*%)")
    if rf and gf and bf then
      local r, g, b = self:float_to_rgb(tonumber(rf), tonumber(gf), tonumber(bf))
      return self:rgb_to_hex(r, g, b), nil
    end
  elseif format == "qcolor_fromrgbf_a" then
    local rf, gf, bf, af = match:match("QColor::fromRgbF%s*%(%s*([%d%.]+)%s*,%s*([%d%.]+)%s*,%s*([%d%.]+)%s*,%s*([%d%.]+)%s*%)")
    if rf and gf and bf and af then
      local r, g, b = self:float_to_rgb(tonumber(rf), tonumber(gf), tonumber(bf))
      local alpha = self:decimal_to_alpha(tonumber(af))
      return self:rgb_to_hex(r, g, b), alpha
    end
  elseif format == "struct_rgb" then
    local r, g, b = match:match("%{%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%}")
    if r and g and b then
      return self:rgb_to_hex(tonumber(r), tonumber(g), tonumber(b)), nil
    end
  elseif format == "struct_rgba" then
    local r, g, b, a = match:match("%{%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%}")
    if r and g and b and a then
      local alpha = self:byte_to_alpha(tonumber(a))
      return self:rgb_to_hex(tonumber(r), tonumber(g), tonumber(b)), alpha
    end
  elseif format == "struct_float_rgb" then
    -- Match {0.384f, 0.000f, 0.933f} - strip 'f' suffix
    local rf, gf, bf = match:match("%{%s*([%d%.]+)f?%s*,%s*([%d%.]+)f?%s*,%s*([%d%.]+)f?%s*%}")
    if rf and gf and bf then
      local r, g, b = self:float_to_rgb(tonumber(rf), tonumber(gf), tonumber(bf))
      return self:rgb_to_hex(r, g, b), nil
    end
  elseif format == "struct_float_rgba" then
    -- Match {0.384f, 0.000f, 0.933f, 1.00f} - strip 'f' suffix
    local rf, gf, bf, af = match:match("%{%s*([%d%.]+)f?%s*,%s*([%d%.]+)f?%s*,%s*([%d%.]+)f?%s*,%s*([%d%.]+)f?%s*%}")
    if rf and gf and bf and af then
      local r, g, b = self:float_to_rgb(tonumber(rf), tonumber(gf), tonumber(bf))
      local alpha = self:decimal_to_alpha(tonumber(af))
      return self:rgb_to_hex(r, g, b), alpha
    end
  elseif format == "hex_numeric" then
    local hex_str = match:match("0x(%x%x%x%x%x%x)")
    if hex_str then
      return "#" .. hex_str:upper(), nil
    end
  elseif format == "hex_numeric_argb" then
    local hex_str = match:match("0x(%x%x%x%x%x%x%x%x)")
    if hex_str then
      local a = tonumber(hex_str:sub(1, 2), 16)
      local alpha = self:byte_to_alpha(a)
      return "#" .. hex_str:sub(3, 8):upper(), alpha
    end
  elseif format == "hex" then
    return self:normalize_hex(match), nil
  elseif format == "hex3" then
    local short = match:gsub("^#", "")
    if #short == 3 then
      local expanded = short:sub(1, 1):rep(2) .. short:sub(2, 2):rep(2) .. short:sub(3, 3):rep(2)
      return "#" .. expanded:upper(), nil
    end
  elseif format == "hex8" then
    local alpha_hex = match:sub(8, 9)
    local alpha_int = tonumber(alpha_hex, 16)
    local alpha = alpha_int and self:byte_to_alpha(alpha_int) or nil
    return "#" .. match:sub(2, 7):upper(), alpha
  end

  -- Fallback
  local color_format = require('nvim-colorpicker.color.format')
  return color_format.parse_color_string(match)
end

return CppAdapter
