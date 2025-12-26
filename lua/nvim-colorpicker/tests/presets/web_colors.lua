---@brief Tests for web color presets

local framework = require('nvim-colorpicker.tests.framework')
local describe, it, expect = framework.describe, framework.it, framework.expect

local presets = require('nvim-colorpicker.presets')

-- ============================================================================
-- Web Preset Availability
-- ============================================================================

describe("web preset existence", function()
  it("has web preset available", function()
    local names = presets.get_preset_names()
    expect(names):toContain("web")
  end)

  it("can get web preset", function()
    local web = presets.get_preset("web")
    expect(web):toBeTruthy()
    expect(type(web)):toBe("table")
  end)

  it("web preset has colors", function()
    local web = presets.get_preset("web")
    local count = 0
    for _ in pairs(web) do count = count + 1 end
    expect(count):toBeGreaterThan(100)  -- Should have 140+ colors
  end)
end)

-- ============================================================================
-- Primary Colors
-- ============================================================================

describe("web primary colors", function()
  it("has red", function()
    local color = presets.get_color("web", "red")
    expect(color):toBeTruthy()
    expect(color:lower()):toBe("#ff0000")
  end)

  it("has green", function()
    local color = presets.get_color("web", "green")
    expect(color):toBeTruthy()
    -- Web green is actually #008000, not #00ff00
    expect(color:lower()):toBe("#008000")
  end)

  it("has blue", function()
    local color = presets.get_color("web", "blue")
    expect(color):toBeTruthy()
    expect(color:lower()):toBe("#0000ff")
  end)

  it("has lime (bright green)", function()
    local color = presets.get_color("web", "lime")
    expect(color):toBeTruthy()
    expect(color:lower()):toBe("#00ff00")
  end)
end)

-- ============================================================================
-- Common Named Colors
-- ============================================================================

describe("web common colors", function()
  it("has white", function()
    local color = presets.get_color("web", "white")
    expect(color:lower()):toBe("#ffffff")
  end)

  it("has black", function()
    local color = presets.get_color("web", "black")
    expect(color:lower()):toBe("#000000")
  end)

  it("has gray", function()
    local color = presets.get_color("web", "gray")
    expect(color):toBeTruthy()
  end)

  it("has grey (British spelling)", function()
    local color = presets.get_color("web", "grey")
    expect(color):toBeTruthy()
  end)

  it("has cyan", function()
    local color = presets.get_color("web", "cyan")
    expect(color:lower()):toBe("#00ffff")
  end)

  it("has magenta", function()
    local color = presets.get_color("web", "magenta")
    expect(color:lower()):toBe("#ff00ff")
  end)

  it("has yellow", function()
    local color = presets.get_color("web", "yellow")
    expect(color:lower()):toBe("#ffff00")
  end)

  it("has orange", function()
    local color = presets.get_color("web", "orange")
    expect(color):toBeTruthy()
  end)

  it("has purple", function()
    local color = presets.get_color("web", "purple")
    expect(color):toBeTruthy()
  end)

  it("has pink", function()
    local color = presets.get_color("web", "pink")
    expect(color):toBeTruthy()
  end)

  it("has brown", function()
    local color = presets.get_color("web", "brown")
    expect(color):toBeTruthy()
  end)
end)

-- ============================================================================
-- Extended Colors
-- ============================================================================

describe("web extended colors", function()
  it("has aliceblue", function()
    local color = presets.get_color("web", "aliceblue")
    expect(color):toBeTruthy()
  end)

  it("has coral", function()
    local color = presets.get_color("web", "coral")
    expect(color):toBeTruthy()
  end)

  it("has crimson", function()
    local color = presets.get_color("web", "crimson")
    expect(color):toBeTruthy()
  end)

  it("has darkblue", function()
    local color = presets.get_color("web", "darkblue")
    expect(color):toBeTruthy()
  end)

  it("has lightgray", function()
    local color = presets.get_color("web", "lightgray")
    expect(color):toBeTruthy()
  end)

  it("has navy", function()
    local color = presets.get_color("web", "navy")
    expect(color):toBeTruthy()
  end)

  it("has olive", function()
    local color = presets.get_color("web", "olive")
    expect(color):toBeTruthy()
  end)

  it("has teal", function()
    local color = presets.get_color("web", "teal")
    expect(color):toBeTruthy()
  end)

  it("has turquoise", function()
    local color = presets.get_color("web", "turquoise")
    expect(color):toBeTruthy()
  end)

  it("has violet", function()
    local color = presets.get_color("web", "violet")
    expect(color):toBeTruthy()
  end)
end)

-- ============================================================================
-- Search Functionality
-- ============================================================================

describe("web preset search", function()
  it("finds colors by name", function()
    local matches = presets.search("blue")
    expect(#matches):toBeGreaterThan(0)
  end)

  it("finds multiple blue variants", function()
    local matches = presets.search("blue")
    -- Should find blue, darkblue, lightblue, etc.
    expect(#matches):toBeGreaterThan(5)
  end)

  it("finds red variants", function()
    local matches = presets.search("red")
    expect(#matches):toBeGreaterThan(0)
  end)

  it("search is case insensitive", function()
    local lower = presets.search("blue")
    local upper = presets.search("BLUE")
    expect(#lower):toBe(#upper)
  end)

  it("returns empty for no match", function()
    local matches = presets.search("xyznotacolor123")
    expect(#matches):toBe(0)
  end)

  it("search results include preset name", function()
    local matches = presets.search("red")
    if #matches > 0 then
      expect(matches[1].preset):toBeTruthy()
    end
  end)

  it("search results include hex value", function()
    local matches = presets.search("red")
    if #matches > 0 then
      expect(matches[1].hex):toBeTruthy()
      expect(matches[1].hex):toMatch("^#")
    end
  end)
end)

-- ============================================================================
-- Edge Cases
-- ============================================================================

describe("web preset edge cases", function()
  it("returns nil for non-existent color", function()
    local color = presets.get_color("web", "notacolor")
    expect(color):toBeNil()
  end)

  it("handles case insensitive lookup", function()
    local lower = presets.get_color("web", "red")
    local upper = presets.get_color("web", "RED")
    local mixed = presets.get_color("web", "Red")
    -- All should return the same color
    expect(lower):toBe(upper)
    expect(lower):toBe(mixed)
  end)

  it("all colors are valid hex", function()
    local web = presets.get_preset("web")
    for name, hex in pairs(web) do
      expect(hex):toMatch("^#%x%x%x%x%x%x$")
    end
  end)
end)
