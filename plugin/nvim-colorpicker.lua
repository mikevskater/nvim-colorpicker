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

-- Commands
vim.api.nvim_create_user_command('ColorPicker', function(opts)
  local colorpicker = require('nvim-colorpicker')
  local initial_color = opts.args ~= '' and opts.args or nil
  colorpicker.pick({ color = initial_color })
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
    local viewer = require('tests.viewer')
    viewer.show()
  elseif arg == 'run' then
    -- Run tests and print to console
    local runner = require('tests.runner')
    runner.run({ save = true, print = true, ui = false })
  elseif arg == 'last' then
    -- Show last results in UI
    local runner = require('tests.runner')
    local results = runner.load_results()
    if results then
      local viewer = require('tests.viewer')
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
