---@module 'nvim-colorpicker.filetypes.adapters.rust'
---@brief Rust adapter for Bevy, macroquad, and general Rust

local base = require('nvim-colorpicker.filetypes.base')
local patterns = require('nvim-colorpicker.filetypes.patterns')

---@class RustAdapter : BaseAdapter
local RustAdapter = base.BaseAdapter.new({
  filetypes = { "rust" },
  default_format = "hex",
  value_range = "0-1",
  patterns = patterns.combine(
    -- Bevy color patterns
    {
      -- Color::srgba(r, g, b, a)
      { pattern = "Color::srgba%s*%(%s*[%d%.]+%s*,%s*[%d%.]+%s*,%s*[%d%.]+%s*,%s*[%d%.]+%s*%)", format = "bevy_srgba", priority = 100 },
      -- Color::srgb(r, g, b)
      { pattern = "Color::srgb%s*%(%s*[%d%.]+%s*,%s*[%d%.]+%s*,%s*[%d%.]+%s*%)", format = "bevy_srgb", priority = 95 },
      -- Color::hex("#RRGGBB") or Color::hex("RRGGBB")
      { pattern = 'Color::hex%s*%(%s*"#?%x%x%x%x%x%x%x?%x?"%s*%)', format = "bevy_hex", priority = 100 },
      -- Color::rgba(r, g, b, a) - older Bevy
      { pattern = "Color::rgba%s*%(%s*[%d%.]+%s*,%s*[%d%.]+%s*,%s*[%d%.]+%s*,%s*[%d%.]+%s*%)", format = "bevy_rgba", priority = 90 },
      -- Color::rgb(r, g, b) - older Bevy
      { pattern = "Color::rgb%s*%(%s*[%d%.]+%s*,%s*[%d%.]+%s*,%s*[%d%.]+%s*%)", format = "bevy_rgb", priority = 85 },
      -- macroquad: Color::new(r, g, b, a)
      { pattern = "Color::new%s*%(%s*[%d%.]+%s*,%s*[%d%.]+%s*,%s*[%d%.]+%s*,%s*[%d%.]+%s*%)", format = "macroquad_new", priority = 90 },
      -- macroquad: color_u8!(r, g, b, a)
      { pattern = "color_u8!%s*%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*,%s*%d+%s*%)", format = "macroquad_u8", priority = 90 },
    },
    -- Standard hex patterns
    patterns.universal
  ),
})

---Format a hex color to Rust format
---@param hex string The hex color
---@param format string Target format
---@param alpha number? Alpha value 0-100
---@return string formatted The formatted color string
function RustAdapter:format_color(hex, format, alpha)
  local r, g, b = self:hex_to_rgb(hex)
  local rf, gf, bf = self:rgb_to_float(r, g, b)
  local af = alpha and self:alpha_to_decimal(alpha) or 1.0
  local a = alpha and self:alpha_to_byte(alpha) or 255

  if format == "bevy_srgb" then
    if alpha and alpha < 100 then
      return string.format("Color::srgba(%.3f, %.3f, %.3f, %.3f)", rf, gf, bf, af)
    end
    return string.format("Color::srgb(%.3f, %.3f, %.3f)", rf, gf, bf)
  elseif format == "bevy_srgba" then
    return string.format("Color::srgba(%.3f, %.3f, %.3f, %.3f)", rf, gf, bf, af)
  elseif format == "bevy_rgb" then
    if alpha and alpha < 100 then
      return string.format("Color::rgba(%.3f, %.3f, %.3f, %.3f)", rf, gf, bf, af)
    end
    return string.format("Color::rgb(%.3f, %.3f, %.3f)", rf, gf, bf)
  elseif format == "bevy_rgba" then
    return string.format("Color::rgba(%.3f, %.3f, %.3f, %.3f)", rf, gf, bf, af)
  elseif format == "bevy_hex" then
    if alpha and alpha < 100 then
      return string.format('Color::hex("#%s%02X").unwrap()', hex:sub(2):upper(), a)
    end
    return string.format('Color::hex("#%s").unwrap()', hex:sub(2):upper())
  elseif format == "macroquad_new" then
    return string.format("Color::new(%.3f, %.3f, %.3f, %.3f)", rf, gf, bf, af)
  elseif format == "macroquad_u8" then
    return string.format("color_u8!(%d, %d, %d, %d)", r, g, b, a)
  elseif format == "hex" or format == "hex8" then
    if alpha and alpha < 100 then
      return hex .. string.format("%02X", a)
    end
    return hex
  end

  return hex
end

---Parse a Rust color string to hex
---@param match string The matched string
---@param format string The format type
---@return string? hex Hex color
---@return number? alpha Alpha value 0-100
function RustAdapter:parse_color(match, format)
  if format == "bevy_srgb" or format == "bevy_rgb" then
    local rf, gf, bf = match:match("Color::%w+%s*%(%s*([%d%.]+)%s*,%s*([%d%.]+)%s*,%s*([%d%.]+)%s*%)")
    if rf and gf and bf then
      local r, g, b = self:float_to_rgb(tonumber(rf), tonumber(gf), tonumber(bf))
      return self:rgb_to_hex(r, g, b), nil
    end
  elseif format == "bevy_srgba" or format == "bevy_rgba" then
    local rf, gf, bf, af = match:match("Color::%w+%s*%(%s*([%d%.]+)%s*,%s*([%d%.]+)%s*,%s*([%d%.]+)%s*,%s*([%d%.]+)%s*%)")
    if rf and gf and bf and af then
      local r, g, b = self:float_to_rgb(tonumber(rf), tonumber(gf), tonumber(bf))
      local alpha = self:decimal_to_alpha(tonumber(af))
      return self:rgb_to_hex(r, g, b), alpha
    end
  elseif format == "bevy_hex" then
    local hex_str = match:match('Color::hex%s*%(%s*"#?(%x+)"')
    if hex_str then
      if #hex_str == 8 then
        -- RRGGBBAA
        local alpha_int = tonumber(hex_str:sub(7, 8), 16)
        local alpha = self:byte_to_alpha(alpha_int)
        return "#" .. hex_str:sub(1, 6):upper(), alpha
      elseif #hex_str == 6 then
        return "#" .. hex_str:upper(), nil
      end
    end
  elseif format == "macroquad_new" then
    local rf, gf, bf, af = match:match("Color::new%s*%(%s*([%d%.]+)%s*,%s*([%d%.]+)%s*,%s*([%d%.]+)%s*,%s*([%d%.]+)%s*%)")
    if rf and gf and bf and af then
      local r, g, b = self:float_to_rgb(tonumber(rf), tonumber(gf), tonumber(bf))
      local alpha = self:decimal_to_alpha(tonumber(af))
      return self:rgb_to_hex(r, g, b), alpha
    end
  elseif format == "macroquad_u8" then
    local r, g, b, a = match:match("color_u8!%s*%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%)")
    if r and g and b and a then
      local alpha = self:byte_to_alpha(tonumber(a))
      return self:rgb_to_hex(tonumber(r), tonumber(g), tonumber(b)), alpha
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

return RustAdapter
