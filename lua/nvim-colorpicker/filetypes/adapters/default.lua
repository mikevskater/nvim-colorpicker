---@module 'nvim-colorpicker.filetypes.adapters.default'
---@brief Default adapter that preserves current plugin behavior

local base = require('nvim-colorpicker.filetypes.base')
local patterns = require('nvim-colorpicker.filetypes.patterns')
local color_utils = require('nvim-colorpicker.color')
local color_format = require('nvim-colorpicker.color.format')

---@class DefaultAdapter : BaseAdapter
local DefaultAdapter = base.BaseAdapter.new({
  filetypes = { "_default" },  -- Fallback for unknown filetypes
  default_format = "hex",
  value_range = "0-255",
  -- Use current patterns that match existing detect.lua behavior
  patterns = {
    -- Vim highlight guifg/guibg (must come before hex to avoid double-matching)
    { pattern = "gui[fb]g=#%x%x%x%x%x%x", format = "vim", priority = 110 },

    -- CSS rgb/rgba
    { pattern = "rgba?%s*%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*[,/]?%s*[%d%.]*%s*%)", format = "rgb", priority = 100 },

    -- CSS hsl/hsla
    { pattern = "hsla?%s*%(%s*%d+%s*,%s*%d+%%%s*,%s*%d+%%%s*[,/]?%s*[%d%.]*%s*%)", format = "hsl", priority = 100 },

    -- Hex colors: #RGB, #RRGGBB, #RRGGBBAA (least specific, check last)
    { pattern = "#%x%x%x%x%x%x%x%x", format = "hex8", priority = 90 },
    { pattern = "#%x%x%x%x%x%x", format = "hex", priority = 85 },
    { pattern = "#%x%x%x", format = "hex3", priority = 80 },
  },
})

---Format a hex color to target format
---Preserves exact current format.lua behavior
---@param hex string The hex color
---@param format string Target format
---@param alpha number? Alpha value 0-100
---@return string formatted The formatted color string
function DefaultAdapter:format_color(hex, format, alpha)
  -- Use existing color format module for consistency
  local result = color_format.convert_format(hex, format, alpha)
  return result or hex
end

---Parse a matched color string to hex
---Preserves exact current detect.lua behavior
---@param match string The matched string
---@param format string The format type
---@return string? hex Hex color
---@return number? alpha Alpha value 0-100
function DefaultAdapter:parse_color(match, format)
  if format == "hex" then
    return color_utils.normalize_hex(match), nil
  elseif format == "hex3" then
    -- Expand #RGB to #RRGGBB
    local short = match:gsub("^#", "")
    if #short == 3 then
      local expanded = short:sub(1, 1):rep(2) .. short:sub(2, 2):rep(2) .. short:sub(3, 3):rep(2)
      return "#" .. expanded:upper(), nil
    end
  elseif format == "hex8" then
    -- Strip alpha from #RRGGBBAA, return alpha separately
    local alpha_hex = match:sub(8, 9)
    local alpha_int = tonumber(alpha_hex, 16)
    local alpha = alpha_int and math.floor((alpha_int / 255) * 100 + 0.5) or nil
    return "#" .. match:sub(2, 7):upper(), alpha
  elseif format == "rgb" then
    -- Match both rgb() and rgba() - extract first 3 numbers
    local r, g, b = match:match("rgba?%s*%(%s*(%d+)%s*[,/]?%s*(%d+)%s*[,/]?%s*(%d+)")
    if r and g and b then
      local hex = color_utils.rgb_to_hex(tonumber(r), tonumber(g), tonumber(b))
      -- Check for alpha
      local alpha_str = match:match("rgba%s*%([^,]+,[^,]+,[^,]+[,/]%s*([%d%.]+)%s*%)")
      local alpha = nil
      if alpha_str then
        alpha = math.floor(tonumber(alpha_str) * 100 + 0.5)
      end
      return hex, alpha
    end
  elseif format == "hsl" then
    -- Match both hsl() and hsla() - extract h, s%, l%
    local h, s, l = match:match("hsla?%s*%(%s*(%d+)%s*[,/]?%s*(%d+)%%%s*[,/]?%s*(%d+)%%")
    if h and s and l then
      local hex = color_utils.hsl_to_hex(tonumber(h), tonumber(s), tonumber(l))
      -- Check for alpha
      local alpha_str = match:match("hsla%s*%([^,]+,[^,]+,[^,]+[,/]%s*([%d%.]+)%s*%)")
      local alpha = nil
      if alpha_str then
        alpha = math.floor(tonumber(alpha_str) * 100 + 0.5)
      end
      return hex, alpha
    end
  elseif format == "vim" then
    local hex = match:match("#(%x%x%x%x%x%x)")
    if hex then
      return "#" .. hex:upper(), nil
    end
  end

  -- Fallback to color format parser
  return color_format.parse_color_string(match)
end

return DefaultAdapter
