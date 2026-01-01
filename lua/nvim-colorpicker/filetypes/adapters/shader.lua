---@module 'nvim-colorpicker.filetypes.adapters.shader'
---@brief Shader adapter for GLSL, HLSL, Metal, and WGSL

local base = require('nvim-colorpicker.filetypes.base')

---@class ShaderAdapter : BaseAdapter
local ShaderAdapter = base.BaseAdapter.new({
  filetypes = { "glsl", "hlsl", "metal", "wgsl", "vert", "frag", "geom", "tesc", "tese", "comp", "shader" },
  default_format = "vec3",
  value_range = "0-1",
  patterns = {
    -- GLSL vec patterns
    { pattern = "vec4%s*%(%s*[%d%.]+%s*,%s*[%d%.]+%s*,%s*[%d%.]+%s*,%s*[%d%.]+%s*%)", format = "vec4", priority = 100 },
    { pattern = "vec3%s*%(%s*[%d%.]+%s*,%s*[%d%.]+%s*,%s*[%d%.]+%s*%)", format = "vec3", priority = 95 },
    -- HLSL/Metal float patterns
    { pattern = "float4%s*%(%s*[%d%.]+%s*,%s*[%d%.]+%s*,%s*[%d%.]+%s*,%s*[%d%.]+%s*%)", format = "float4", priority = 100 },
    { pattern = "float3%s*%(%s*[%d%.]+%s*,%s*[%d%.]+%s*,%s*[%d%.]+%s*%)", format = "float3", priority = 95 },
    -- WGSL vec patterns
    { pattern = "vec4f%s*%(%s*[%d%.]+%s*,%s*[%d%.]+%s*,%s*[%d%.]+%s*,%s*[%d%.]+%s*%)", format = "vec4f", priority = 100 },
    { pattern = "vec3f%s*%(%s*[%d%.]+%s*,%s*[%d%.]+%s*,%s*[%d%.]+%s*%)", format = "vec3f", priority = 95 },
    -- Hex fallback (in comments or defines)
    { pattern = "#%x%x%x%x%x%x%x%x", format = "hex8", priority = 80 },
    { pattern = "#%x%x%x%x%x%x", format = "hex", priority = 75 },
  },
})

---Format a hex color to shader format
---@param hex string The hex color
---@param format string Target format
---@param alpha number? Alpha value 0-100
---@return string formatted The formatted color string
function ShaderAdapter:format_color(hex, format, alpha)
  local r, g, b = self:hex_to_rgb(hex)
  local rf, gf, bf = self:rgb_to_float(r, g, b)
  local af = alpha and self:alpha_to_decimal(alpha) or 1.0

  if format == "vec3" then
    if alpha and alpha < 100 then
      return string.format("vec4(%.3f, %.3f, %.3f, %.3f)", rf, gf, bf, af)
    end
    return string.format("vec3(%.3f, %.3f, %.3f)", rf, gf, bf)
  elseif format == "vec4" then
    return string.format("vec4(%.3f, %.3f, %.3f, %.3f)", rf, gf, bf, af)
  elseif format == "float3" then
    if alpha and alpha < 100 then
      return string.format("float4(%.3f, %.3f, %.3f, %.3f)", rf, gf, bf, af)
    end
    return string.format("float3(%.3f, %.3f, %.3f)", rf, gf, bf)
  elseif format == "float4" then
    return string.format("float4(%.3f, %.3f, %.3f, %.3f)", rf, gf, bf, af)
  elseif format == "vec3f" then
    if alpha and alpha < 100 then
      return string.format("vec4f(%.3f, %.3f, %.3f, %.3f)", rf, gf, bf, af)
    end
    return string.format("vec3f(%.3f, %.3f, %.3f)", rf, gf, bf)
  elseif format == "vec4f" then
    return string.format("vec4f(%.3f, %.3f, %.3f, %.3f)", rf, gf, bf, af)
  elseif format == "hex" or format == "hex8" then
    if alpha and alpha < 100 then
      return hex .. string.format("%02X", self:alpha_to_byte(alpha))
    end
    return hex
  end

  return hex
end

---Parse a shader color string to hex
---@param match string The matched string
---@param format string The format type
---@return string? hex Hex color
---@return number? alpha Alpha value 0-100
function ShaderAdapter:parse_color(match, format)
  if format == "vec3" then
    local rf, gf, bf = match:match("vec3%s*%(%s*([%d%.]+)%s*,%s*([%d%.]+)%s*,%s*([%d%.]+)%s*%)")
    if rf and gf and bf then
      local r, g, b = self:float_to_rgb(tonumber(rf), tonumber(gf), tonumber(bf))
      return self:rgb_to_hex(r, g, b), nil
    end
  elseif format == "vec4" then
    local rf, gf, bf, af = match:match("vec4%s*%(%s*([%d%.]+)%s*,%s*([%d%.]+)%s*,%s*([%d%.]+)%s*,%s*([%d%.]+)%s*%)")
    if rf and gf and bf and af then
      local r, g, b = self:float_to_rgb(tonumber(rf), tonumber(gf), tonumber(bf))
      local alpha = self:decimal_to_alpha(tonumber(af))
      return self:rgb_to_hex(r, g, b), alpha
    end
  elseif format == "float3" then
    local rf, gf, bf = match:match("float3%s*%(%s*([%d%.]+)%s*,%s*([%d%.]+)%s*,%s*([%d%.]+)%s*%)")
    if rf and gf and bf then
      local r, g, b = self:float_to_rgb(tonumber(rf), tonumber(gf), tonumber(bf))
      return self:rgb_to_hex(r, g, b), nil
    end
  elseif format == "float4" then
    local rf, gf, bf, af = match:match("float4%s*%(%s*([%d%.]+)%s*,%s*([%d%.]+)%s*,%s*([%d%.]+)%s*,%s*([%d%.]+)%s*%)")
    if rf and gf and bf and af then
      local r, g, b = self:float_to_rgb(tonumber(rf), tonumber(gf), tonumber(bf))
      local alpha = self:decimal_to_alpha(tonumber(af))
      return self:rgb_to_hex(r, g, b), alpha
    end
  elseif format == "vec3f" then
    local rf, gf, bf = match:match("vec3f%s*%(%s*([%d%.]+)%s*,%s*([%d%.]+)%s*,%s*([%d%.]+)%s*%)")
    if rf and gf and bf then
      local r, g, b = self:float_to_rgb(tonumber(rf), tonumber(gf), tonumber(bf))
      return self:rgb_to_hex(r, g, b), nil
    end
  elseif format == "vec4f" then
    local rf, gf, bf, af = match:match("vec4f%s*%(%s*([%d%.]+)%s*,%s*([%d%.]+)%s*,%s*([%d%.]+)%s*,%s*([%d%.]+)%s*%)")
    if rf and gf and bf and af then
      local r, g, b = self:float_to_rgb(tonumber(rf), tonumber(gf), tonumber(bf))
      local alpha = self:decimal_to_alpha(tonumber(af))
      return self:rgb_to_hex(r, g, b), alpha
    end
  elseif format == "hex" then
    return self:normalize_hex(match), nil
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

return ShaderAdapter
