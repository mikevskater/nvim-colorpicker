---@module 'nvim-colorpicker.picker.actions'
---@brief Shared action handlers for apply/cancel/close operations

local State = require('nvim-colorpicker.picker.state')
local Grid = require('nvim-colorpicker.picker.grid')
local Preview = require('nvim-colorpicker.picker.preview')
local History = require('nvim-colorpicker.history')

local M = {}

-- ============================================================================
-- Result Building
-- ============================================================================

---Build result object from current state
---@return table result The result object with color, alpha, and custom values
function M.build_result()
  local state = State.state
  if not state then return {} end

  local result = vim.deepcopy(state.current)
  result.alpha = state.alpha_enabled and state.alpha or nil

  if state.options.custom_controls and #state.options.custom_controls > 0 then
    result.custom = vim.deepcopy(state.custom_values)
  end

  return result
end

-- ============================================================================
-- Apply Action
-- ============================================================================

---Execute apply action - saves to history, calls callback, then closes
---@param close_fn fun() Function to close the picker window
function M.apply(close_fn)
  local state = State.state
  if not state then return end

  local result = M.build_result()
  local on_select = state.options.on_select

  -- Add selected color to history (with alpha)
  if result.color then
    History.add_recent(result.color, result.alpha)
  end

  -- Close the picker
  close_fn()

  -- Call the callback after closing
  if on_select then
    on_select(result)
  end
end

-- ============================================================================
-- Cancel Action
-- ============================================================================

---Execute cancel action - notifies callbacks, then closes
---@param close_fn fun() Function to close the picker window
function M.cancel(close_fn)
  local state = State.state
  if not state then return end

  -- Notify on_change with original color (revert)
  if state.options.on_change then
    state.options.on_change(vim.deepcopy(state.original))
  end

  -- Notify on_cancel
  if state.options.on_cancel then
    state.options.on_cancel()
  end

  -- Close the picker
  close_fn()
end

-- ============================================================================
-- Close/Cleanup
-- ============================================================================

---Clean up highlight groups and state
---@param grid_height number? Grid height for cleanup (uses state default if nil)
---@param grid_width number? Grid width for cleanup (uses state default if nil)
function M.cleanup_highlights(grid_height, grid_width)
  local state = State.state
  grid_height = grid_height or (state and state.grid_height) or 20
  grid_width = grid_width or (state and state.grid_width) or 60

  Grid.clear_grid_highlights(grid_height, grid_width)
  Preview.clear_preview_highlights()
end

---Full cleanup including state and optional augroup
---@param augroup_name string? Optional augroup name to delete
function M.full_cleanup(augroup_name)
  local state = State.state
  if not state then return end

  local grid_height = state.grid_height or 20
  local grid_width = state.grid_width or 60

  -- Clear state first
  State.clear_state()

  -- Delete augroup if specified
  if augroup_name then
    pcall(vim.api.nvim_del_augroup_by_name, augroup_name)
  end

  -- Clean up highlights
  Grid.clear_grid_highlights(grid_height, grid_width)
  Preview.clear_preview_highlights()
end

-- ============================================================================
-- Render Scheduling
-- ============================================================================

---Create a simple render scheduler (schedules for next frame)
---@param render_fn fun() The render function to call
---@return fun() schedule_render Function to schedule a render
function M.create_render_scheduler(render_fn)
  return function()
    vim.schedule(render_fn)
  end
end

return M
