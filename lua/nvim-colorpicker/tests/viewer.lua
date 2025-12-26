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
              cb:styled(string.format("      X %s > %s", suite.name, test.name), "error")
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
          cb:styled(string.format("    + %s", test.name), "success")
        else
          cb:styled(string.format("    X %s", test.name), "error")
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

  -- Use multipanel's render_panel which calls the on_render callbacks
  state:render_panel("categories")
  state:render_panel("details")
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

---Enter category to view files (and focus details panel)
local function enter_category()
  if not results or not state then return end
  local category = results.categories[selected_category]
  if category then
    selected_file = 0  -- Show category summary first
    update_panels()
    state:focus_panel("details")
  end
end

---Go back to category summary
local function back_to_summary()
  selected_file = 0
  update_panels()
end

---Next file in category (or next category if at last file)
local function next_file()
  if not results then return end
  local category = results.categories[selected_category]
  if not category then return end

  if selected_file == 0 then
    -- At category summary, go to first file
    if #category.files > 0 then
      selected_file = 1
    end
  elseif selected_file < #category.files then
    -- Go to next file
    selected_file = selected_file + 1
  else
    -- At last file, go to next category
    if selected_category < #results.categories then
      selected_category = selected_category + 1
      selected_file = 0
    end
  end
  update_panels()
end

---Previous file in category (or prev category if at first)
local function prev_file()
  if not results then return end

  if selected_file > 0 then
    -- Go to previous file or category summary
    selected_file = selected_file - 1
  elseif selected_category > 1 then
    -- At category summary, go to previous category's last file
    selected_category = selected_category - 1
    local prev_cat = results.categories[selected_category]
    selected_file = prev_cat and #prev_cat.files or 0
  end
  update_panels()
end

---Go back - if viewing file go to summary, if at summary focus categories
local function go_back()
  if selected_file > 0 then
    selected_file = 0
    update_panels()
  else
    -- Focus categories panel
    state:focus_panel("categories")
  end
end

---Drill into details - if at summary, show first file
local function drill_in()
  if not results then return end
  local category = results.categories[selected_category]
  if category and selected_file == 0 and #category.files > 0 then
    selected_file = 1
    update_panels()
  end
end

-- ============================================================================
-- Actions
-- ============================================================================

---Re-run tests and update UI
local function rerun_tests()
  local runner = require('nvim-colorpicker.tests.runner')
  results = runner.run({ save = true, print = false, ui = false })
  selected_category = 1
  selected_file = 0
  update_panels()
  vim.notify("Tests re-run complete", vim.log.levels.INFO)
end

---Close the viewer
local function close_viewer()
  if state then
    state:close()
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
    local runner = require('nvim-colorpicker.tests.runner')
    data = runner.run({ save = true, print = false, ui = false })
  end

  results = data
  selected_category = 1
  selected_file = 0

  -- Ensure nvim-float is setup
  nf.setup()

  -- Create multipanel layout using correct API
  state = nf.create_multi_panel({
    layout = {
      split = "horizontal",
      children = {
        {
          name = "categories",
          title = " Categories ",
          ratio = 0.35,
          on_render = function()
            local cb = build_category_list(results)
            return cb:build_lines(), cb:build_highlights()
          end,
        },
        {
          name = "details",
          title = " Details ",
          ratio = 0.65,
          on_render = function()
            local cb = build_detail_panel(results)
            return cb:build_lines(), cb:build_highlights()
          end,
        },
      },
    },
    total_width_ratio = 0.75,
    total_height_ratio = 0.75,
    initial_focus = "categories",
    controls = {
      {
        header = "Categories Panel",
        keys = {
          { key = "j/k", desc = "Navigate categories" },
          { key = "l/Enter", desc = "Select category" },
        },
      },
      {
        header = "Details Panel",
        keys = {
          { key = "j/k", desc = "Scroll content (vim default)" },
          { key = "]/n", desc = "Next file/category" },
          { key = "[/N", desc = "Previous file/category" },
          { key = "l", desc = "Drill into file" },
          { key = "h", desc = "Back / focus categories" },
        },
      },
      {
        header = "General",
        keys = {
          { key = "Tab", desc = "Switch panel focus" },
          { key = "r", desc = "Re-run tests" },
          { key = "q/Esc", desc = "Close" },
        },
      },
    },
  })

  if not state then
    vim.notify("Failed to create test viewer", vim.log.levels.ERROR)
    return
  end

  -- Render initial content
  state:render_all()

  -- Panel switching functions
  local function focus_next()
    state:focus_next_panel()
  end
  local function focus_prev()
    state:focus_prev_panel()
  end

  -- Setup keymaps on the categories panel
  state:set_panel_keymaps("categories", {
    ["j"] = next_category,
    ["k"] = prev_category,
    ["l"] = enter_category,
    ["<CR>"] = enter_category,
    ["h"] = back_to_summary,
    ["r"] = rerun_tests,
    ["q"] = close_viewer,
    ["<Esc>"] = close_viewer,
    ["<Tab>"] = focus_next,
    ["<S-Tab>"] = focus_prev,
  })

  -- Setup keymaps on the details panel
  -- Note: j/k are NOT overridden so normal vim scrolling works
  state:set_panel_keymaps("details", {
    ["]"] = next_file,        -- Next file/category
    ["["] = prev_file,        -- Previous file/category
    ["n"] = next_file,        -- Alternative: next
    ["N"] = prev_file,        -- Alternative: previous
    ["h"] = go_back,          -- Back to summary or focus categories
    ["l"] = drill_in,         -- Drill into file details
    ["r"] = rerun_tests,
    ["q"] = close_viewer,
    ["<Esc>"] = close_viewer,
    ["<Tab>"] = focus_next,
    ["<S-Tab>"] = focus_prev,
  })
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
