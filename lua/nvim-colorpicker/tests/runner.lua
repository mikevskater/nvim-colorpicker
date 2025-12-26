---@module 'nvim-colorpicker.tests.runner'
---@brief Test runner with auto-scanning and results viewer

local M = {}

local framework = require('nvim-colorpicker.tests.framework')

-- ============================================================================
-- Types
-- ============================================================================

---@class CategoryResult
---@field name string Category name
---@field files TestFile[] Test files in category
---@field passed number Total passed
---@field failed number Total failed
---@field duration number Total duration

-- ============================================================================
-- File Discovery
-- ============================================================================

---Get the tests directory path
---@return string
local function get_tests_dir()
  local info = debug.getinfo(1, "S")
  local path = info.source:sub(2)  -- Remove leading @
  -- Handle Windows paths
  path = path:gsub("\\", "/")
  return path:match("(.*/)")
end

---Scan directory recursively for test files
---@param dir string Directory path
---@param files string[]? Accumulator
---@return string[] files
local function scan_test_files(dir, files)
  files = files or {}

  -- Use vim.fn.glob for cross-platform directory scanning
  local pattern = dir .. "**/*.lua"
  local matches = vim.fn.glob(pattern, false, true)

  for _, file in ipairs(matches) do
    -- Skip framework.lua and runner.lua
    local basename = vim.fn.fnamemodify(file, ":t")
    if basename ~= "framework.lua" and basename ~= "runner.lua" then
      table.insert(files, file)
    end
  end

  return files
end

---Extract category from file path
---@param file_path string
---@param tests_dir string
---@return string category
local function get_category(file_path, tests_dir)
  -- Normalize paths
  file_path = file_path:gsub("\\", "/")
  tests_dir = tests_dir:gsub("\\", "/")

  -- Remove tests dir prefix
  local relative = file_path:gsub("^" .. vim.pesc(tests_dir), "")
  relative = relative:gsub("^/", "")

  -- Get first directory as category
  local category = relative:match("^([^/]+)/") or "root"
  return category
end

-- ============================================================================
-- Test Execution
-- ============================================================================

---Run all tests in directory
---@param tests_dir string? Tests directory (default: auto-detect)
---@return table results Test run results
function M.run_all(tests_dir)
  tests_dir = tests_dir or get_tests_dir()

  -- Discover test files
  local files = scan_test_files(tests_dir)

  -- Group by category
  local categories = {}
  local category_order = {}

  for _, file_path in ipairs(files) do
    local category = get_category(file_path, tests_dir)

    if not categories[category] then
      categories[category] = {
        name = category,
        files = {},
        passed = 0,
        failed = 0,
        duration = 0,
      }
      table.insert(category_order, category)
    end

    -- Run test file
    framework.reset()
    local file_result = framework.run_file(file_path)

    table.insert(categories[category].files, file_result)
    categories[category].passed = categories[category].passed + file_result.passed
    categories[category].failed = categories[category].failed + file_result.failed
    categories[category].duration = categories[category].duration + file_result.duration
  end

  -- Sort categories
  table.sort(category_order)

  -- Build ordered results
  local ordered_categories = {}
  for _, name in ipairs(category_order) do
    table.insert(ordered_categories, categories[name])
  end

  -- Calculate totals
  local total_passed = 0
  local total_failed = 0
  local total_duration = 0

  for _, cat in ipairs(ordered_categories) do
    total_passed = total_passed + cat.passed
    total_failed = total_failed + cat.failed
    total_duration = total_duration + cat.duration
  end

  return {
    timestamp = os.time(),
    categories = ordered_categories,
    total_passed = total_passed,
    total_failed = total_failed,
    total_duration = total_duration,
  }
end

---Run tests for a specific category
---@param category string Category name
---@param tests_dir string? Tests directory
---@return CategoryResult?
function M.run_category(category, tests_dir)
  tests_dir = tests_dir or get_tests_dir()

  local cat_dir = tests_dir .. category .. "/"
  local files = scan_test_files(cat_dir)

  if #files == 0 then
    return nil
  end

  local result = {
    name = category,
    files = {},
    passed = 0,
    failed = 0,
    duration = 0,
  }

  for _, file_path in ipairs(files) do
    framework.reset()
    local file_result = framework.run_file(file_path)

    table.insert(result.files, file_result)
    result.passed = result.passed + file_result.passed
    result.failed = result.failed + file_result.failed
    result.duration = result.duration + file_result.duration
  end

  return result
end

-- ============================================================================
-- Results Persistence
-- ============================================================================

---Save results to file
---@param results table Test results
---@param path string? File path (default: tests/results/latest.json)
function M.save_results(results, path)
  local tests_dir = get_tests_dir()
  path = path or (tests_dir .. "results/latest.json")

  local json = vim.fn.json_encode(results)

  local file = io.open(path, "w")
  if file then
    file:write(json)
    file:close()
  end

  -- Also save timestamped version
  local timestamp_path = tests_dir .. "results/" .. os.date("%Y%m%d_%H%M%S") .. ".json"
  file = io.open(timestamp_path, "w")
  if file then
    file:write(json)
    file:close()
  end
end

---Load results from file
---@param path string? File path (default: tests/results/latest.json)
---@return table? results
function M.load_results(path)
  local tests_dir = get_tests_dir()
  path = path or (tests_dir .. "results/latest.json")

  local file = io.open(path, "r")
  if not file then
    return nil
  end

  local content = file:read("*all")
  file:close()

  if content and content ~= "" then
    local ok, data = pcall(vim.fn.json_decode, content)
    if ok then
      return data
    end
  end

  return nil
end

-- ============================================================================
-- Console Output
-- ============================================================================

---Print results to console
---@param results table Test results
function M.print_results(results)
  print("=== nvim-colorpicker Test Results ===")
  print("")
  print(string.format("Total: %d passed, %d failed (%.2fms)",
    results.total_passed,
    results.total_failed,
    results.total_duration))
  print("")

  for _, category in ipairs(results.categories) do
    local status = category.failed == 0 and "PASS" or "FAIL"
    print(string.format("[%s] %s: %d passed, %d failed",
      status, category.name, category.passed, category.failed))

    for _, file in ipairs(category.files) do
      if file.failed > 0 then
        print(string.format("  - %s: %d passed, %d FAILED", file.name, file.passed, file.failed))
        for _, suite in ipairs(file.suites) do
          for _, test in ipairs(suite.tests) do
            if not test.passed then
              print(string.format("    FAIL: %s > %s", suite.name, test.name))
              if test.error then
                print(string.format("          %s", test.error:gsub("\n", "\n          ")))
              end
            end
          end
        end
      end
    end
  end

  print("")
  if results.total_failed == 0 then
    print("All tests passed!")
  else
    print(string.format("%d test(s) failed", results.total_failed))
  end
end

-- ============================================================================
-- Main Entry Point
-- ============================================================================

---Run all tests and show results
---@param opts table? Options { save = bool, print = bool, ui = bool }
---@return table results
function M.run(opts)
  opts = opts or {}
  if opts.save == nil then opts.save = true end
  if opts.print == nil then opts.print = true end
  if opts.ui == nil then opts.ui = false end

  local results = M.run_all()

  if opts.save then
    M.save_results(results)
  end

  if opts.print then
    M.print_results(results)
  end

  if opts.ui then
    M.show_ui(results)
  end

  return results
end

---Show results in UI (placeholder for viewer module)
---@param results table Test results
function M.show_ui(results)
  local ok, viewer = pcall(require, 'nvim-colorpicker.tests.viewer')
  if ok then
    viewer.show(results)
  else
    print("UI viewer not available, printing to console instead")
    M.print_results(results)
  end
end

return M
