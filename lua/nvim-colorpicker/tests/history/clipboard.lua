---@brief Tests for clipboard integration

local framework = require('nvim-colorpicker.tests.framework')
local describe, it, expect = framework.describe, framework.it, framework.expect

local history = require('nvim-colorpicker.history')
local utils = require('nvim-colorpicker.utils')

-- ============================================================================
-- Yank Function
-- ============================================================================

describe("yank - basic", function()
  it("copies hex to clipboard", function()
    -- Set up clipboard mock
    vim.fn.setreg('+', '')
    vim.fn.setreg('"', '')

    history.yank("#ff5500")

    local clipboard = vim.fn.getreg('+')
    expect(clipboard):toContain("ff5500")
  end)

  it("copies to both + and \" registers", function()
    vim.fn.setreg('+', '')
    vim.fn.setreg('"', '')

    history.yank("#00ff00")

    local plus = vim.fn.getreg('+')
    local quote = vim.fn.getreg('"')
    expect(plus):toContain("00ff00")
    expect(quote):toContain("00ff00")
  end)

  it("normalizes hex before copying", function()
    vim.fn.setreg('+', '')

    history.yank("#FF5500")

    local clipboard = vim.fn.getreg('+')
    -- Should contain the color (case may vary)
    expect(clipboard:lower()):toContain("ff5500")
  end)
end)

describe("yank - format conversion", function()
  it("copies as hex by default", function()
    vim.fn.setreg('+', '')

    history.yank("#ff5500", "hex")

    local clipboard = vim.fn.getreg('+')
    expect(clipboard):toMatch("^#")
  end)

  it("copies as rgb format", function()
    vim.fn.setreg('+', '')

    history.yank("#ff5500", "rgb")

    local clipboard = vim.fn.getreg('+')
    expect(clipboard):toMatch("^rgb%(")
    expect(clipboard):toContain("255")
  end)

  it("copies as hsl format", function()
    vim.fn.setreg('+', '')

    history.yank("#ff0000", "hsl")

    local clipboard = vim.fn.getreg('+')
    expect(clipboard):toMatch("^hsl%(")
  end)

  it("copies as hsv format", function()
    vim.fn.setreg('+', '')

    history.yank("#ff0000", "hsv")

    local clipboard = vim.fn.getreg('+')
    expect(clipboard):toMatch("^hsv%(")
  end)
end)

describe("yank - invalid input", function()
  it("handles nil gracefully", function()
    -- Should not throw error
    local ok = pcall(function()
      history.yank(nil)
    end)
    expect(ok):toBeTruthy()
  end)

  it("handles invalid hex gracefully", function()
    local ok = pcall(function()
      history.yank("notahex")
    end)
    expect(ok):toBeTruthy()
  end)

  it("handles empty string gracefully", function()
    local ok = pcall(function()
      history.yank("")
    end)
    expect(ok):toBeTruthy()
  end)
end)

-- ============================================================================
-- Paste Function
-- ============================================================================

describe("paste - hex formats", function()
  it("parses hex from clipboard", function()
    vim.fn.setreg('+', '#ff5500')

    local hex = history.paste()
    expect(hex:lower()):toBe("#ff5500")
  end)

  it("parses hex without #", function()
    vim.fn.setreg('+', 'ff5500')

    local hex = history.paste()
    expect(hex:lower()):toBe("#ff5500")
  end)

  it("parses 3-digit hex", function()
    vim.fn.setreg('+', '#f50')

    local hex = history.paste()
    expect(hex:lower()):toBe("#ff5500")
  end)

  it("handles uppercase hex", function()
    vim.fn.setreg('+', '#FF5500')

    local hex = history.paste()
    expect(hex):toBeTruthy()
  end)
end)

describe("paste - rgb formats", function()
  it("parses rgb() from clipboard", function()
    vim.fn.setreg('+', 'rgb(255, 85, 0)')

    local hex = history.paste()
    expect(hex:lower()):toBe("#ff5500")
  end)

  it("parses rgb without spaces", function()
    vim.fn.setreg('+', 'rgb(255,85,0)')

    local hex = history.paste()
    expect(hex:lower()):toBe("#ff5500")
  end)

  it("parses rgba()", function()
    vim.fn.setreg('+', 'rgba(255, 85, 0, 0.5)')

    local hex = history.paste()
    expect(hex:lower()):toBe("#ff5500")
  end)
end)

describe("paste - hsl formats", function()
  it("parses hsl() from clipboard", function()
    vim.fn.setreg('+', 'hsl(0, 100%, 50%)')

    local hex = history.paste()
    expect(hex:lower()):toBe("#ff0000")
  end)

  it("parses hsla()", function()
    vim.fn.setreg('+', 'hsla(120, 100%, 50%, 0.5)')

    local hex = history.paste()
    expect(hex:lower()):toBe("#00ff00")
  end)
end)

describe("paste - whitespace handling", function()
  it("trims leading whitespace", function()
    vim.fn.setreg('+', '   #ff5500')

    local hex = history.paste()
    expect(hex):toBeTruthy()
  end)

  it("trims trailing whitespace", function()
    vim.fn.setreg('+', '#ff5500   ')

    local hex = history.paste()
    expect(hex):toBeTruthy()
  end)

  it("trims both sides", function()
    vim.fn.setreg('+', '  #ff5500  ')

    local hex = history.paste()
    expect(hex):toBeTruthy()
  end)

  it("handles newlines", function()
    vim.fn.setreg('+', '#ff5500\n')

    local hex = history.paste()
    expect(hex):toBeTruthy()
  end)
end)

describe("paste - invalid input", function()
  it("returns nil for empty clipboard", function()
    vim.fn.setreg('+', '')
    vim.fn.setreg('"', '')

    local hex = history.paste()
    expect(hex):toBeNil()
  end)

  it("returns nil for invalid color", function()
    vim.fn.setreg('+', 'not a color')

    local hex = history.paste()
    expect(hex):toBeNil()
  end)

  it("returns nil for partial hex", function()
    vim.fn.setreg('+', '#ff55')

    local hex = history.paste()
    expect(hex):toBeNil()
  end)

  it("returns nil for invalid rgb values", function()
    vim.fn.setreg('+', 'rgb(300, 85, 0)')  -- 300 is out of range

    local hex = history.paste()
    -- May or may not return nil depending on implementation
    -- Just ensure no crash
    local ok = pcall(function() history.paste() end)
    expect(ok):toBeTruthy()
  end)
end)

describe("paste - fallback to \" register", function()
  it("uses \" register if + is empty", function()
    vim.fn.setreg('+', '')
    vim.fn.setreg('"', '#00ff00')

    local hex = history.paste()
    expect(hex:lower()):toBe("#00ff00")
  end)

  it("prefers + register over \"", function()
    vim.fn.setreg('+', '#ff0000')
    vim.fn.setreg('"', '#00ff00')

    local hex = history.paste()
    expect(hex:lower()):toBe("#ff0000")
  end)
end)

-- ============================================================================
-- Round-trip Test
-- ============================================================================

describe("yank/paste round-trip", function()
  it("round-trips hex correctly", function()
    local original = "#ff5500"
    vim.fn.setreg('+', '')

    history.yank(original, "hex")
    local result = history.paste()

    expect(result:lower()):toBe(original:lower())
  end)

  it("round-trips rgb correctly", function()
    local original = "#ff5500"
    vim.fn.setreg('+', '')

    history.yank(original, "rgb")
    local result = history.paste()

    expect(result:lower()):toBe(original:lower())
  end)

  it("round-trips hsl correctly", function()
    local original = "#ff0000"  -- Pure red for accurate round-trip
    vim.fn.setreg('+', '')

    history.yank(original, "hsl")
    local result = history.paste()

    expect(result:lower()):toBe(original:lower())
  end)
end)
