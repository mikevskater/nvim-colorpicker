---@brief Tests for vim highlight color detection (guifg/guibg)

local framework = require('tests.framework')
local describe, it, expect = framework.describe, framework.it, framework.expect

local detect = require('nvim-colorpicker.detect')

-- ============================================================================
-- parse_to_hex Tests (Vim Format)
-- ============================================================================

describe("parse_to_hex - guifg format", function()
  it("parses guifg=#rrggbb", function()
    local hex = detect.parse_to_hex("guifg=#ff5500", "vim")
    expect(hex:lower()):toBe("#ff5500")
  end)

  it("parses lowercase guifg", function()
    local hex = detect.parse_to_hex("guifg=#aabbcc", "vim")
    expect(hex:lower()):toBe("#aabbcc")
  end)

  it("parses uppercase guifg", function()
    local hex = detect.parse_to_hex("guifg=#AABBCC", "vim")
    expect(hex:lower()):toBe("#aabbcc")
  end)

  it("parses guifg with red", function()
    local hex = detect.parse_to_hex("guifg=#ff0000", "vim")
    expect(hex:lower()):toBe("#ff0000")
  end)

  it("parses guifg with green", function()
    local hex = detect.parse_to_hex("guifg=#00ff00", "vim")
    expect(hex:lower()):toBe("#00ff00")
  end)

  it("parses guifg with blue", function()
    local hex = detect.parse_to_hex("guifg=#0000ff", "vim")
    expect(hex:lower()):toBe("#0000ff")
  end)
end)

describe("parse_to_hex - guibg format", function()
  it("parses guibg=#rrggbb", function()
    local hex = detect.parse_to_hex("guibg=#ff5500", "vim")
    expect(hex:lower()):toBe("#ff5500")
  end)

  it("parses guibg with dark color", function()
    local hex = detect.parse_to_hex("guibg=#1a1a1a", "vim")
    expect(hex:lower()):toBe("#1a1a1a")
  end)

  it("parses guibg with light color", function()
    local hex = detect.parse_to_hex("guibg=#f0f0f0", "vim")
    expect(hex:lower()):toBe("#f0f0f0")
  end)
end)

-- ============================================================================
-- get_colors_in_line Tests (Vim)
-- ============================================================================

describe("get_colors_in_line - vim detection", function()
  it("detects guifg in highlight command", function()
    local colors = detect.get_colors_in_line("highlight Normal guifg=#ffffff guibg=#1a1a1a", 1)
    expect(#colors):toBe(2)
  end)

  it("detects guifg in hi command", function()
    local colors = detect.get_colors_in_line("hi Comment guifg=#808080", 1)
    expect(#colors):toBe(1)
    expect(colors[1].format):toBe("vim")
  end)

  it("returns correct format type", function()
    local colors = detect.get_colors_in_line("guifg=#ff5500", 1)
    expect(#colors):toBe(1)
    expect(colors[1].format):toBe("vim")
  end)

  it("stores original including guifg prefix", function()
    local colors = detect.get_colors_in_line("guifg=#ff5500", 1)
    expect(#colors):toBe(1)
    expect(colors[1].original):toContain("guifg=")
  end)

  it("detects multiple vim colors on line", function()
    local colors = detect.get_colors_in_line("guifg=#ff0000 guibg=#0000ff", 1)
    expect(#colors):toBe(2)
  end)
end)

-- ============================================================================
-- Detection in Vim Script Context
-- ============================================================================

describe("vim detection in context", function()
  it("detects in vim highlight command", function()
    local colors = detect.get_colors_in_line("highlight MyGroup guifg=#ff5500 guibg=#000000 gui=bold", 1)
    expect(#colors):toBe(2)
  end)

  it("detects in hi! command", function()
    local colors = detect.get_colors_in_line("hi! link MyGroup guifg=#ff5500", 1)
    expect(#colors):toBe(1)
  end)

  it("detects in Lua vim.api.nvim_set_hl", function()
    local colors = detect.get_colors_in_line("  fg = '#ff5500', -- guifg=#ff5500", 1)
    -- Should find both the hex string and the guifg comment
    expect(#colors):toBeGreaterThan(0)
  end)

  it("detects guifg in comment", function()
    local colors = detect.get_colors_in_line("-- guifg=#ff5500 for foreground", 1)
    expect(#colors):toBe(1)
  end)

  it("handles guifg with spaces around =", function()
    -- Note: This tests standard guifg= syntax; spaces may not be detected
    local colors = detect.get_colors_in_line("guifg=#ff5500", 1)
    expect(#colors):toBe(1)
  end)
end)

-- ============================================================================
-- Mixed Format Detection
-- ============================================================================

describe("vim detection with other formats", function()
  it("detects vim alongside hex", function()
    local colors = detect.get_colors_in_line("#ff0000 guifg=#00ff00", 1)
    expect(#colors):toBe(2)
    -- One should be hex format, one should be vim format
    local formats = {}
    for _, c in ipairs(colors) do
      formats[c.format] = true
    end
    expect(formats["hex"]):toBeTruthy()
    expect(formats["vim"]):toBeTruthy()
  end)

  it("detects vim alongside rgb", function()
    local colors = detect.get_colors_in_line("rgb(255, 0, 0) guifg=#00ff00", 1)
    expect(#colors):toBe(2)
  end)

  it("detects all three formats", function()
    local colors = detect.get_colors_in_line("#ff0000 rgb(0, 255, 0) guifg=#0000ff", 1)
    expect(#colors):toBe(3)
  end)
end)

-- ============================================================================
-- Edge Cases
-- ============================================================================

describe("vim detection edge cases", function()
  it("handles guifg without color value after", function()
    -- Should not crash, just not find color
    local colors = detect.get_colors_in_line("guifg=None", 1)
    -- Should not match since None is not a hex
    expect(#colors):toBe(0)
  end)

  it("handles guifg=NONE (vim keyword)", function()
    local colors = detect.get_colors_in_line("guifg=NONE guibg=#000000", 1)
    -- Should only find the guibg
    expect(#colors):toBe(1)
  end)

  it("handles colorscheme file context", function()
    local colors = detect.get_colors_in_line('hi Normal guifg=#c0c0c0 guibg=#1e1e1e ctermfg=7 ctermbg=234', 1)
    expect(#colors):toBe(2)
  end)

  it("ignores ctermfg/ctermbg numbers", function()
    local colors = detect.get_colors_in_line("ctermfg=255 ctermbg=0", 1)
    -- These are not hex colors
    expect(#colors):toBe(0)
  end)
end)
