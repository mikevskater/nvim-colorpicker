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
