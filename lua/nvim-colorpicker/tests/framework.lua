---@module 'nvim-colorpicker.tests.framework'
---@brief Lightweight test framework for nvim-colorpicker

local M = {}

-- ============================================================================
-- Types
-- ============================================================================

---@class TestResult
---@field name string Test name
---@field passed boolean Whether test passed
---@field error string? Error message if failed
---@field duration number Test duration in ms

---@class TestSuite
---@field name string Suite name
---@field tests TestResult[] Individual test results
---@field passed number Count of passed tests
---@field failed number Count of failed tests
---@field duration number Total duration in ms

---@class TestFile
---@field path string File path relative to tests/
---@field category string Category (folder name)
---@field name string Test file name
---@field suites TestSuite[] Test suites in file
---@field passed number Total passed
---@field failed number Total failed
---@field duration number Total duration

---@class TestRun
---@field timestamp number Unix timestamp
---@field files TestFile[] All test files
---@field total_passed number Total passed tests
---@field total_failed number Total failed tests
---@field total_duration number Total duration in ms

-- ============================================================================
-- State
-- ============================================================================

---@type TestSuite[]
local current_suites = {}

---@type TestSuite?
local current_suite = nil

---@type TestResult[]
local current_tests = {}

-- ============================================================================
-- Assertion Helpers
-- ============================================================================

---@class Expectation
---@field value any The value being tested
---@field negated boolean Whether this is a NOT assertion
local Expectation = {}
Expectation.__index = Expectation

---Create a new expectation
---@param value any
---@return Expectation
function M.expect(value)
  return setmetatable({ value = value, negated = false }, Expectation)
end

---Negate the expectation
---@return Expectation
function Expectation:never()
  self.negated = true
  return self
end

---Assert equality
---@param expected any
function Expectation:toBe(expected)
  local passed = (self.value == expected)
  if self.negated then passed = not passed end

  if not passed then
    local msg = self.negated
      and string.format("Expected %s to NOT be %s", vim.inspect(self.value), vim.inspect(expected))
      or string.format("Expected %s to be %s", vim.inspect(self.value), vim.inspect(expected))
    error(msg, 2)
  end
end

---Assert deep equality for tables
---@param expected any
function Expectation:toEqual(expected)
  local passed = vim.deep_equal(self.value, expected)
  if self.negated then passed = not passed end

  if not passed then
    local msg = self.negated
      and string.format("Expected %s to NOT equal %s", vim.inspect(self.value), vim.inspect(expected))
      or string.format("Expected %s to equal %s", vim.inspect(self.value), vim.inspect(expected))
    error(msg, 2)
  end
end

---Assert value is truthy
function Expectation:toBeTruthy()
  local passed = self.value and true or false
  if self.negated then passed = not passed end

  if not passed then
    local msg = self.negated
      and string.format("Expected %s to be falsy", vim.inspect(self.value))
      or string.format("Expected %s to be truthy", vim.inspect(self.value))
    error(msg, 2)
  end
end

---Assert value is falsy
function Expectation:toBeFalsy()
  local passed = not self.value
  if self.negated then passed = not passed end

  if not passed then
    local msg = self.negated
      and string.format("Expected %s to be truthy", vim.inspect(self.value))
      or string.format("Expected %s to be falsy", vim.inspect(self.value))
    error(msg, 2)
  end
end

---Assert value is nil
function Expectation:toBeNil()
  local passed = (self.value == nil)
  if self.negated then passed = not passed end

  if not passed then
    local msg = self.negated
      and string.format("Expected %s to NOT be nil", vim.inspect(self.value))
      or string.format("Expected %s to be nil", vim.inspect(self.value))
    error(msg, 2)
  end
end

---Assert type
---@param expected_type string
function Expectation:toBeType(expected_type)
  local actual_type = type(self.value)
  local passed = (actual_type == expected_type)
  if self.negated then passed = not passed end

  if not passed then
    local msg = self.negated
      and string.format("Expected type to NOT be %s (got %s)", expected_type, actual_type)
      or string.format("Expected type %s but got %s", expected_type, actual_type)
    error(msg, 2)
  end
end

---Assert number is close to expected (for floating point)
---@param expected number
---@param tolerance number?
function Expectation:toBeCloseTo(expected, tolerance)
  tolerance = tolerance or 0.001
  local passed = math.abs(self.value - expected) <= tolerance
  if self.negated then passed = not passed end

  if not passed then
    local msg = self.negated
      and string.format("Expected %s to NOT be close to %s (tolerance: %s)", self.value, expected, tolerance)
      or string.format("Expected %s to be close to %s (tolerance: %s)", self.value, expected, tolerance)
    error(msg, 2)
  end
end

---Assert string contains substring
---@param substring string
function Expectation:toContain(substring)
  local passed = false
  if type(self.value) == "string" then
    passed = self.value:find(substring, 1, true) ~= nil
  elseif type(self.value) == "table" then
    for _, v in pairs(self.value) do
      if v == substring then
        passed = true
        break
      end
    end
  end
  if self.negated then passed = not passed end

  if not passed then
    local msg = self.negated
      and string.format("Expected %s to NOT contain %s", vim.inspect(self.value), vim.inspect(substring))
      or string.format("Expected %s to contain %s", vim.inspect(self.value), vim.inspect(substring))
    error(msg, 2)
  end
end

---Assert string matches pattern
---@param pattern string
function Expectation:toMatch(pattern)
  local passed = type(self.value) == "string" and self.value:match(pattern) ~= nil
  if self.negated then passed = not passed end

  if not passed then
    local msg = self.negated
      and string.format("Expected %s to NOT match pattern %s", vim.inspect(self.value), pattern)
      or string.format("Expected %s to match pattern %s", vim.inspect(self.value), pattern)
    error(msg, 2)
  end
end

---Assert table has key
---@param key any
function Expectation:toHaveKey(key)
  local passed = type(self.value) == "table" and self.value[key] ~= nil
  if self.negated then passed = not passed end

  if not passed then
    local msg = self.negated
      and string.format("Expected table to NOT have key %s", vim.inspect(key))
      or string.format("Expected table to have key %s", vim.inspect(key))
    error(msg, 2)
  end
end

---Assert table has length
---@param length number
function Expectation:toHaveLength(length)
  local actual_length = type(self.value) == "table" and #self.value or 0
  local passed = actual_length == length
  if self.negated then passed = not passed end

  if not passed then
    local msg = self.negated
      and string.format("Expected length to NOT be %d (got %d)", length, actual_length)
      or string.format("Expected length %d but got %d", length, actual_length)
    error(msg, 2)
  end
end

---Assert value is greater than
---@param expected number
function Expectation:toBeGreaterThan(expected)
  local passed = self.value > expected
  if self.negated then passed = not passed end

  if not passed then
    local msg = self.negated
      and string.format("Expected %s to NOT be greater than %s", self.value, expected)
      or string.format("Expected %s to be greater than %s", self.value, expected)
    error(msg, 2)
  end
end

---Assert value is less than
---@param expected number
function Expectation:toBeLessThan(expected)
  local passed = self.value < expected
  if self.negated then passed = not passed end

  if not passed then
    local msg = self.negated
      and string.format("Expected %s to NOT be less than %s", self.value, expected)
      or string.format("Expected %s to be less than %s", self.value, expected)
    error(msg, 2)
  end
end

-- ============================================================================
-- Test Definition
-- ============================================================================

---Define a test suite
---@param name string Suite name
---@param fn function Suite definition function
function M.describe(name, fn)
  -- Save current suite
  local parent_suite = current_suite

  -- Create new suite
  current_suite = {
    name = name,
    tests = {},
    passed = 0,
    failed = 0,
    duration = 0,
  }

  -- Run suite definition
  local ok, err = pcall(fn)
  if not ok then
    -- Suite setup failed
    table.insert(current_suite.tests, {
      name = "(suite setup)",
      passed = false,
      error = tostring(err),
      duration = 0,
    })
    current_suite.failed = current_suite.failed + 1
  end

  -- Store suite
  table.insert(current_suites, current_suite)

  -- Restore parent
  current_suite = parent_suite
end

---Define a test
---@param name string Test name
---@param fn function Test function
function M.it(name, fn)
  if not current_suite then
    error("it() must be called inside describe()", 2)
  end

  local start_time = vim.loop.hrtime()
  local ok, err = pcall(fn)
  local duration = (vim.loop.hrtime() - start_time) / 1000000 -- Convert to ms

  local result = {
    name = name,
    passed = ok,
    error = ok and nil or tostring(err),
    duration = duration,
  }

  table.insert(current_suite.tests, result)

  if ok then
    current_suite.passed = current_suite.passed + 1
  else
    current_suite.failed = current_suite.failed + 1
  end

  current_suite.duration = current_suite.duration + duration
end

---Skip a test
---@param name string Test name
---@param _fn function Test function (not executed)
function M.xit(name, _fn)
  if not current_suite then
    error("xit() must be called inside describe()", 2)
  end

  table.insert(current_suite.tests, {
    name = name .. " (SKIPPED)",
    passed = true,
    error = nil,
    duration = 0,
  })
  current_suite.passed = current_suite.passed + 1
end

-- ============================================================================
-- Test Execution
-- ============================================================================

---Run a test file and return results
---@param file_path string Path to test file
---@return TestFile
function M.run_file(file_path)
  -- Reset state
  current_suites = {}
  current_suite = nil

  -- Extract category and name from path
  local category = file_path:match("tests/([^/]+)/") or "root"
  local name = file_path:match("([^/]+)%.lua$") or file_path

  local start_time = vim.loop.hrtime()

  -- Load and execute test file
  local ok, err = pcall(dofile, file_path)

  local duration = (vim.loop.hrtime() - start_time) / 1000000

  if not ok then
    -- File failed to load
    return {
      path = file_path,
      category = category,
      name = name,
      suites = {{
        name = "(file load)",
        tests = {{
          name = "(load error)",
          passed = false,
          error = tostring(err),
          duration = 0,
        }},
        passed = 0,
        failed = 1,
        duration = 0,
      }},
      passed = 0,
      failed = 1,
      duration = duration,
    }
  end

  -- Calculate totals
  local total_passed = 0
  local total_failed = 0
  for _, suite in ipairs(current_suites) do
    total_passed = total_passed + suite.passed
    total_failed = total_failed + suite.failed
  end

  return {
    path = file_path,
    category = category,
    name = name,
    suites = current_suites,
    passed = total_passed,
    failed = total_failed,
    duration = duration,
  }
end

---Reset framework state
function M.reset()
  current_suites = {}
  current_suite = nil
  current_tests = {}
end

return M
