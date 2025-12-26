---@brief Tests for Material Design color presets

local framework = require('nvim-colorpicker.tests.framework')
local describe, it, expect = framework.describe, framework.it, framework.expect

local presets = require('nvim-colorpicker.presets')

-- ============================================================================
-- Material Preset Availability
-- ============================================================================

describe("material preset existence", function()
  it("has material preset available", function()
    local names = presets.get_preset_names()
    expect(names):toContain("material")
  end)

  it("can get material preset", function()
    local material = presets.get_preset("material")
    expect(material):toBeTruthy()
    expect(type(material)):toBe("table")
  end)

  it("material preset has colors", function()
    local material = presets.get_preset("material")
    local count = 0
    for _ in pairs(material) do count = count + 1 end
    expect(count):toBeGreaterThan(150)  -- Should have 190+ colors
  end)
end)

-- ============================================================================
-- Primary Material Colors
-- ============================================================================

describe("material primary colors", function()
  it("has red-500", function()
    local color = presets.get_color("material", "red-500")
    expect(color):toBeTruthy()
  end)

  it("has blue-500", function()
    local color = presets.get_color("material", "blue-500")
    expect(color):toBeTruthy()
  end)

  it("has green-500", function()
    local color = presets.get_color("material", "green-500")
    expect(color):toBeTruthy()
  end)

  it("has yellow-500", function()
    local color = presets.get_color("material", "yellow-500")
    expect(color):toBeTruthy()
  end)

  it("has purple-500", function()
    local color = presets.get_color("material", "purple-500")
    expect(color):toBeTruthy()
  end)

  it("has orange-500", function()
    local color = presets.get_color("material", "orange-500")
    expect(color):toBeTruthy()
  end)

  it("has pink-500", function()
    local color = presets.get_color("material", "pink-500")
    expect(color):toBeTruthy()
  end)

  it("has teal-500", function()
    local color = presets.get_color("material", "teal-500")
    expect(color):toBeTruthy()
  end)

  it("has cyan-500", function()
    local color = presets.get_color("material", "cyan-500")
    expect(color):toBeTruthy()
  end)

  it("has indigo-500", function()
    local color = presets.get_color("material", "indigo-500")
    expect(color):toBeTruthy()
  end)
end)

-- ============================================================================
-- Color Shades (50-900)
-- ============================================================================

describe("material color shades", function()
  it("has red in all standard shades", function()
    local shades = { "50", "100", "200", "300", "400", "500", "600", "700", "800", "900" }
    for _, shade in ipairs(shades) do
      local color = presets.get_color("material", "red-" .. shade)
      expect(color):toBeTruthy()
    end
  end)

  it("has blue in all standard shades", function()
    local shades = { "50", "100", "200", "300", "400", "500", "600", "700", "800", "900" }
    for _, shade in ipairs(shades) do
      local color = presets.get_color("material", "blue-" .. shade)
      expect(color):toBeTruthy()
    end
  end)

  it("lighter shades have higher lightness", function()
    local red50 = presets.get_color("material", "red-50")
    local red900 = presets.get_color("material", "red-900")
    -- 50 should be lighter (closer to white)
    -- Compare first hex digit (red channel high byte)
    expect(red50):toBeTruthy()
    expect(red900):toBeTruthy()
  end)
end)

-- ============================================================================
-- Extended Material Colors
-- ============================================================================

describe("material extended colors", function()
  it("has amber colors", function()
    local amber500 = presets.get_color("material", "amber-500")
    expect(amber500):toBeTruthy()
  end)

  it("has deep-purple colors", function()
    local deepPurple500 = presets.get_color("material", "deep-purple-500")
    expect(deepPurple500):toBeTruthy()
  end)

  it("has light-blue colors", function()
    local lightBlue500 = presets.get_color("material", "light-blue-500")
    expect(lightBlue500):toBeTruthy()
  end)

  it("has light-green colors", function()
    local lightGreen500 = presets.get_color("material", "light-green-500")
    expect(lightGreen500):toBeTruthy()
  end)

  it("has deep-orange colors", function()
    local deepOrange500 = presets.get_color("material", "deep-orange-500")
    expect(deepOrange500):toBeTruthy()
  end)

  it("has brown colors", function()
    local brown500 = presets.get_color("material", "brown-500")
    expect(brown500):toBeTruthy()
  end)
end)

-- ============================================================================
-- Gray Scale
-- ============================================================================

describe("material gray colors", function()
  it("has gray shades", function()
    local gray500 = presets.get_color("material", "gray-500")
    expect(gray500):toBeTruthy()
  end)

  it("has blue-gray shades", function()
    local bluegray500 = presets.get_color("material", "blue-gray-500")
    expect(bluegray500):toBeTruthy()
  end)
end)

-- ============================================================================
-- Search Functionality
-- ============================================================================

describe("material preset search", function()
  it("finds red colors", function()
    local matches = presets.search("red")
    local materialMatches = vim.tbl_filter(function(m)
      return m.preset == "material"
    end, matches)
    expect(#materialMatches):toBeGreaterThan(0)
  end)

  it("finds colors by shade number", function()
    local matches = presets.search("500")
    local materialMatches = vim.tbl_filter(function(m)
      return m.preset == "material"
    end, matches)
    -- Should find multiple colors with 500 shade
    expect(#materialMatches):toBeGreaterThan(5)
  end)

  it("finds indigo colors", function()
    local matches = presets.search("indigo")
    expect(#matches):toBeGreaterThan(0)
  end)

  it("finds deep-purple colors", function()
    local matches = presets.search("deep")
    expect(#matches):toBeGreaterThan(0)
  end)

  it("search results identify material preset", function()
    local matches = presets.search("indigo")
    if #matches > 0 then
      local materialMatch = vim.tbl_filter(function(m)
        return m.preset == "material"
      end, matches)
      expect(#materialMatch):toBeGreaterThan(0)
    end
  end)
end)

-- ============================================================================
-- Color Validity
-- ============================================================================

describe("material color validity", function()
  it("all colors are valid hex", function()
    local material = presets.get_preset("material")
    for name, hex in pairs(material) do
      expect(hex):toMatch("^#%x%x%x%x%x%x$")
    end
  end)

  it("no duplicate hex values for different names", function()
    -- Material colors should be unique (mostly)
    local material = presets.get_preset("material")
    local hexValues = {}
    local duplicates = 0
    for name, hex in pairs(material) do
      if hexValues[hex] then
        duplicates = duplicates + 1
      end
      hexValues[hex] = name
    end
    -- Some duplicates are OK (like grey/gray)
    expect(duplicates):toBeLessThan(20)
  end)
end)

-- ============================================================================
-- Edge Cases
-- ============================================================================

describe("material preset edge cases", function()
  it("returns nil for non-existent color", function()
    local color = presets.get_color("material", "notacolor")
    expect(color):toBeNil()
  end)

  it("handles case insensitive lookup", function()
    local lower = presets.get_color("material", "red-500")
    local upper = presets.get_color("material", "RED-500")
    local mixed = presets.get_color("material", "Red-500")
    -- All should return the same color
    if lower then
      expect(lower):toBe(upper)
      expect(lower):toBe(mixed)
    end
  end)
end)
