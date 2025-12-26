---@brief Tests for rgb() color detection

local framework = require('nvim-colorpicker.tests.framework')
local describe, it, expect = framework.describe, framework.it, framework.expect

local detect = require('nvim-colorpicker.detect')

-- ============================================================================
-- parse_to_hex Tests (RGB Format)
-- ============================================================================

describe("parse_to_hex - rgb() format", function()
  it("parses standard rgb()", function()
    local hex = detect.parse_to_hex("rgb(255, 85, 0)", "rgb")
    expect(hex:lower()):toBe("#ff5500")
  end)

  it("parses rgb without spaces", function()
    local hex = detect.parse_to_hex("rgb(255,85,0)", "rgb")
    expect(hex:lower()):toBe("#ff5500")
  end)

  it("parses rgb with extra spaces", function()
    local hex = detect.parse_to_hex("rgb( 255 , 85 , 0 )", "rgb")
    expect(hex:lower()):toBe("#ff5500")
  end)

  it("parses red", function()
    local hex = detect.parse_to_hex("rgb(255, 0, 0)", "rgb")
    expect(hex:lower()):toBe("#ff0000")
  end)

  it("parses green", function()
    local hex = detect.parse_to_hex("rgb(0, 255, 0)", "rgb")
    expect(hex:lower()):toBe("#00ff00")
  end)

  it("parses blue", function()
    local hex = detect.parse_to_hex("rgb(0, 0, 255)", "rgb")
    expect(hex:lower()):toBe("#0000ff")
  end)

  it("parses black", function()
    local hex = detect.parse_to_hex("rgb(0, 0, 0)", "rgb")
    expect(hex:lower()):toBe("#000000")
  end)

  it("parses white", function()
    local hex = detect.parse_to_hex("rgb(255, 255, 255)", "rgb")
    expect(hex:lower()):toBe("#ffffff")
  end)

  it("parses mid-gray", function()
    local hex = detect.parse_to_hex("rgb(128, 128, 128)", "rgb")
    expect(hex:lower()):toBe("#808080")
  end)
end)

describe("parse_to_hex - rgba() format", function()
  it("parses rgba with decimal alpha", function()
    local hex = detect.parse_to_hex("rgba(255, 85, 0, 0.5)", "rgb")
    -- Should extract color, ignoring alpha for hex
    expect(hex:lower()):toBe("#ff5500")
  end)

  it("parses rgba with 1.0 alpha", function()
    local hex = detect.parse_to_hex("rgba(255, 85, 0, 1)", "rgb")
    expect(hex:lower()):toBe("#ff5500")
  end)

  it("parses rgba with 0 alpha", function()
    local hex = detect.parse_to_hex("rgba(255, 85, 0, 0)", "rgb")
    expect(hex:lower()):toBe("#ff5500")
  end)

  it("parses rgba with / separator", function()
    local hex = detect.parse_to_hex("rgba(255, 85, 0 / 0.5)", "rgb")
    expect(hex):toBeTruthy()
  end)
end)

-- ============================================================================
-- get_colors_in_line Tests (RGB)
-- ============================================================================

describe("get_colors_in_line - rgb detection", function()
  it("detects rgb() in CSS", function()
    local colors = detect.get_colors_in_line("color: rgb(255, 85, 0);", 1)
    expect(#colors):toBeGreaterThan(0)
    expect(colors[1].format):toBe("rgb")
  end)

  it("detects rgba() in CSS", function()
    local colors = detect.get_colors_in_line("color: rgba(255, 85, 0, 0.5);", 1)
    expect(#colors):toBeGreaterThan(0)
  end)

  it("returns correct positions for rgb", function()
    local line = "x rgb(255, 0, 0) y"
    local colors = detect.get_colors_in_line(line, 1)
    expect(#colors):toBe(1)
    expect(colors[1].original):toMatch("rgb%(255")
  end)

  it("detects multiple rgb colors", function()
    local colors = detect.get_colors_in_line("rgb(255, 0, 0) and rgb(0, 255, 0)", 1)
    expect(#colors):toBe(2)
  end)

  it("stores original string", function()
    local colors = detect.get_colors_in_line("rgb(255, 85, 0)", 1)
    expect(#colors):toBe(1)
    expect(colors[1].original):toContain("rgb")
    expect(colors[1].original):toContain("255")
  end)
end)

-- ============================================================================
-- RGB Value Edge Cases
-- ============================================================================

describe("rgb edge cases", function()
  it("handles boundary value 0", function()
    local hex = detect.parse_to_hex("rgb(0, 0, 0)", "rgb")
    expect(hex:lower()):toBe("#000000")
  end)

  it("handles boundary value 255", function()
    local hex = detect.parse_to_hex("rgb(255, 255, 255)", "rgb")
    expect(hex:lower()):toBe("#ffffff")
  end)

  it("handles single digit values", function()
    local hex = detect.parse_to_hex("rgb(1, 2, 3)", "rgb")
    expect(hex:lower()):toBe("#010203")
  end)

  it("handles two digit values", function()
    local hex = detect.parse_to_hex("rgb(10, 20, 30)", "rgb")
    expect(hex:lower()):toBe("#0a141e")
  end)

  it("handles mixed length values", function()
    local hex = detect.parse_to_hex("rgb(1, 100, 255)", "rgb")
    expect(hex):toBeTruthy()
  end)
end)

-- ============================================================================
-- Detection in Context
-- ============================================================================

describe("rgb detection in context", function()
  it("detects in JavaScript", function()
    local colors = detect.get_colors_in_line("const color = 'rgb(255, 128, 0)';", 1)
    expect(#colors):toBeGreaterThan(0)
  end)

  it("detects in Lua table", function()
    local colors = detect.get_colors_in_line("  color = 'rgb(255, 128, 0)',", 1)
    expect(#colors):toBeGreaterThan(0)
  end)

  it("detects in inline style", function()
    local colors = detect.get_colors_in_line('style="color: rgb(255, 128, 0)"', 1)
    expect(#colors):toBeGreaterThan(0)
  end)

  it("detects multiple formats on same line", function()
    local colors = detect.get_colors_in_line("#ff0000 and rgb(0, 255, 0)", 1)
    expect(#colors):toBe(2)
  end)
end)
