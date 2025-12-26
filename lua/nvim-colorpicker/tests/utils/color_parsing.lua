---@brief Tests for color parsing and format conversion

local framework = require('nvim-colorpicker.tests.framework')
local describe, it, expect = framework.describe, framework.it, framework.expect

local utils = require('nvim-colorpicker.utils')

-- ============================================================================
-- parse_color_string Tests
-- ============================================================================

describe("parse_color_string - hex formats", function()
  it("parses 6-digit hex with #", function()
    local hex = utils.parse_color_string("#ff5500")
    expect(hex):toBe("#FF5500")
  end)

  it("parses 6-digit hex without #", function()
    local hex = utils.parse_color_string("ff5500")
    expect(hex):toBe("#FF5500")
  end)

  it("parses 3-digit hex and expands", function()
    local hex = utils.parse_color_string("#f50")
    expect(hex):toBe("#FF5500")
  end)

  it("parses uppercase hex", function()
    local hex = utils.parse_color_string("#FF5500")
    expect(hex):toBeTruthy()
  end)

  it("parses 8-digit hex (with alpha)", function()
    local hex = utils.parse_color_string("#ff550080")
    expect(hex):toBeTruthy()
  end)

  it("returns nil for invalid hex", function()
    local hex = utils.parse_color_string("#gggggg")
    expect(hex):toBeNil()
  end)

  it("returns nil for wrong length hex", function()
    local hex = utils.parse_color_string("#ff55")
    expect(hex):toBeNil()
  end)
end)

describe("parse_color_string - rgb formats", function()
  it("parses rgb() format", function()
    local hex = utils.parse_color_string("rgb(255, 85, 0)")
    expect(hex:lower()):toBe("#ff5500")
  end)

  it("parses rgb without spaces", function()
    local hex = utils.parse_color_string("rgb(255,85,0)")
    expect(hex:lower()):toBe("#ff5500")
  end)

  it("parses rgba() format", function()
    local hex = utils.parse_color_string("rgba(255, 85, 0, 0.5)")
    expect(hex):toBeTruthy()
  end)

  it("parses rgb with percentage values", function()
    local hex = utils.parse_color_string("rgb(100%, 33%, 0%)")
    expect(hex):toBeTruthy()
  end)

  it("handles rgb boundary values", function()
    local hex = utils.parse_color_string("rgb(0, 0, 0)")
    expect(hex:lower()):toBe("#000000")
  end)

  it("handles rgb max values", function()
    local hex = utils.parse_color_string("rgb(255, 255, 255)")
    expect(hex:lower()):toBe("#ffffff")
  end)
end)

describe("parse_color_string - hsl formats", function()
  it("parses hsl() format", function()
    local hex = utils.parse_color_string("hsl(0, 100%, 50%)")
    expect(hex):toBeTruthy()
    -- Should be close to red
  end)

  it("parses hsl without spaces", function()
    local hex = utils.parse_color_string("hsl(120,100%,50%)")
    expect(hex):toBeTruthy()
  end)

  it("parses hsla() format", function()
    local hex = utils.parse_color_string("hsla(0, 100%, 50%, 0.5)")
    expect(hex):toBeTruthy()
  end)

  it("parses hsl with 0 saturation (gray)", function()
    local hex = utils.parse_color_string("hsl(0, 0%, 50%)")
    expect(hex):toBeTruthy()
  end)
end)

describe("parse_color_string - hsv formats", function()
  it("parses hsv() format", function()
    local hex = utils.parse_color_string("hsv(0, 100%, 100%)")
    expect(hex):toBeTruthy()
  end)

  it("parses hsv without spaces", function()
    local hex = utils.parse_color_string("hsv(120,100%,100%)")
    expect(hex):toBeTruthy()
  end)
end)

describe("parse_color_string - edge cases", function()
  it("returns nil for empty string", function()
    local hex = utils.parse_color_string("")
    expect(hex):toBeNil()
  end)

  it("returns nil for whitespace only", function()
    local hex = utils.parse_color_string("   ")
    expect(hex):toBeNil()
  end)

  it("returns nil for invalid format", function()
    local hex = utils.parse_color_string("not a color")
    expect(hex):toBeNil()
  end)

  it("trims whitespace from input", function()
    local hex = utils.parse_color_string("  #ff5500  ")
    expect(hex):toBeTruthy()
  end)
end)

-- ============================================================================
-- convert_format Tests
-- ============================================================================

describe("convert_format - to hex", function()
  it("converts to hex from hex (no change)", function()
    local result = utils.convert_format("#ff5500", "hex")
    expect(result:lower()):toBe("#ff5500")
  end)

  it("normalizes hex case", function()
    local result = utils.convert_format("#FF5500", "hex")
    expect(result):toMatch("^#")
  end)
end)

describe("convert_format - to rgb", function()
  it("converts hex to rgb format", function()
    local result = utils.convert_format("#ff5500", "rgb")
    expect(result):toMatch("^rgb%(")
    expect(result):toContain("255")
    expect(result):toContain("85")
    expect(result):toContain("0")
  end)

  it("converts red correctly", function()
    local result = utils.convert_format("#ff0000", "rgb")
    expect(result):toMatch("rgb%(255")
  end)
end)

describe("convert_format - to hsl", function()
  it("converts hex to hsl format", function()
    local result = utils.convert_format("#ff0000", "hsl")
    expect(result):toMatch("^hsl%(")
    expect(result):toContain("0")  -- hue
    expect(result):toContain("100%")  -- saturation
    expect(result):toContain("50%")  -- lightness
  end)

  it("converts green correctly", function()
    local result = utils.convert_format("#00ff00", "hsl")
    expect(result):toMatch("^hsl%(")
    expect(result):toContain("120")  -- hue for green
  end)
end)

describe("convert_format - to hsv", function()
  it("converts hex to hsv format", function()
    local result = utils.convert_format("#ff0000", "hsv")
    expect(result):toMatch("^hsv%(")
    expect(result):toContain("0")  -- hue
    expect(result):toContain("100%")  -- saturation
    expect(result):toContain("100%")  -- value
  end)
end)

describe("convert_format - edge cases", function()
  it("returns nil for invalid hex input", function()
    local result = utils.convert_format("not a color", "rgb")
    expect(result):toBeNil()
  end)

  it("returns nil for invalid format", function()
    local result = utils.convert_format("#ff5500", "invalid")
    expect(result):toBeNil()
  end)

  it("handles white correctly in all formats", function()
    local rgb = utils.convert_format("#ffffff", "rgb")
    expect(rgb):toContain("255")

    local hsl = utils.convert_format("#ffffff", "hsl")
    expect(hsl):toContain("100%")

    local hsv = utils.convert_format("#ffffff", "hsv")
    expect(hsv):toContain("100%")
  end)

  it("handles black correctly in all formats", function()
    local rgb = utils.convert_format("#000000", "rgb")
    expect(rgb):toMatch("rgb%(0")

    local hsl = utils.convert_format("#000000", "hsl")
    expect(hsl):toContain("0%")
  end)
end)

-- ============================================================================
-- Utility Function Tests
-- ============================================================================

describe("is_valid_hex", function()
  it("validates 6-digit hex", function()
    local valid = utils.is_valid_hex("#ff5500")
    expect(valid):toBeTruthy()
  end)

  it("validates 3-digit hex", function()
    local valid = utils.is_valid_hex("#f50")
    expect(valid):toBeTruthy()
  end)

  it("validates 8-digit hex", function()
    local valid = utils.is_valid_hex("#ff550080")
    expect(valid):toBeTruthy()
  end)

  it("rejects invalid characters", function()
    local valid = utils.is_valid_hex("#gggggg")
    expect(valid):toBeFalsy()
  end)

  it("rejects wrong length", function()
    local valid = utils.is_valid_hex("#ff55")
    expect(valid):toBeFalsy()
  end)
end)

describe("normalize_hex", function()
  it("adds # prefix if missing", function()
    local hex = utils.normalize_hex("ff5500")
    expect(hex):toMatch("^#")
  end)

  it("expands 3-digit to 6-digit", function()
    local hex = utils.normalize_hex("#f50")
    expect(#hex):toBe(7)  -- # + 6 chars
  end)

  it("applies consistent case (default upper)", function()
    local hex = utils.normalize_hex("#ff5500")
    -- Default config is uppercase
    expect(hex):toBe("#FF5500")
  end)

  it("normalizes mixed case input", function()
    local hex = utils.normalize_hex("#FfAaBb")
    expect(hex:lower()):toBe("#ffaabb")
  end)

  it("preserves valid 6-digit hex structure", function()
    local hex = utils.normalize_hex("#ff5500")
    expect(hex:lower()):toBe("#ff5500")
  end)
end)

describe("get_contrast_color", function()
  it("returns dark for light colors", function()
    local contrast = utils.get_contrast_color("#ffffff")
    -- Should be dark (low RGB values)
    expect(contrast):toBeTruthy()
  end)

  it("returns light for dark colors", function()
    local contrast = utils.get_contrast_color("#000000")
    -- Should be light (high RGB values)
    expect(contrast):toBeTruthy()
  end)

  it("returns contrast for mid colors", function()
    local contrast = utils.get_contrast_color("#808080")
    expect(contrast):toBeTruthy()
  end)
end)
