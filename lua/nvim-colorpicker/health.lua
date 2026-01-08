---@module nvim-colorpicker.health
---@brief Health check module for nvim-colorpicker
---
---Run with :checkhealth nvim-colorpicker

local M = {}

---Perform health checks for nvim-colorpicker
function M.check()
  vim.health.start("nvim-colorpicker")

  -- Check Neovim version
  local nvim_version = vim.version()
  local version_str = string.format("%d.%d.%d", nvim_version.major, nvim_version.minor, nvim_version.patch)

  if vim.fn.has("nvim-0.9.0") == 1 then
    vim.health.ok("Neovim version: " .. version_str)
  else
    vim.health.error("Neovim >= 0.9.0 required (found " .. version_str .. ")")
  end

  -- Check if plugin loaded
  if vim.g.loaded_nvim_colorpicker then
    vim.health.ok("Plugin loaded")
  else
    vim.health.warn("Plugin not loaded - check your plugin manager configuration")
  end

  -- Check if module loads
  local ok, colorpicker = pcall(require, "nvim-colorpicker")
  if not ok then
    vim.health.error("Failed to load nvim-colorpicker module")
    return
  end

  vim.health.ok("Module version: " .. (colorpicker.version or "unknown"))

  -- Check if setup was called
  if colorpicker.is_setup and colorpicker.is_setup() then
    vim.health.ok("Setup complete")
  else
    vim.health.info("Setup not called - using defaults (this is fine)")
  end

  -- Check nvim-float dependency
  local float_ok, nvim_float = pcall(require, "nvim-float")
  if float_ok then
    vim.health.ok("nvim-float dependency: " .. (nvim_float.version or "loaded"))
  else
    vim.health.error("nvim-float dependency not found - install mikevskater/nvim-float")
  end

  -- Check termguicolors
  if vim.o.termguicolors then
    vim.health.ok("termguicolors enabled")
  else
    vim.health.warn("termguicolors not enabled - colors may not display correctly")
  end

  -- Check commands exist
  local commands = {
    "ColorPicker",
    "ColorPickerAtCursor",
    "ColorPickerMini",
    "ColorConvert",
    "ColorHighlight",
  }
  local missing_commands = {}
  for _, cmd in ipairs(commands) do
    if vim.fn.exists(":" .. cmd) ~= 2 then
      table.insert(missing_commands, cmd)
    end
  end

  if #missing_commands == 0 then
    vim.health.ok("All commands registered")
  else
    vim.health.warn("Missing commands: " .. table.concat(missing_commands, ", "))
  end

  -- Check configuration
  local config_ok, config = pcall(require, "nvim-colorpicker.config")
  if config_ok then
    local cfg = config.get()
    vim.health.ok("Configuration loaded")

    -- Report highlight settings
    if cfg.highlight and cfg.highlight.enable then
      vim.health.info("Auto-highlighting: enabled (mode: " .. (cfg.highlight.mode or "background") .. ")")
    else
      vim.health.info("Auto-highlighting: disabled")
    end

    -- Report loaded presets
    if cfg.presets and #cfg.presets > 0 then
      vim.health.info("Loaded presets: " .. table.concat(cfg.presets, ", "))
    end
  else
    vim.health.warn("Could not load config module")
  end

  -- Check color submodules
  local submodules = { "color", "detect", "picker", "highlight" }
  local failed_modules = {}
  for _, mod in ipairs(submodules) do
    local mod_ok = pcall(require, "nvim-colorpicker." .. mod)
    if not mod_ok then
      table.insert(failed_modules, mod)
    end
  end

  if #failed_modules == 0 then
    vim.health.ok("All core modules loaded")
  else
    vim.health.error("Failed to load modules: " .. table.concat(failed_modules, ", "))
  end
end

return M
