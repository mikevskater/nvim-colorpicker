-- Plugin guard
if vim.g.loaded_nvim_colorpicker then
  return
end
vim.g.loaded_nvim_colorpicker = true

-- Require Neovim 0.9+
if vim.fn.has('nvim-0.9') == 0 then
  vim.api.nvim_err_writeln('nvim-colorpicker requires Neovim 0.9 or higher')
  return
end

-- ============================================================================
-- User Commands
-- ============================================================================
vim.api.nvim_create_user_command('ColorPicker', function(opts)
  local colorpicker = require('nvim-colorpicker')
  local initial_color = opts.args ~= '' and opts.args or nil
  -- Capture filetype before opening picker for file-aware formatting
  local filetype = vim.bo.filetype
  colorpicker.pick({
    color = initial_color,
    target_filetype = filetype,
    on_select = function(result)
      vim.api.nvim_put({ result.color }, 'c', true, true)
    end,
  })
end, {
  nargs = '?',
  desc = 'Open color picker (optional: initial color)',
})

vim.api.nvim_create_user_command('ColorPickerAtCursor', function()
  local colorpicker = require('nvim-colorpicker')
  colorpicker.pick_at_cursor()
end, {
  desc = 'Pick and replace color at cursor',
})

vim.api.nvim_create_user_command('ColorPickerMini', function(opts)
  local colorpicker = require('nvim-colorpicker')
  local initial_color = opts.args ~= '' and opts.args or nil
  -- Capture filetype before opening picker for file-aware formatting
  local filetype = vim.bo.filetype
  colorpicker.pick_mini({
    color = initial_color,
    target_filetype = filetype,
    on_select = function(result)
      vim.api.nvim_put({ result.color }, 'c', true, true)
    end,
  })
end, {
  nargs = '?',
  desc = 'Open compact inline color picker (optional: initial color)',
})

vim.api.nvim_create_user_command('ColorPickerMiniAtCursor', function()
  local colorpicker = require('nvim-colorpicker')
  colorpicker.pick_mini_at_cursor()
end, {
  desc = 'Pick and replace color at cursor with mini picker',
})

vim.api.nvim_create_user_command('ColorPickerMiniSlider', function(opts)
  local colorpicker = require('nvim-colorpicker')
  local initial_color = opts.args ~= '' and opts.args or nil
  -- Capture filetype before opening picker for file-aware formatting
  local filetype = vim.bo.filetype
  colorpicker.pick_mini_slider({
    color = initial_color,
    target_filetype = filetype,
    on_select = function(result)
      vim.api.nvim_put({ result.color }, 'c', true, true)
    end,
  })
end, {
  nargs = '?',
  desc = 'Open mini picker in slider mode (optional: initial color)',
})

vim.api.nvim_create_user_command('ColorPickerMiniSliderAtCursor', function()
  local colorpicker = require('nvim-colorpicker')
  colorpicker.pick_mini_slider_at_cursor()
end, {
  desc = 'Pick and replace color at cursor with mini picker in slider mode',
})

vim.api.nvim_create_user_command('ColorConvert', function(opts)
  local colorpicker = require('nvim-colorpicker')
  local format = opts.args ~= '' and opts.args or 'hex'
  colorpicker.convert_at_cursor(format)
end, {
  nargs = '?',
  complete = function()
    return { 'hex', 'rgb', 'hsl', 'hsv' }
  end,
  desc = 'Convert color at cursor to specified format',
})

-- Clipboard commands
vim.api.nvim_create_user_command('ColorYank', function(opts)
  local colorpicker = require('nvim-colorpicker')
  local format = opts.args ~= '' and opts.args or nil
  colorpicker.yank(nil, format)
end, {
  nargs = '?',
  complete = function()
    return { 'hex', 'rgb', 'hsl', 'hsv' }
  end,
  desc = 'Copy color at cursor to clipboard',
})

vim.api.nvim_create_user_command('ColorPaste', function()
  local colorpicker = require('nvim-colorpicker')
  local hex = colorpicker.paste()
  if hex then
    -- Insert at cursor
    vim.api.nvim_put({ hex }, 'c', true, true)
  end
end, {
  desc = 'Paste color from clipboard',
})

-- Highlighting commands
vim.api.nvim_create_user_command('ColorHighlight', function(opts)
  local colorpicker = require('nvim-colorpicker')
  local arg = opts.args:lower()
  if arg == 'on' or arg == 'enable' then
    colorpicker.enable_highlight()
  elseif arg == 'off' or arg == 'disable' then
    colorpicker.disable_highlight()
  elseif arg == 'toggle' or arg == '' then
    colorpicker.toggle_highlight()
  elseif arg == 'auto' then
    colorpicker.enable_auto_highlight()
  elseif arg == 'noauto' then
    colorpicker.disable_auto_highlight()
  elseif arg == 'background' or arg == 'foreground' or arg == 'virtualtext' then
    colorpicker.set_highlight_mode(arg)
  end
end, {
  nargs = '?',
  complete = function()
    return { 'toggle', 'on', 'off', 'auto', 'noauto', 'background', 'foreground', 'virtualtext' }
  end,
  desc = 'Toggle or configure color highlighting in buffer',
})

-- History command
vim.api.nvim_create_user_command('ColorHistory', function(opts)
  local colorpicker = require('nvim-colorpicker')
  local count = opts.args ~= '' and tonumber(opts.args) or 10
  local colors = colorpicker.get_recent_colors(count)
  if #colors == 0 then
    vim.notify('No recent colors in history', vim.log.levels.INFO)
    return
  end
  local lines = { 'Recent colors:' }
  for i, hex in ipairs(colors) do
    table.insert(lines, string.format('  %d. %s', i, hex))
  end
  vim.notify(table.concat(lines, '\n'), vim.log.levels.INFO)
end, {
  nargs = '?',
  desc = 'Show recent color history (optional: count)',
})

-- Preset search command
vim.api.nvim_create_user_command('ColorSearch', function(opts)
  local colorpicker = require('nvim-colorpicker')
  if opts.args == '' then
    vim.notify('Usage: :ColorSearch <query>', vim.log.levels.INFO)
    return
  end
  local matches = colorpicker.search_presets(opts.args)
  if #matches == 0 then
    vim.notify('No colors found matching: ' .. opts.args, vim.log.levels.INFO)
    return
  end
  -- Display matches
  local lines = { 'Color search results for "' .. opts.args .. '":' }
  for i, match in ipairs(matches) do
    if i > 20 then
      table.insert(lines, '... and ' .. (#matches - 20) .. ' more')
      break
    end
    table.insert(lines, string.format('  %s: %s (%s)', match.name, match.hex, match.preset))
  end
  vim.notify(table.concat(lines, '\n'), vim.log.levels.INFO)
end, {
  nargs = 1,
  desc = 'Search color presets by name',
})

-- Test commands
vim.api.nvim_create_user_command('ColorPickerTest', function(opts)
  local arg = opts.args:lower()
  if arg == 'ui' or arg == '' then
    -- Run tests and show UI
    local viewer = require('nvim-colorpicker.tests.viewer')
    viewer.show()
  elseif arg == 'run' then
    -- Run tests and print to console
    local runner = require('nvim-colorpicker.tests.runner')
    runner.run({ save = true, print = true, ui = false })
  elseif arg == 'last' then
    -- Show last results in UI
    local runner = require('nvim-colorpicker.tests.runner')
    local results = runner.load_results()
    if results then
      local viewer = require('nvim-colorpicker.tests.viewer')
      viewer.show(results)
    else
      vim.notify('No previous test results found', vim.log.levels.WARN)
    end
  end
end, {
  nargs = '?',
  complete = function()
    return { 'ui', 'run', 'last' }
  end,
  desc = 'Run nvim-colorpicker tests (ui/run/last)',
})

-- ============================================================================
-- <Plug> Mappings
-- ============================================================================
-- These allow users to create their own keymaps without hardcoding commands.
-- Usage: vim.keymap.set("n", "<leader>cp", "<Plug>(colorpicker)")

-- Full picker
vim.keymap.set("n", "<Plug>(colorpicker)", function()
  local colorpicker = require("nvim-colorpicker")
  local filetype = vim.bo.filetype
  colorpicker.pick({
    target_filetype = filetype,
    on_select = function(result)
      vim.api.nvim_put({ result.color }, 'c', true, true)
    end,
  })
end, { desc = "Open color picker" })

vim.keymap.set("n", "<Plug>(colorpicker-at-cursor)", function()
  require("nvim-colorpicker").pick_at_cursor()
end, { desc = "Pick and replace color at cursor" })

-- Mini picker
vim.keymap.set("n", "<Plug>(colorpicker-mini)", function()
  local colorpicker = require("nvim-colorpicker")
  local filetype = vim.bo.filetype
  colorpicker.pick_mini({
    target_filetype = filetype,
    on_select = function(result)
      vim.api.nvim_put({ result.color }, 'c', true, true)
    end,
  })
end, { desc = "Open mini color picker" })

vim.keymap.set("n", "<Plug>(colorpicker-mini-at-cursor)", function()
  require("nvim-colorpicker").pick_mini_at_cursor()
end, { desc = "Pick and replace color at cursor with mini picker" })

-- Slider mode
vim.keymap.set("n", "<Plug>(colorpicker-slider)", function()
  local colorpicker = require("nvim-colorpicker")
  local filetype = vim.bo.filetype
  colorpicker.pick_mini_slider({
    target_filetype = filetype,
    on_select = function(result)
      vim.api.nvim_put({ result.color }, 'c', true, true)
    end,
  })
end, { desc = "Open color picker in slider mode" })

vim.keymap.set("n", "<Plug>(colorpicker-slider-at-cursor)", function()
  require("nvim-colorpicker").pick_mini_slider_at_cursor()
end, { desc = "Pick and replace color at cursor with slider mode" })

-- Convert color at cursor
vim.keymap.set("n", "<Plug>(colorpicker-convert-hex)", function()
  require("nvim-colorpicker").convert_at_cursor("hex")
end, { desc = "Convert color at cursor to hex" })

vim.keymap.set("n", "<Plug>(colorpicker-convert-rgb)", function()
  require("nvim-colorpicker").convert_at_cursor("rgb")
end, { desc = "Convert color at cursor to rgb" })

vim.keymap.set("n", "<Plug>(colorpicker-convert-hsl)", function()
  require("nvim-colorpicker").convert_at_cursor("hsl")
end, { desc = "Convert color at cursor to hsl" })

-- Highlighting
vim.keymap.set("n", "<Plug>(colorpicker-highlight-toggle)", function()
  require("nvim-colorpicker").toggle_highlight()
end, { desc = "Toggle color highlighting in buffer" })
