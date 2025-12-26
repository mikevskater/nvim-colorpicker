---@brief Tests for color conversion functions

local framework = require('nvim-colorpicker.tests.framework')
local describe, it, expect = framework.describe, framework.it, framework.expect

local utils = require('nvim-colorpicker.utils')

-- ============================================================================
-- Hex <-> RGB Conversions
-- ============================================================================

describe("hex_to_rgb", function()
  it("converts 6-digit hex to RGB", function()
    local r, g, b = utils.hex_to_rgb("#ff0000")
    expect(r):toBe(255)
    expect(g):toBe(0)
    expect(b):toBe(0)
  end)

  it("converts lowercase hex", function()
    local r, g, b = utils.hex_to_rgb("#00ff00")
    expect(r):toBe(0)
    expect(g):toBe(255)
    expect(b):toBe(0)
  end)

  it("converts uppercase hex", function()
    local r, g, b = utils.hex_to_rgb("#0000FF")
    expect(r):toBe(0)
    expect(g):toBe(0)
    expect(b):toBe(255)
  end)

  it("converts mixed case hex", function()
    local r, g, b = utils.hex_to_rgb("#FfAa00")
    expect(r):toBe(255)
    expect(g):toBe(170)
    expect(b):toBe(0)
  end)

  it("handles hex without # prefix", function()
    local r, g, b = utils.hex_to_rgb("ff5500")
    expect(r):toBe(255)
    expect(g):toBe(85)
    expect(b):toBe(0)
  end)

  it("converts white correctly", function()
    local r, g, b = utils.hex_to_rgb("#ffffff")
    expect(r):toBe(255)
    expect(g):toBe(255)
    expect(b):toBe(255)
  end)

  it("converts black correctly", function()
    local r, g, b = utils.hex_to_rgb("#000000")
    expect(r):toBe(0)
    expect(g):toBe(0)
    expect(b):toBe(0)
  end)

  it("converts mid-gray correctly", function()
    local r, g, b = utils.hex_to_rgb("#808080")
    expect(r):toBe(128)
    expect(g):toBe(128)
    expect(b):toBe(128)
  end)
end)

describe("rgb_to_hex", function()
  it("converts RGB to hex", function()
    local hex = utils.rgb_to_hex(255, 0, 0)
    expect(hex:lower()):toBe("#ff0000")
  end)

  it("converts green correctly", function()
    local hex = utils.rgb_to_hex(0, 255, 0)
    expect(hex:lower()):toBe("#00ff00")
  end)

  it("converts blue correctly", function()
    local hex = utils.rgb_to_hex(0, 0, 255)
    expect(hex:lower()):toBe("#0000ff")
  end)

  it("converts mixed colors", function()
    local hex = utils.rgb_to_hex(255, 128, 64)
    expect(hex:lower()):toBe("#ff8040")
  end)

  it("pads single digit values with zeros", function()
    local hex = utils.rgb_to_hex(1, 2, 3)
    expect(hex:lower()):toBe("#010203")
  end)

  it("handles boundary values", function()
    local hex = utils.rgb_to_hex(0, 0, 0)
    expect(hex:lower()):toBe("#000000")
  end)
end)

-- ============================================================================
-- RGB <-> HSL Conversions
-- ============================================================================

describe("rgb_to_hsl", function()
  it("converts red to HSL", function()
    local h, s, l = utils.rgb_to_hsl(255, 0, 0)
    expect(h):toBeCloseTo(0, 1)
    expect(s):toBeCloseTo(100, 1)
    expect(l):toBeCloseTo(50, 1)
  end)

  it("converts green to HSL", function()
    local h, s, l = utils.rgb_to_hsl(0, 255, 0)
    expect(h):toBeCloseTo(120, 1)
    expect(s):toBeCloseTo(100, 1)
    expect(l):toBeCloseTo(50, 1)
  end)

  it("converts blue to HSL", function()
    local h, s, l = utils.rgb_to_hsl(0, 0, 255)
    expect(h):toBeCloseTo(240, 1)
    expect(s):toBeCloseTo(100, 1)
    expect(l):toBeCloseTo(50, 1)
  end)

  it("converts white to HSL", function()
    local h, s, l = utils.rgb_to_hsl(255, 255, 255)
    expect(l):toBeCloseTo(100, 1)
    expect(s):toBeCloseTo(0, 1)
  end)

  it("converts black to HSL", function()
    local h, s, l = utils.rgb_to_hsl(0, 0, 0)
    expect(l):toBeCloseTo(0, 1)
  end)

  it("converts gray to HSL (no saturation)", function()
    local h, s, l = utils.rgb_to_hsl(128, 128, 128)
    expect(s):toBeCloseTo(0, 1)
    expect(l):toBeCloseTo(50, 2)
  end)

  it("converts orange to HSL", function()
    local h, s, l = utils.rgb_to_hsl(255, 128, 0)
    expect(h):toBeCloseTo(30, 1)
    expect(s):toBeCloseTo(100, 1)
  end)
end)

describe("hsl_to_rgb", function()
  it("converts red HSL to RGB", function()
    local r, g, b = utils.hsl_to_rgb(0, 100, 50)
    expect(r):toBeCloseTo(255, 1)
    expect(g):toBeCloseTo(0, 1)
    expect(b):toBeCloseTo(0, 1)
  end)

  it("converts green HSL to RGB", function()
    local r, g, b = utils.hsl_to_rgb(120, 100, 50)
    expect(r):toBeCloseTo(0, 1)
    expect(g):toBeCloseTo(255, 1)
    expect(b):toBeCloseTo(0, 1)
  end)

  it("converts blue HSL to RGB", function()
    local r, g, b = utils.hsl_to_rgb(240, 100, 50)
    expect(r):toBeCloseTo(0, 1)
    expect(g):toBeCloseTo(0, 1)
    expect(b):toBeCloseTo(255, 1)
  end)

  it("converts white HSL to RGB", function()
    local r, g, b = utils.hsl_to_rgb(0, 0, 100)
    expect(r):toBeCloseTo(255, 1)
    expect(g):toBeCloseTo(255, 1)
    expect(b):toBeCloseTo(255, 1)
  end)

  it("converts black HSL to RGB", function()
    local r, g, b = utils.hsl_to_rgb(0, 0, 0)
    expect(r):toBeCloseTo(0, 1)
    expect(g):toBeCloseTo(0, 1)
    expect(b):toBeCloseTo(0, 1)
  end)

  it("round-trips correctly", function()
    local original_r, original_g, original_b = 180, 90, 45
    local h, s, l = utils.rgb_to_hsl(original_r, original_g, original_b)
    local r, g, b = utils.hsl_to_rgb(h, s, l)
    expect(r):toBeCloseTo(original_r, 1)
    expect(g):toBeCloseTo(original_g, 1)
    expect(b):toBeCloseTo(original_b, 1)
  end)
end)

-- ============================================================================
-- RGB <-> HSV Conversions
-- ============================================================================

describe("rgb_to_hsv", function()
  it("converts red to HSV", function()
    local h, s, v = utils.rgb_to_hsv(255, 0, 0)
    expect(h):toBeCloseTo(0, 1)
    expect(s):toBeCloseTo(100, 1)
    expect(v):toBeCloseTo(100, 1)
  end)

  it("converts green to HSV", function()
    local h, s, v = utils.rgb_to_hsv(0, 255, 0)
    expect(h):toBeCloseTo(120, 1)
    expect(s):toBeCloseTo(100, 1)
    expect(v):toBeCloseTo(100, 1)
  end)

  it("converts blue to HSV", function()
    local h, s, v = utils.rgb_to_hsv(0, 0, 255)
    expect(h):toBeCloseTo(240, 1)
    expect(s):toBeCloseTo(100, 1)
    expect(v):toBeCloseTo(100, 1)
  end)

  it("converts black to HSV", function()
    local h, s, v = utils.rgb_to_hsv(0, 0, 0)
    expect(v):toBeCloseTo(0, 1)
  end)

  it("converts white to HSV", function()
    local h, s, v = utils.rgb_to_hsv(255, 255, 255)
    expect(s):toBeCloseTo(0, 1)
    expect(v):toBeCloseTo(100, 1)
  end)
end)

describe("hsv_to_rgb", function()
  it("converts red HSV to RGB", function()
    local r, g, b = utils.hsv_to_rgb(0, 100, 100)
    expect(r):toBeCloseTo(255, 1)
    expect(g):toBeCloseTo(0, 1)
    expect(b):toBeCloseTo(0, 1)
  end)

  it("converts green HSV to RGB", function()
    local r, g, b = utils.hsv_to_rgb(120, 100, 100)
    expect(r):toBeCloseTo(0, 1)
    expect(g):toBeCloseTo(255, 1)
    expect(b):toBeCloseTo(0, 1)
  end)

  it("converts blue HSV to RGB", function()
    local r, g, b = utils.hsv_to_rgb(240, 100, 100)
    expect(r):toBeCloseTo(0, 1)
    expect(g):toBeCloseTo(0, 1)
    expect(b):toBeCloseTo(255, 1)
  end)

  it("round-trips correctly", function()
    local original_r, original_g, original_b = 180, 90, 45
    local h, s, v = utils.rgb_to_hsv(original_r, original_g, original_b)
    local r, g, b = utils.hsv_to_rgb(h, s, v)
    expect(r):toBeCloseTo(original_r, 1)
    expect(g):toBeCloseTo(original_g, 1)
    expect(b):toBeCloseTo(original_b, 1)
  end)
end)

-- ============================================================================
-- RGB <-> CMYK Conversions
-- ============================================================================

describe("rgb_to_cmyk", function()
  it("converts red to CMYK", function()
    local c, m, y, k = utils.rgb_to_cmyk(255, 0, 0)
    expect(c):toBeCloseTo(0, 1)
    expect(m):toBeCloseTo(100, 1)
    expect(y):toBeCloseTo(100, 1)
    expect(k):toBeCloseTo(0, 1)
  end)

  it("converts green to CMYK", function()
    local c, m, y, k = utils.rgb_to_cmyk(0, 255, 0)
    expect(c):toBeCloseTo(100, 1)
    expect(m):toBeCloseTo(0, 1)
    expect(y):toBeCloseTo(100, 1)
    expect(k):toBeCloseTo(0, 1)
  end)

  it("converts blue to CMYK", function()
    local c, m, y, k = utils.rgb_to_cmyk(0, 0, 255)
    expect(c):toBeCloseTo(100, 1)
    expect(m):toBeCloseTo(100, 1)
    expect(y):toBeCloseTo(0, 1)
    expect(k):toBeCloseTo(0, 1)
  end)

  it("converts black to CMYK", function()
    local c, m, y, k = utils.rgb_to_cmyk(0, 0, 0)
    expect(k):toBeCloseTo(100, 1)
  end)

  it("converts white to CMYK", function()
    local c, m, y, k = utils.rgb_to_cmyk(255, 255, 255)
    expect(c):toBeCloseTo(0, 1)
    expect(m):toBeCloseTo(0, 1)
    expect(y):toBeCloseTo(0, 1)
    expect(k):toBeCloseTo(0, 1)
  end)
end)

describe("cmyk_to_rgb", function()
  it("converts CMYK red to RGB", function()
    local r, g, b = utils.cmyk_to_rgb(0, 100, 100, 0)
    expect(r):toBeCloseTo(255, 1)
    expect(g):toBeCloseTo(0, 1)
    expect(b):toBeCloseTo(0, 1)
  end)

  it("converts CMYK green to RGB", function()
    local r, g, b = utils.cmyk_to_rgb(100, 0, 100, 0)
    expect(r):toBeCloseTo(0, 1)
    expect(g):toBeCloseTo(255, 1)
    expect(b):toBeCloseTo(0, 1)
  end)

  it("converts CMYK blue to RGB", function()
    local r, g, b = utils.cmyk_to_rgb(100, 100, 0, 0)
    expect(r):toBeCloseTo(0, 1)
    expect(g):toBeCloseTo(0, 1)
    expect(b):toBeCloseTo(255, 1)
  end)

  it("round-trips correctly", function()
    local original_r, original_g, original_b = 180, 90, 45
    local c, m, y, k = utils.rgb_to_cmyk(original_r, original_g, original_b)
    local r, g, b = utils.cmyk_to_rgb(c, m, y, k)
    expect(r):toBeCloseTo(original_r, 1)
    expect(g):toBeCloseTo(original_g, 1)
    expect(b):toBeCloseTo(original_b, 1)
  end)
end)
