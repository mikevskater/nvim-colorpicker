---@brief Tests for recent colors tracking

local framework = require('tests.framework')
local describe, it, expect = framework.describe, framework.it, framework.expect

local history = require('nvim-colorpicker.history')

-- ============================================================================
-- Setup/Teardown
-- ============================================================================

-- Clear history before each test suite
history.clear_recent()

-- ============================================================================
-- Basic Recent Colors
-- ============================================================================

describe("add_recent", function()
  -- Clear before this suite
  history.clear_recent()

  it("adds color to recent list", function()
    history.clear_recent()
    history.add_recent("#ff5500")
    local recent = history.get_recent()
    expect(#recent):toBe(1)
    expect(recent[1]:lower()):toBe("#ff5500")
  end)

  it("adds multiple colors", function()
    history.clear_recent()
    history.add_recent("#ff0000")
    history.add_recent("#00ff00")
    history.add_recent("#0000ff")
    local recent = history.get_recent()
    expect(#recent):toBe(3)
  end)

  it("most recent color is first", function()
    history.clear_recent()
    history.add_recent("#ff0000")
    history.add_recent("#00ff00")
    local recent = history.get_recent()
    expect(recent[1]:lower()):toBe("#00ff00")
    expect(recent[2]:lower()):toBe("#ff0000")
  end)

  it("normalizes hex to lowercase", function()
    history.clear_recent()
    history.add_recent("#FF5500")
    local recent = history.get_recent()
    expect(recent[1]):toBe("#ff5500")
  end)

  it("adds # prefix if missing", function()
    history.clear_recent()
    history.add_recent("ff5500")
    local recent = history.get_recent()
    expect(recent[1]):toMatch("^#")
  end)
end)

-- ============================================================================
-- Duplicate Handling
-- ============================================================================

describe("duplicate handling", function()
  it("moves duplicate to front", function()
    history.clear_recent()
    history.add_recent("#ff0000")
    history.add_recent("#00ff00")
    history.add_recent("#ff0000")  -- Add red again
    local recent = history.get_recent()
    expect(#recent):toBe(2)  -- Should not duplicate
    expect(recent[1]:lower()):toBe("#ff0000")  -- Red should be first now
  end)

  it("handles case-insensitive duplicates", function()
    history.clear_recent()
    history.add_recent("#ff5500")
    history.add_recent("#FF5500")
    local recent = history.get_recent()
    expect(#recent):toBe(1)  -- Should not duplicate
  end)

  it("deduplicates across multiple adds", function()
    history.clear_recent()
    history.add_recent("#aabbcc")
    history.add_recent("#ddeeff")
    history.add_recent("#aabbcc")
    history.add_recent("#112233")
    history.add_recent("#ddeeff")
    local recent = history.get_recent()
    expect(#recent):toBe(3)  -- Only unique colors
  end)
end)

-- ============================================================================
-- Maximum Limit
-- ============================================================================

describe("max recent limit", function()
  it("respects default max limit", function()
    history.clear_recent()
    -- Add more than default max (10)
    for i = 1, 15 do
      history.add_recent(string.format("#%02x%02x%02x", i, i, i))
    end
    local recent = history.get_recent()
    expect(#recent):toBeLessThan(16)
  end)

  it("oldest colors are removed when limit exceeded", function()
    history.clear_recent()
    history.set_max_recent(3)
    history.add_recent("#111111")
    history.add_recent("#222222")
    history.add_recent("#333333")
    history.add_recent("#444444")  -- Should push out #111111
    local recent = history.get_recent()
    expect(#recent):toBe(3)
    -- #111111 should be gone
    local has111 = false
    for _, c in ipairs(recent) do
      if c:lower() == "#111111" then has111 = true end
    end
    expect(has111):toBeFalsy()
    -- Reset max
    history.set_max_recent(10)
  end)

  it("can change max limit", function()
    history.clear_recent()
    history.set_max_recent(5)
    for i = 1, 10 do
      history.add_recent(string.format("#%02x%02x%02x", i*10, i*10, i*10))
    end
    local recent = history.get_recent()
    expect(#recent):toBe(5)
    -- Reset max
    history.set_max_recent(10)
  end)
end)

-- ============================================================================
-- Get Recent
-- ============================================================================

describe("get_recent", function()
  it("returns empty array when no history", function()
    history.clear_recent()
    local recent = history.get_recent()
    expect(#recent):toBe(0)
  end)

  it("returns limited count when specified", function()
    history.clear_recent()
    history.add_recent("#ff0000")
    history.add_recent("#00ff00")
    history.add_recent("#0000ff")
    history.add_recent("#ffff00")
    local recent = history.get_recent(2)
    expect(#recent):toBe(2)
  end)

  it("returns all if count exceeds actual", function()
    history.clear_recent()
    history.add_recent("#ff0000")
    history.add_recent("#00ff00")
    local recent = history.get_recent(10)
    expect(#recent):toBe(2)
  end)

  it("returns copy, not reference", function()
    history.clear_recent()
    history.add_recent("#ff0000")
    local recent1 = history.get_recent()
    local recent2 = history.get_recent()
    expect(recent1):never():toBe(recent2)  -- Different table references
  end)
end)

-- ============================================================================
-- Get Recent Count
-- ============================================================================

describe("get_recent_count", function()
  it("returns 0 when empty", function()
    history.clear_recent()
    expect(history.get_recent_count()):toBe(0)
  end)

  it("returns correct count", function()
    history.clear_recent()
    history.add_recent("#ff0000")
    history.add_recent("#00ff00")
    history.add_recent("#0000ff")
    expect(history.get_recent_count()):toBe(3)
  end)

  it("updates after clear", function()
    history.clear_recent()
    history.add_recent("#ff0000")
    history.add_recent("#00ff00")
    expect(history.get_recent_count()):toBe(2)
    history.clear_recent()
    expect(history.get_recent_count()):toBe(0)
  end)
end)

-- ============================================================================
-- Clear Recent
-- ============================================================================

describe("clear_recent", function()
  it("removes all recent colors", function()
    history.add_recent("#ff0000")
    history.add_recent("#00ff00")
    history.clear_recent()
    local recent = history.get_recent()
    expect(#recent):toBe(0)
  end)

  it("can add colors after clear", function()
    history.clear_recent()
    history.add_recent("#ff0000")
    history.clear_recent()
    history.add_recent("#00ff00")
    local recent = history.get_recent()
    expect(#recent):toBe(1)
    expect(recent[1]:lower()):toBe("#00ff00")
  end)
end)

-- ============================================================================
-- Invalid Input Handling
-- ============================================================================

describe("invalid input handling", function()
  it("ignores nil input", function()
    history.clear_recent()
    history.add_recent(nil)
    expect(history.get_recent_count()):toBe(0)
  end)

  it("ignores empty string", function()
    history.clear_recent()
    history.add_recent("")
    expect(history.get_recent_count()):toBe(0)
  end)

  it("ignores invalid hex", function()
    history.clear_recent()
    history.add_recent("notahex")
    expect(history.get_recent_count()):toBe(0)
  end)

  it("ignores partial hex", function()
    history.clear_recent()
    history.add_recent("#ff55")
    expect(history.get_recent_count()):toBe(0)
  end)
end)

-- ============================================================================
-- Persistence Data
-- ============================================================================

describe("persistence data", function()
  it("get_persist_data returns recent colors", function()
    history.clear_recent()
    history.add_recent("#ff0000")
    history.add_recent("#00ff00")
    local data = history.get_persist_data()
    expect(data):toBeTruthy()
    expect(data.recent):toBeTruthy()
    expect(#data.recent):toBe(2)
  end)

  it("restore_persist_data restores colors", function()
    history.clear_recent()
    local data = {
      recent = { "#ff0000", "#00ff00", "#0000ff" }
    }
    history.restore_persist_data(data)
    local recent = history.get_recent()
    expect(#recent):toBe(3)
  end)

  it("restore handles empty data", function()
    history.clear_recent()
    history.restore_persist_data({})
    expect(history.get_recent_count()):toBe(0)
  end)

  it("restore handles nil data", function()
    history.clear_recent()
    history.restore_persist_data(nil)
    expect(history.get_recent_count()):toBe(0)
  end)
end)
