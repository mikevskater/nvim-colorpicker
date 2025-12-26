---@brief Tests for hsl() color detection

local framework = require('nvim-colorpicker.tests.framework')
local describe, it, expect = framework.describe, framework.it, framework.expect

local detect = require('nvim-colorpicker.detect')

-- ============================================================================
-- parse_to_hex Tests (HSL Format)
-- ============================================================================

describe("parse_to_hex - hsl() format", function()
  it("parses red hsl (0, 100%, 50%)", function()
    local hex = detect.parse_to_hex("hsl(0, 100%, 50%)", "hsl")
    expect(hex:lower()):toBe("#ff0000")
  end)

  it("parses green hsl (120, 100%, 50%)", function()
    local hex = detect.parse_to_hex("hsl(120, 100%, 50%)", "hsl")
    expect(hex:lower()):toBe("#00ff00")
  end)

  it("parses blue hsl (240, 100%, 50%)", function()
    local hex = detect.parse_to_hex("hsl(240, 100%, 50%)", "hsl")
    expect(hex:lower()):toBe("#0000ff")
  end)

  it("parses white hsl (0, 0%, 100%)", function()
    local hex = detect.parse_to_hex("hsl(0, 0%, 100%)", "hsl")
    expect(hex:lower()):toBe("#ffffff")
  end)

  it("parses black hsl (0, 0%, 0%)", function()
    local hex = detect.parse_to_hex("hsl(0, 0%, 0%)", "hsl")
    expect(hex:lower()):toBe("#000000")
  end)

  it("parses gray hsl (0, 0%, 50%)", function()
    local hex = detect.parse_to_hex("hsl(0, 0%, 50%)", "hsl")
    -- Should be approximately #808080
    expect(hex:lower()):toMatch("^#[78][0-9a-f][78][0-9a-f][78][0-9a-f]$")
  end)

  it("parses hsl without spaces", function()
    local hex = detect.parse_to_hex("hsl(0,100%,50%)", "hsl")
    expect(hex:lower()):toBe("#ff0000")
  end)

  it("parses orange hsl (30, 100%, 50%)", function()
    local hex = detect.parse_to_hex("hsl(30, 100%, 50%)", "hsl")
    expect(hex):toBeTruthy()
  end)

  it("parses cyan hsl (180, 100%, 50%)", function()
    local hex = detect.parse_to_hex("hsl(180, 100%, 50%)", "hsl")
    expect(hex:lower()):toBe("#00ffff")
  end)

  it("parses magenta hsl (300, 100%, 50%)", function()
    local hex = detect.parse_to_hex("hsl(300, 100%, 50%)", "hsl")
    expect(hex:lower()):toBe("#ff00ff")
  end)

  it("parses yellow hsl (60, 100%, 50%)", function()
    local hex = detect.parse_to_hex("hsl(60, 100%, 50%)", "hsl")
    expect(hex:lower()):toBe("#ffff00")
  end)
end)

describe("parse_to_hex - hsla() format", function()
  it("parses hsla with decimal alpha", function()
    local hex = detect.parse_to_hex("hsla(0, 100%, 50%, 0.5)", "hsl")
    expect(hex:lower()):toBe("#ff0000")
  end)

  it("parses hsla with 1.0 alpha", function()
    local hex = detect.parse_to_hex("hsla(120, 100%, 50%, 1)", "hsl")
    expect(hex:lower()):toBe("#00ff00")
  end)

  it("parses hsla with 0 alpha", function()
    local hex = detect.parse_to_hex("hsla(240, 100%, 50%, 0)", "hsl")
    expect(hex:lower()):toBe("#0000ff")
  end)

  it("parses hsla with / separator", function()
    local hex = detect.parse_to_hex("hsla(0, 100%, 50% / 0.5)", "hsl")
    expect(hex):toBeTruthy()
  end)
end)

-- ============================================================================
-- get_colors_in_line Tests (HSL)
-- ============================================================================

describe("get_colors_in_line - hsl detection", function()
  it("detects hsl() in CSS", function()
    local colors = detect.get_colors_in_line("color: hsl(0, 100%, 50%);", 1)
    expect(#colors):toBeGreaterThan(0)
    expect(colors[1].format):toBe("hsl")
  end)

  it("detects hsla() in CSS", function()
    local colors = detect.get_colors_in_line("color: hsla(0, 100%, 50%, 0.5);", 1)
    expect(#colors):toBeGreaterThan(0)
  end)

  it("returns correct positions for hsl", function()
    local line = "x hsl(120, 100%, 50%) y"
    local colors = detect.get_colors_in_line(line, 1)
    expect(#colors):toBe(1)
    expect(colors[1].original):toMatch("hsl%(120")
  end)

  it("detects multiple hsl colors", function()
    local colors = detect.get_colors_in_line("hsl(0, 100%, 50%) and hsl(120, 100%, 50%)", 1)
    expect(#colors):toBe(2)
  end)

  it("stores original string", function()
    local colors = detect.get_colors_in_line("hsl(60, 100%, 50%)", 1)
    expect(#colors):toBe(1)
    expect(colors[1].original):toContain("hsl")
    expect(colors[1].original):toContain("60")
  end)
end)

-- ============================================================================
-- HSL Value Edge Cases
-- ============================================================================

describe("hsl edge cases", function()
  it("handles hue 0", function()
    local hex = detect.parse_to_hex("hsl(0, 100%, 50%)", "hsl")
    expect(hex:lower()):toBe("#ff0000")
  end)

  it("handles hue 360 (same as 0)", function()
    local hex = detect.parse_to_hex("hsl(360, 100%, 50%)", "hsl")
    -- 360 degrees = 0 degrees = red
    expect(hex:lower()):toBe("#ff0000")
  end)

  it("handles saturation 0 (gray)", function()
    local hex = detect.parse_to_hex("hsl(180, 0%, 50%)", "hsl")
    -- Any hue with 0% saturation is gray
    expect(hex:lower()):toMatch("^#[78]")
  end)

  it("handles saturation 100% (full color)", function()
    local hex = detect.parse_to_hex("hsl(0, 100%, 50%)", "hsl")
    expect(hex:lower()):toBe("#ff0000")
  end)

  it("handles lightness 0 (black)", function()
    local hex = detect.parse_to_hex("hsl(0, 100%, 0%)", "hsl")
    expect(hex:lower()):toBe("#000000")
  end)

  it("handles lightness 100% (white)", function()
    local hex = detect.parse_to_hex("hsl(0, 100%, 100%)", "hsl")
    expect(hex:lower()):toBe("#ffffff")
  end)

  it("handles lightness 25% (dark)", function()
    local hex = detect.parse_to_hex("hsl(0, 100%, 25%)", "hsl")
    expect(hex):toBeTruthy()
    -- Should be a dark red
  end)

  it("handles lightness 75% (light)", function()
    local hex = detect.parse_to_hex("hsl(0, 100%, 75%)", "hsl")
    expect(hex):toBeTruthy()
    -- Should be a light red/pink
  end)
end)

-- ============================================================================
-- Detection in Context
-- ============================================================================

describe("hsl detection in context", function()
  it("detects in CSS variable", function()
    local colors = detect.get_colors_in_line("--primary: hsl(210, 100%, 50%);", 1)
    expect(#colors):toBeGreaterThan(0)
  end)

  it("detects in JavaScript", function()
    local colors = detect.get_colors_in_line("const color = 'hsl(45, 100%, 50%)';", 1)
    expect(#colors):toBeGreaterThan(0)
  end)

  it("detects mixed hsl and hex", function()
    local colors = detect.get_colors_in_line("#ff0000 and hsl(120, 100%, 50%)", 1)
    expect(#colors):toBe(2)
  end)

  it("detects mixed hsl and rgb", function()
    local colors = detect.get_colors_in_line("rgb(255, 0, 0) and hsl(120, 100%, 50%)", 1)
    expect(#colors):toBe(2)
  end)
end)
