---@module 'nvim-colorpicker.tests.viewer'
---@brief Multipanel UI for viewing test results

local M = {}

-- ============================================================================
-- Dependencies
-- ============================================================================

local nf = require("nvim-float")
local ContentBuilder = require("nvim-float.content_builder")

-- ============================================================================
-- State
-- ============================================================================

---@type table? Current multipanel state
local state = nil

---@type table? Current test results
local results = nil

---@type number Selected category index
local selected_category = 1

---@type number Selected file index within category (0 = category summary)
local selected_file = 0

-- ============================================================================
-- Content Builders
-- ============================================================================

---Build left panel content (category list)
---@param data table Test results
---@return table ContentBuilder
local function build_category_list(data)
  local cb = ContentBuilder.new()

  -- Header with summary
  cb:header("Test Results")
  cb:blank()

  local status_style = data.total_failed == 0 and "success" or "error"
  cb:styled(string.format("  %d passed, %d failed", data.total_passed, data.total_failed), status_style)
  cb:muted(string.format("  %.2fms total", data.total_duration))
  cb:blank()
  cb:separator()
  cb:blank()

  -- Category list
  for i, category in ipairs(data.categories) do
    local prefix = i == selected_category and " > " or "   "
    local icon = category.failed == 0 and "[+]" or "[X]"
    local style = nil

    if i == selected_category then
      style = "emphasis"
    elseif category.failed > 0 then
      style = "error"
    else
      style = "success"
    end

    local text = string.format("%s%s %s (%d/%d)",
      prefix, icon, category.name,
      category.passed, category.passed + category.failed)

    if style then
      cb:styled(text, style)
    else
      cb:line(text)
    end
  end

  cb:blank()
  cb:separator()
  cb:blank()
  cb:muted("  [j/k] Navigate")
  cb:muted("  [l/Enter] View details")
  cb:muted("  [h] Back to summary")
  cb:muted("  [r] Re-run tests")
  cb:muted("  [q] Close")

  return cb
end

---Build right panel content (category/file details)
---@param data table Test results
---@return table ContentBuilder
local function build_detail_panel(data)
  local cb = ContentBuilder.new()

  if #data.categories == 0 then
    cb:header("No Tests Found")
    cb:blank()
    cb:text("No test files were found in the tests/ directory.")
    return cb
  end

  local category = data.categories[selected_category]
  if not category then
    cb:header("Select a Category")
    return cb
  end

  if selected_file == 0 then
    -- Category summary
    cb:header(category.name:upper())
    cb:blank()

    -- Stats
    local status_style = category.failed == 0 and "success" or "error"
    cb:styled(string.format("  Status: %s", category.failed == 0 and "PASSED" or "FAILED"), status_style)
    cb:key_value("  Tests", string.format("%d passed, %d failed", category.passed, category.failed))
    cb:key_value("  Duration", string.format("%.2fms", category.duration))
    cb:key_value("  Files", tostring(#category.files))
    cb:blank()
    cb:separator()

    -- File list
    cb:blank()
    cb:subheader("Test Files")
    cb:blank()

    for i, file in ipairs(category.files) do
      local icon = file.failed == 0 and "[+]" or "[X]"
      local style = file.failed == 0 and "success" or "error"
      cb:styled(string.format("  %s %s (%d/%d)",
        icon, file.name, file.passed, file.passed + file.failed), style)

      -- Show failed tests inline
      if file.failed > 0 then
        for _, suite in ipairs(file.suites) do
          for _, test in ipairs(suite.tests) do
            if not test.passed then
              cb:error(string.format("      X %s > %s", suite.name, test.name))
            end
          end
        end
      end
    end
  else
    -- File details
    local file = category.files[selected_file]
    if not file then
      cb:header("Select a File")
      return cb
    end

    cb:header(file.name)
    cb:muted("  " .. category.name .. "/" .. file.name .. ".lua")
    cb:blank()

    local status_style = file.failed == 0 and "success" or "error"
    cb:styled(string.format("  Status: %s", file.failed == 0 and "PASSED" or "FAILED"), status_style)
    cb:key_value("  Tests", string.format("%d passed, %d failed", file.passed, file.failed))
    cb:key_value("  Duration", string.format("%.2fms", file.duration))
    cb:blank()
    cb:separator()

    -- Suites and tests
    for _, suite in ipairs(file.suites) do
      cb:blank()
      cb:subheader(suite.name)

      for _, test in ipairs(suite.tests) do
        if test.passed then
          cb:success(string.format("    + %s", test.name))
        else
          cb:error(string.format("    X %s", test.name))
          if test.error then
            -- Wrap error message
            local err_lines = vim.split(test.error, "\n")
            for _, line in ipairs(err_lines) do
              cb:muted("        " .. line:sub(1, 60))
            end
          end
        end
      end
    end
  end

  return cb
end

-- ============================================================================
-- Panel Updates
-- ============================================================================

---Update both panels
local function update_panels()
  if not state or not results then return end

  local left = state.panels.categories
  local right = state.panels.details

  if left and vim.api.nvim_win_is_valid(left.winid) then
    left:update_styled(build_category_list(results))
  end

  if right and vim.api.nvim_win_is_valid(right.winid) then
    right:update_styled(build_detail_panel(results))
  end
end

-- ============================================================================
-- Navigation
-- ============================================================================

---Move to next category
local function next_category()
  if not results then return end
  selected_category = math.min(selected_category + 1, #results.categories)
  selected_file = 0
  update_panels()
end

---Move to previous category
local function prev_category()
  if not results then return end
  selected_category = math.max(selected_category - 1, 1)
  selected_file = 0
  update_panels()
end

---Enter category to view files
local function enter_category()
  if not results then return end
  local category = results.categories[selected_category]
  if category and #category.files > 0 then
    selected_file = 1
    update_panels()
  end
end

---Go back to category summary
local function back_to_summary()
  selected_file = 0
  update_panels()
end

---Next file in category
local function next_file()
  if not results then return end
  local category = results.categories[selected_category]
  if not category then return end

  if selected_file == 0 then
    selected_file = 1
  else
    selected_file = math.min(selected_file + 1, #category.files)
  end
  update_panels()
end

---Previous file in category
local function prev_file()
  if not results then return end
  selected_file = math.max(selected_file - 1, 0)
  update_panels()
end

-- ============================================================================
-- Actions
-- ============================================================================

---Re-run tests and update UI
local function rerun_tests()
  local runner = require('tests.runner')
  results = runner.run({ save = true, print = false, ui = false })
  selected_category = 1
  selected_file = 0
  update_panels()
  vim.notify("Tests re-run complete", vim.log.levels.INFO)
end

---Close the viewer
local function close_viewer()
  if state then
    -- Close all panels
    for _, panel in pairs(state.panels) do
      if panel and panel.winid and vim.api.nvim_win_is_valid(panel.winid) then
        vim.api.nvim_win_close(panel.winid, true)
      end
    end
    state = nil
  end
end

-- ============================================================================
-- Public API
-- ============================================================================

---Show test results in multipanel UI
---@param data table? Test results (will run tests if not provided)
function M.show(data)
  -- Get or run tests
  if not data then
    local runner = require('tests.runner')
    data = runner.run({ save = true, print = false, ui = false })
  end

  results = data
  selected_category = 1
  selected_file = 0

  -- Ensure nvim-float is setup
  nf.setup()

  -- Create multipanel layout
  state = nf.create_multi_panel({
    layout = "horizontal",
    panels = {
      {
        id = "categories",
        title = " Categories ",
        width = 0.35,
        content_builder = build_category_list(data),
      },
      {
        id = "details",
        title = " Details ",
        width = 0.65,
        content_builder = build_detail_panel(data),
      },
    },
    total_width = 120,
    total_height = 30,
  })

  if not state then
    vim.notify("Failed to create test viewer", vim.log.levels.ERROR)
    return
  end

  -- Setup keymaps on the categories panel
  local left = state.panels.categories
  if left and left.bufnr and vim.api.nvim_buf_is_valid(left.bufnr) then
    local opts = { buffer = left.bufnr, nowait = true }

    vim.keymap.set("n", "j", next_category, opts)
    vim.keymap.set("n", "k", prev_category, opts)
    vim.keymap.set("n", "l", enter_category, opts)
    vim.keymap.set("n", "<CR>", enter_category, opts)
    vim.keymap.set("n", "h", back_to_summary, opts)
    vim.keymap.set("n", "r", rerun_tests, opts)
    vim.keymap.set("n", "q", close_viewer, opts)
    vim.keymap.set("n", "<Esc>", close_viewer, opts)
  end

  -- Setup keymaps on the details panel
  local right = state.panels.details
  if right and right.bufnr and vim.api.nvim_buf_is_valid(right.bufnr) then
    local opts = { buffer = right.bufnr, nowait = true }

    vim.keymap.set("n", "j", next_file, opts)
    vim.keymap.set("n", "k", prev_file, opts)
    vim.keymap.set("n", "h", back_to_summary, opts)
    vim.keymap.set("n", "r", rerun_tests, opts)
    vim.keymap.set("n", "q", close_viewer, opts)
    vim.keymap.set("n", "<Esc>", close_viewer, opts)
  end
end

---Close the viewer if open
function M.close()
  close_viewer()
end

---Check if viewer is open
---@return boolean
function M.is_open()
  return state ~= nil
end

return M
