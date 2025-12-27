---@module 'nvim-colorpicker.highlight'
---@brief Buffer color highlighting and virtual text preview

local M = {}

local utils = require('nvim-colorpicker.utils')
local detect = require('nvim-colorpicker.detect')

-- ============================================================================
-- State
-- ============================================================================

---@type number Namespace for highlights
local ns = vim.api.nvim_create_namespace('nvim_colorpicker_highlight')

---@type table<number, boolean> Buffers with active highlighting
local active_buffers = {}

---@type string Highlight mode: "background", "foreground", "virtualtext"
local highlight_mode = "background"

-- ============================================================================
-- Highlight Creation
-- ============================================================================

---Create a unique highlight group for a color
---@param hex string Hex color
---@return string hl_name Highlight group name
local function get_or_create_hl(hex)
  local hl_name = "NvimColorPicker_" .. hex:gsub("#", "")

  -- Check if already exists
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = hl_name })
  if ok and hl and (hl.bg or hl.fg) then
    return hl_name
  end

  -- Create highlight
  if highlight_mode == "background" then
    local fg = utils.get_contrast_color(hex)
    vim.api.nvim_set_hl(0, hl_name, { bg = hex, fg = fg })
  elseif highlight_mode == "foreground" then
    vim.api.nvim_set_hl(0, hl_name, { fg = hex })
  else
    -- Virtual text uses foreground
    vim.api.nvim_set_hl(0, hl_name, { fg = hex })
  end

  return hl_name
end

-- ============================================================================
-- Buffer Highlighting
-- ============================================================================

---Highlight all colors in a buffer
---@param bufnr number? Buffer number (default: current)
function M.highlight_buffer(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- Clear existing highlights
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  -- Get config for swatch character (only needed for virtualtext mode)
  local swatch_char
  if highlight_mode == "virtualtext" then
    local config = require('nvim-colorpicker.config').get()
    swatch_char = (config.highlight and config.highlight.swatch_char) or '■'
  end

  -- Get all lines
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  for line_idx, line in ipairs(lines) do
    local line_num = line_idx - 1 -- 0-indexed

    -- Find all colors in line using detect module (has proper deduplication)
    local colors = detect.get_colors_in_line(line, line_idx)

    for _, color_info in ipairs(colors) do
      local hl_name = get_or_create_hl(color_info.color)

      if highlight_mode == "virtualtext" then
        -- Add virtual text swatch BEFORE the color
        vim.api.nvim_buf_set_extmark(bufnr, ns, line_num, color_info.start_col, {
          virt_text = { { swatch_char, hl_name } },
          virt_text_pos = "inline",
        })
      else
        -- Highlight the color text itself
        vim.api.nvim_buf_add_highlight(
          bufnr,
          ns,
          hl_name,
          line_num,
          color_info.start_col,
          color_info.end_col
        )
      end
    end
  end

  active_buffers[bufnr] = true
end

---Clear highlights from a buffer
---@param bufnr number? Buffer number (default: current)
function M.clear_buffer(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  active_buffers[bufnr] = nil
end

---Check if buffer has active highlighting
---@param bufnr number? Buffer number (default: current)
---@return boolean
function M.is_active(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  return active_buffers[bufnr] == true
end

---Toggle highlighting for current buffer
---@param bufnr number? Buffer number (default: current)
function M.toggle(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if M.is_active(bufnr) then
    M.clear_buffer(bufnr)
  else
    M.highlight_buffer(bufnr)
  end
end

-- ============================================================================
-- Configuration
-- ============================================================================

---Set highlight mode
---@param mode "background"|"foreground"|"virtualtext"
function M.set_mode(mode)
  if mode == "background" or mode == "foreground" or mode == "virtualtext" then
    highlight_mode = mode
    -- Re-highlight active buffers
    for bufnr, _ in pairs(active_buffers) do
      if vim.api.nvim_buf_is_valid(bufnr) then
        M.highlight_buffer(bufnr)
      else
        active_buffers[bufnr] = nil
      end
    end
  end
end

---Get current highlight mode
---@return string mode
function M.get_mode()
  return highlight_mode
end

-- ============================================================================
-- Auto-highlight Setup
-- ============================================================================

---@type number? Autocmd group id
local augroup = nil

---Check if buffer filetype should be highlighted based on config
---@param bufnr number Buffer number
---@return boolean should_highlight
local function should_highlight_buffer(bufnr)
  local config = require('nvim-colorpicker.config').get()
  local ft = vim.bo[bufnr].filetype

  -- Check exclude list first
  if config.highlight and config.highlight.exclude_filetypes then
    for _, excluded in ipairs(config.highlight.exclude_filetypes) do
      if ft == excluded then
        return false
      end
    end
  end

  -- Check filetypes setting
  if config.highlight and config.highlight.filetypes then
    if config.highlight.filetypes == '*' then
      return true
    elseif type(config.highlight.filetypes) == 'table' then
      for _, allowed in ipairs(config.highlight.filetypes) do
        if ft == allowed then
          return true
        end
      end
      return false
    end
  end

  return true
end

---Enable auto-highlighting for file patterns
---@param patterns string[]? File patterns (default: use config or common patterns)
function M.enable_auto(patterns)
  local config = require('nvim-colorpicker.config').get()

  -- Use config mode if set
  if config.highlight and config.highlight.mode then
    highlight_mode = config.highlight.mode
  end

  -- Build patterns from config or use defaults
  if not patterns then
    if config.highlight and config.highlight.filetypes == '*' then
      patterns = { '*' }
    elseif config.highlight and type(config.highlight.filetypes) == 'table' then
      -- Convert filetypes to patterns
      patterns = {}
      for _, ft in ipairs(config.highlight.filetypes) do
        table.insert(patterns, '*.' .. ft)
      end
    else
      patterns = {
        "*.css", "*.scss", "*.sass", "*.less",
        "*.html", "*.htm", "*.vue", "*.svelte",
        "*.jsx", "*.tsx", "*.js", "*.ts",
        "*.lua", "*.vim",
      }
    end
  end

  -- Create autocmd group
  if augroup then
    vim.api.nvim_del_augroup_by_id(augroup)
  end
  augroup = vim.api.nvim_create_augroup("NvimColorPickerHighlight", { clear = true })

  -- Add autocmds for each pattern
  vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI" }, {
    group = augroup,
    pattern = patterns,
    callback = function(ev)
      -- Check if this buffer should be highlighted
      if not should_highlight_buffer(ev.buf) then
        return
      end

      -- Debounce for TextChanged events
      if ev.event:match("TextChanged") then
        vim.defer_fn(function()
          if vim.api.nvim_buf_is_valid(ev.buf) then
            M.highlight_buffer(ev.buf)
          end
        end, 100)
      else
        M.highlight_buffer(ev.buf)
      end
    end,
  })

  -- Clean up on buffer delete
  vim.api.nvim_create_autocmd("BufDelete", {
    group = augroup,
    callback = function(ev)
      active_buffers[ev.buf] = nil
    end,
  })
end

---Setup highlight module with config
---Called automatically during plugin setup
function M.setup()
  local config = require('nvim-colorpicker.config').get()

  -- Apply mode from config
  if config.highlight and config.highlight.mode then
    highlight_mode = config.highlight.mode
  end

  -- Enable auto-highlight if configured
  if config.highlight and config.highlight.enable then
    M.enable_auto()
  end
end

---Disable auto-highlighting
function M.disable_auto()
  if augroup then
    vim.api.nvim_del_augroup_by_id(augroup)
    augroup = nil
  end
end

return M
