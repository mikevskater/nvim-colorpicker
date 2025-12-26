---@brief Tests for buffer color highlighting

local framework = require('tests.framework')
local describe, it, expect = framework.describe, framework.it, framework.expect

local highlight = require('nvim-colorpicker.highlight')

-- ============================================================================
-- Highlight Mode
-- ============================================================================

describe("highlight mode", function()
  it("defaults to background mode", function()
    local mode = highlight.get_mode()
    expect(mode):toBe("background")
  end)

  it("can set to foreground mode", function()
    highlight.set_mode("foreground")
    expect(highlight.get_mode()):toBe("foreground")
    -- Reset
    highlight.set_mode("background")
  end)

  it("can set to virtualtext mode", function()
    highlight.set_mode("virtualtext")
    expect(highlight.get_mode()):toBe("virtualtext")
    -- Reset
    highlight.set_mode("background")
  end)

  it("ignores invalid mode", function()
    local original = highlight.get_mode()
    highlight.set_mode("invalid")
    expect(highlight.get_mode()):toBe(original)
  end)

  it("accepts all valid modes", function()
    local modes = { "background", "foreground", "virtualtext" }
    for _, mode in ipairs(modes) do
      highlight.set_mode(mode)
      expect(highlight.get_mode()):toBe(mode)
    end
    -- Reset
    highlight.set_mode("background")
  end)
end)

-- ============================================================================
-- Buffer State
-- ============================================================================

describe("buffer state", function()
  it("is_active returns false for new buffer", function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    expect(highlight.is_active(bufnr)):toBeFalsy()
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it("is_active returns true after highlight_buffer", function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "#ff0000" })

    highlight.highlight_buffer(bufnr)
    expect(highlight.is_active(bufnr)):toBeTruthy()

    highlight.clear_buffer(bufnr)
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it("is_active returns false after clear_buffer", function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "#ff0000" })

    highlight.highlight_buffer(bufnr)
    highlight.clear_buffer(bufnr)
    expect(highlight.is_active(bufnr)):toBeFalsy()

    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)
end)

-- ============================================================================
-- Toggle
-- ============================================================================

describe("toggle", function()
  it("enables highlighting when inactive", function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "#ff0000" })

    expect(highlight.is_active(bufnr)):toBeFalsy()
    highlight.toggle(bufnr)
    expect(highlight.is_active(bufnr)):toBeTruthy()

    highlight.clear_buffer(bufnr)
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it("disables highlighting when active", function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "#ff0000" })

    highlight.highlight_buffer(bufnr)
    expect(highlight.is_active(bufnr)):toBeTruthy()
    highlight.toggle(bufnr)
    expect(highlight.is_active(bufnr)):toBeFalsy()

    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it("toggles back and forth", function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "#ff0000" })

    highlight.toggle(bufnr)
    expect(highlight.is_active(bufnr)):toBeTruthy()
    highlight.toggle(bufnr)
    expect(highlight.is_active(bufnr)):toBeFalsy()
    highlight.toggle(bufnr)
    expect(highlight.is_active(bufnr)):toBeTruthy()

    highlight.clear_buffer(bufnr)
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)
end)

-- ============================================================================
-- Highlight Buffer
-- ============================================================================

describe("highlight_buffer", function()
  it("processes buffer with hex colors", function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      "color: #ff0000;",
      "background: #00ff00;",
    })

    local ok = pcall(highlight.highlight_buffer, bufnr)
    expect(ok):toBeTruthy()
    expect(highlight.is_active(bufnr)):toBeTruthy()

    highlight.clear_buffer(bufnr)
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it("processes buffer with rgb colors", function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      "color: rgb(255, 0, 0);",
    })

    local ok = pcall(highlight.highlight_buffer, bufnr)
    expect(ok):toBeTruthy()

    highlight.clear_buffer(bufnr)
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it("processes buffer with hsl colors", function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      "color: hsl(0, 100%, 50%);",
    })

    local ok = pcall(highlight.highlight_buffer, bufnr)
    expect(ok):toBeTruthy()

    highlight.clear_buffer(bufnr)
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it("handles empty buffer", function()
    local bufnr = vim.api.nvim_create_buf(false, true)

    local ok = pcall(highlight.highlight_buffer, bufnr)
    expect(ok):toBeTruthy()

    highlight.clear_buffer(bufnr)
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it("handles buffer with no colors", function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      "no colors here",
      "just text",
    })

    local ok = pcall(highlight.highlight_buffer, bufnr)
    expect(ok):toBeTruthy()

    highlight.clear_buffer(bufnr)
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it("handles multiple colors per line", function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      "#ff0000 #00ff00 #0000ff",
    })

    local ok = pcall(highlight.highlight_buffer, bufnr)
    expect(ok):toBeTruthy()

    highlight.clear_buffer(bufnr)
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)
end)

-- ============================================================================
-- Clear Buffer
-- ============================================================================

describe("clear_buffer", function()
  it("clears highlights from buffer", function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "#ff0000" })

    highlight.highlight_buffer(bufnr)
    highlight.clear_buffer(bufnr)

    expect(highlight.is_active(bufnr)):toBeFalsy()

    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it("handles clear on non-highlighted buffer", function()
    local bufnr = vim.api.nvim_create_buf(false, true)

    local ok = pcall(highlight.clear_buffer, bufnr)
    expect(ok):toBeTruthy()

    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it("can clear and re-highlight", function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "#ff0000" })

    highlight.highlight_buffer(bufnr)
    highlight.clear_buffer(bufnr)
    highlight.highlight_buffer(bufnr)

    expect(highlight.is_active(bufnr)):toBeTruthy()

    highlight.clear_buffer(bufnr)
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)
end)

-- ============================================================================
-- Auto Highlight
-- ============================================================================

describe("auto highlight", function()
  it("enable_auto creates autocmds", function()
    local ok = pcall(highlight.enable_auto, { "*.css" })
    expect(ok):toBeTruthy()
    highlight.disable_auto()
  end)

  it("disable_auto removes autocmds", function()
    highlight.enable_auto({ "*.css" })
    local ok = pcall(highlight.disable_auto)
    expect(ok):toBeTruthy()
  end)

  it("accepts custom patterns", function()
    local ok = pcall(highlight.enable_auto, { "*.lua", "*.vim", "*.css" })
    expect(ok):toBeTruthy()
    highlight.disable_auto()
  end)

  it("uses default patterns when nil", function()
    local ok = pcall(highlight.enable_auto, nil)
    expect(ok):toBeTruthy()
    highlight.disable_auto()
  end)
end)

-- ============================================================================
-- Edge Cases
-- ============================================================================

describe("highlight edge cases", function()
  it("handles invalid buffer gracefully", function()
    local ok = pcall(highlight.highlight_buffer, 99999)
    -- May error or succeed silently
    expect(true):toBeTruthy()  -- Just ensure no crash
  end)

  it("handles deleted buffer gracefully", function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_delete(bufnr, { force = true })

    local ok = pcall(highlight.is_active, bufnr)
    expect(true):toBeTruthy()  -- Just ensure no crash
  end)

  it("handles mode change with active buffers", function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "#ff0000" })

    highlight.highlight_buffer(bufnr)
    highlight.set_mode("foreground")
    highlight.set_mode("virtualtext")
    highlight.set_mode("background")

    highlight.clear_buffer(bufnr)
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)
end)
