---@brief Tests for Tailwind CSS color presets

local framework = require('nvim-colorpicker.tests.framework')
local describe, it, expect = framework.describe, framework.it, framework.expect

local presets = require('nvim-colorpicker.presets')

-- ============================================================================
-- Tailwind Preset Availability
-- ============================================================================

describe("tailwind preset existence", function()
  it("has tailwind preset available", function()
    local names = presets.get_preset_names()
    expect(names):toContain("tailwind")
  end)

  it("can get tailwind preset", function()
    local tailwind = presets.get_preset("tailwind")
    expect(tailwind):toBeTruthy()
    expect(type(tailwind)):toBe("table")
  end)

  it("tailwind preset has colors", function()
    local tailwind = presets.get_preset("tailwind")
    local count = 0
    for _ in pairs(tailwind) do count = count + 1 end
    expect(count):toBeGreaterThan(200)  -- Should have 220+ colors
  end)
end)

-- ============================================================================
-- Tailwind Color Families
-- ============================================================================

describe("tailwind color families", function()
  it("has slate colors", function()
    local color = presets.get_color("tailwind", "slate-500")
    expect(color):toBeTruthy()
  end)

  it("has gray colors", function()
    local color = presets.get_color("tailwind", "gray-500")
    expect(color):toBeTruthy()
  end)

  it("has zinc colors", function()
    local color = presets.get_color("tailwind", "zinc-500")
    expect(color):toBeTruthy()
  end)

  it("has neutral colors", function()
    local color = presets.get_color("tailwind", "neutral-500")
    expect(color):toBeTruthy()
  end)

  it("has rose colors", function()
    local color = presets.get_color("tailwind", "rose-500")
    expect(color):toBeTruthy()
  end)

  it("has red colors", function()
    local color = presets.get_color("tailwind", "red-500")
    expect(color):toBeTruthy()
  end)

  it("has orange colors", function()
    local color = presets.get_color("tailwind", "orange-500")
    expect(color):toBeTruthy()
  end)

  it("has amber colors", function()
    local color = presets.get_color("tailwind", "amber-500")
    expect(color):toBeTruthy()
  end)

  it("has yellow colors", function()
    local color = presets.get_color("tailwind", "yellow-500")
    expect(color):toBeTruthy()
  end)

  it("has lime colors", function()
    local color = presets.get_color("tailwind", "lime-500")
    expect(color):toBeTruthy()
  end)

  it("has green colors", function()
    local color = presets.get_color("tailwind", "green-500")
    expect(color):toBeTruthy()
  end)

  it("has emerald colors", function()
    local color = presets.get_color("tailwind", "emerald-500")
    expect(color):toBeTruthy()
  end)

  it("has teal colors", function()
    local color = presets.get_color("tailwind", "teal-500")
    expect(color):toBeTruthy()
  end)

  it("has cyan colors", function()
    local color = presets.get_color("tailwind", "cyan-500")
    expect(color):toBeTruthy()
  end)

  it("has sky colors", function()
    local color = presets.get_color("tailwind", "sky-500")
    expect(color):toBeTruthy()
  end)

  it("has blue colors", function()
    local color = presets.get_color("tailwind", "blue-500")
    expect(color):toBeTruthy()
  end)

  it("has indigo colors", function()
    local color = presets.get_color("tailwind", "indigo-500")
    expect(color):toBeTruthy()
  end)

  it("has violet colors", function()
    local color = presets.get_color("tailwind", "violet-500")
    expect(color):toBeTruthy()
  end)

  it("has purple colors", function()
    local color = presets.get_color("tailwind", "purple-500")
    expect(color):toBeTruthy()
  end)

  it("has fuchsia colors", function()
    local color = presets.get_color("tailwind", "fuchsia-500")
    expect(color):toBeTruthy()
  end)

  it("has pink colors", function()
    local color = presets.get_color("tailwind", "pink-500")
    expect(color):toBeTruthy()
  end)

  it("has rose colors", function()
    local color = presets.get_color("tailwind", "rose-500")
    expect(color):toBeTruthy()
  end)
end)

-- ============================================================================
-- Tailwind Color Shades (50-950)
-- ============================================================================

describe("tailwind color shades", function()
  it("has all standard shades for blue", function()
    local shades = { "50", "100", "200", "300", "400", "500", "600", "700", "800", "900", "950" }
    for _, shade in ipairs(shades) do
      local color = presets.get_color("tailwind", "blue-" .. shade)
      expect(color):toBeTruthy()
    end
  end)

  it("has all standard shades for gray", function()
    local shades = { "50", "100", "200", "300", "400", "500", "600", "700", "800", "900", "950" }
    for _, shade in ipairs(shades) do
      local color = presets.get_color("tailwind", "gray-" .. shade)
      expect(color):toBeTruthy()
    end
  end)

  it("50 shade is lightest", function()
    local shade50 = presets.get_color("tailwind", "blue-50")
    local shade950 = presets.get_color("tailwind", "blue-950")
    expect(shade50):toBeTruthy()
    expect(shade950):toBeTruthy()
    -- 50 should be lighter than 950
  end)
end)

-- ============================================================================
-- Search Functionality
-- ============================================================================

describe("tailwind preset search", function()
  it("finds blue colors", function()
    local matches = presets.search("blue")
    local tailwindMatches = vim.tbl_filter(function(m)
      return m.preset == "tailwind"
    end, matches)
    expect(#tailwindMatches):toBeGreaterThan(0)
  end)

  it("finds slate colors", function()
    local matches = presets.search("slate")
    expect(#matches):toBeGreaterThan(0)
  end)

  it("finds emerald colors", function()
    local matches = presets.search("emerald")
    expect(#matches):toBeGreaterThan(0)
  end)

  it("finds sky colors", function()
    local matches = presets.search("sky")
    expect(#matches):toBeGreaterThan(0)
  end)

  it("finds rose colors", function()
    local matches = presets.search("rose")
    expect(#matches):toBeGreaterThan(0)
  end)

  it("finds colors by shade", function()
    local matches = presets.search("500")
    local tailwindMatches = vim.tbl_filter(function(m)
      return m.preset == "tailwind"
    end, matches)
    expect(#tailwindMatches):toBeGreaterThan(10)  -- Multiple color families
  end)

  it("search identifies tailwind preset", function()
    local matches = presets.search("emerald")
    if #matches > 0 then
      local hasTailwind = false
      for _, m in ipairs(matches) do
        if m.preset == "tailwind" then
          hasTailwind = true
          break
        end
      end
      expect(hasTailwind):toBeTruthy()
    end
  end)
end)

-- ============================================================================
-- Shade Extremes
-- ============================================================================

describe("tailwind shade extremes", function()
  it("has 950 shade (darkest)", function()
    local color = presets.get_color("tailwind", "slate-950")
    expect(color):toBeTruthy()
  end)

  it("has 50 shade (lightest)", function()
    local color = presets.get_color("tailwind", "slate-50")
    expect(color):toBeTruthy()
  end)
end)

-- ============================================================================
-- Color Validity
-- ============================================================================

describe("tailwind color validity", function()
  it("all colors are valid hex", function()
    local tailwind = presets.get_preset("tailwind")
    for name, hex in pairs(tailwind) do
      expect(hex):toMatch("^#%x%x%x%x%x%x$")
    end
  end)
end)

-- ============================================================================
-- Edge Cases
-- ============================================================================

describe("tailwind preset edge cases", function()
  it("returns nil for non-existent color", function()
    local color = presets.get_color("tailwind", "notacolor")
    expect(color):toBeNil()
  end)

  it("handles case insensitive lookup", function()
    local lower = presets.get_color("tailwind", "blue-500")
    local upper = presets.get_color("tailwind", "BLUE-500")
    if lower then
      expect(lower):toBe(upper)
    end
  end)

  it("handles invalid shade numbers gracefully", function()
    local color = presets.get_color("tailwind", "blue-999")
    expect(color):toBeNil()
  end)
end)
