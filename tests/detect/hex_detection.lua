---@brief Tests for hex color detection

local framework = require('tests.framework')
local describe, it, expect = framework.describe, framework.it, framework.expect

local detect = require('nvim-colorpicker.detect')

-- ============================================================================
-- parse_to_hex Tests (Hex Format)
-- ============================================================================

describe("parse_to_hex - 6-digit hex", function()
  it("parses standard 6-digit hex", function()
    local hex = detect.parse_to_hex("#ff5500", "hex")
    expect(hex:lower()):toBe("#ff5500")
  end)

  it("parses lowercase hex", function()
    local hex = detect.parse_to_hex("#aabbcc", "hex")
    expect(hex:lower()):toBe("#aabbcc")
  end)

  it("parses uppercase hex", function()
    local hex = detect.parse_to_hex("#AABBCC", "hex")
    expect(hex:lower()):toBe("#aabbcc")
  end)

  it("parses mixed case hex", function()
    local hex = detect.parse_to_hex("#AaBbCc", "hex")
    expect(hex:lower()):toBe("#aabbcc")
  end)

  it("parses pure colors", function()
    expect(detect.parse_to_hex("#ff0000", "hex"):lower()):toBe("#ff0000")
    expect(detect.parse_to_hex("#00ff00", "hex"):lower()):toBe("#00ff00")
    expect(detect.parse_to_hex("#0000ff", "hex"):lower()):toBe("#0000ff")
  end)

  it("parses black and white", function()
    expect(detect.parse_to_hex("#000000", "hex"):lower()):toBe("#000000")
    expect(detect.parse_to_hex("#ffffff", "hex"):lower()):toBe("#ffffff")
  end)
end)

describe("parse_to_hex - 3-digit hex", function()
  it("expands 3-digit to 6-digit", function()
    local hex = detect.parse_to_hex("#f50", "hex3")
    expect(hex:lower()):toBe("#ff5500")
  end)

  it("expands #fff to #ffffff", function()
    local hex = detect.parse_to_hex("#fff", "hex3")
    expect(hex:lower()):toBe("#ffffff")
  end)

  it("expands #000 to #000000", function()
    local hex = detect.parse_to_hex("#000", "hex3")
    expect(hex:lower()):toBe("#000000")
  end)

  it("expands #abc to #aabbcc", function()
    local hex = detect.parse_to_hex("#abc", "hex3")
    expect(hex:lower()):toBe("#aabbcc")
  end)

  it("handles uppercase 3-digit", function()
    local hex = detect.parse_to_hex("#F50", "hex3")
    expect(hex:lower()):toBe("#ff5500")
  end)
end)

describe("parse_to_hex - 8-digit hex (with alpha)", function()
  it("parses 8-digit hex", function()
    local hex = detect.parse_to_hex("#ff550080", "hex8")
    -- Should return at least the color part
    expect(hex):toBeTruthy()
  end)

  it("parses full opacity 8-digit", function()
    local hex = detect.parse_to_hex("#ff5500ff", "hex8")
    expect(hex):toBeTruthy()
  end)

  it("parses zero opacity 8-digit", function()
    local hex = detect.parse_to_hex("#ff550000", "hex8")
    expect(hex):toBeTruthy()
  end)
end)

-- ============================================================================
-- get_colors_in_line Tests (Hex)
-- ============================================================================

describe("get_colors_in_line - hex detection", function()
  it("detects single 6-digit hex", function()
    local colors = detect.get_colors_in_line("color: #ff5500;", 1)
    expect(#colors):toBeGreaterThan(0)
    expect(colors[1].color:lower()):toBe("#ff5500")
  end)

  it("detects multiple hex colors in line", function()
    local colors = detect.get_colors_in_line("colors: #ff0000, #00ff00, #0000ff", 1)
    expect(#colors):toBe(3)
  end)

  it("returns correct positions", function()
    local colors = detect.get_colors_in_line("x #ff5500 y", 1)
    expect(#colors):toBe(1)
    expect(colors[1].start_col):toBe(2)  -- 0-indexed position of #
    expect(colors[1].end_col):toBe(9)    -- Position after last char
  end)

  it("detects hex at start of line", function()
    local colors = detect.get_colors_in_line("#ff5500 text", 1)
    expect(#colors):toBe(1)
    expect(colors[1].start_col):toBe(0)
  end)

  it("detects hex at end of line", function()
    local colors = detect.get_colors_in_line("text #ff5500", 1)
    expect(#colors):toBe(1)
  end)

  it("detects 3-digit hex", function()
    local colors = detect.get_colors_in_line("color: #f50;", 1)
    expect(#colors):toBeGreaterThan(0)
    expect(colors[1].format):toBe("hex3")
  end)

  it("returns empty for no colors", function()
    local colors = detect.get_colors_in_line("no colors here", 1)
    expect(#colors):toBe(0)
  end)

  it("ignores invalid hex-like strings", function()
    local colors = detect.get_colors_in_line("#gggggg invalid", 1)
    expect(#colors):toBe(0)
  end)
end)

-- ============================================================================
-- Edge Cases
-- ============================================================================

describe("hex detection edge cases", function()
  it("handles hex in CSS property", function()
    local colors = detect.get_colors_in_line("background-color: #ff5500;", 1)
    expect(#colors):toBe(1)
  end)

  it("handles hex in CSS variable", function()
    local colors = detect.get_colors_in_line("--primary-color: #ff5500;", 1)
    expect(#colors):toBe(1)
  end)

  it("handles hex in Lua string", function()
    local colors = detect.get_colors_in_line('local color = "#ff5500"', 1)
    expect(#colors):toBe(1)
  end)

  it("handles multiple hex on same line", function()
    local colors = detect.get_colors_in_line("#ff0000 #00ff00 #0000ff", 1)
    expect(#colors):toBe(3)
    expect(colors[1].color:lower()):toBe("#ff0000")
    expect(colors[2].color:lower()):toBe("#00ff00")
    expect(colors[3].color:lower()):toBe("#0000ff")
  end)

  it("handles adjacent hex colors", function()
    local colors = detect.get_colors_in_line("#ff0000#00ff00", 1)
    -- Should find both
    expect(#colors):toBeGreaterThan(0)
  end)
end)
