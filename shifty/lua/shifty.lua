local M = {}

-- Try to load modules with fallback paths for different package managers
local function safe_require(module_name, fallback_paths)
    local success, module = pcall(require, module_name)
    if success then
        return module
    end
    
    -- Try fallback paths if provided
    if fallback_paths then
        for _, path in ipairs(fallback_paths) do
            success, module = pcall(require, path)
            if success then
                return module
            end
        end
    end
    
    error("Failed to load module: " .. module_name)
end

-- Load modules with fallback paths for different package manager structures
local config = safe_require('config', {'andrew.plugins.custom.shifty.config'})
local parser = safe_require('parser', {'andrew.plugins.custom.shifty.parser'})
local proxy = safe_require('proxy', {'andrew.plugins.custom.shifty.proxy'})
local ui = safe_require('ui', {'andrew.plugins.custom.shifty.ui'})
local utils = safe_require('utils', {'andrew.plugins.custom.shifty.utils'})
local languages = safe_require('languages', {'andrew.plugins.custom.shifty.languages'})

---@type {initialized: boolean, floating_win: number, current_output: string, history: {code: string, result: string, timestamp: string, line: number}[]}
local state = {
  initialized = false,
  floating_win = nil,
  current_output = "",
  history = {}
}

---@param opts {keymaps: {toggle: string, run: string, clear: string, close: string}, languages: table}
function M.setup(opts)
  opts = opts or {}
  config.setup(opts)
  
  -- Initialize language discovery system
  languages.init(opts.languages or {})
  
  -- Register user commands
  vim.api.nvim_create_user_command('ShiftyToggle', M.toggle, {})
  vim.api.nvim_create_user_command('ShiftyRun', M.run_current_block, {})
  vim.api.nvim_create_user_command('ShiftySmart', M.run_smart, {})
  vim.api.nvim_create_user_command('ShiftySelection', M.run_selection, {})
  vim.api.nvim_create_user_command('ShiftyContext', M.run_context, {})
  vim.api.nvim_create_user_command('ShiftyClear', M.clear_output, {})
  vim.api.nvim_create_user_command('ShiftyClose', M.close, {})
  vim.api.nvim_create_user_command('ShiftyInfo', M.show_info, {})
  
  if config.options.keymaps.toggle then
    vim.keymap.set('n', config.options.keymaps.toggle, M.toggle, { desc = 'Toggle Shifty window' })
  end
  
  if config.options.keymaps.run then
    vim.keymap.set('n', config.options.keymaps.run, M.run_current_block, { desc = 'Run current code block' })
  end
  
  if config.options.keymaps.clear then
    vim.keymap.set('n', config.options.keymaps.clear, M.clear_output, { desc = 'Clear Shifty output' })
  end
  
  state.initialized = true
  utils.log("Shifty initialized successfully", "info")
end

---@return void
function M.toggle()
  if not state.initialized then
    utils.log("Shifty not initialized. Run :lua require('shifty').setup()", "error")
    return
  end
  
  if state.floating_win and vim.api.nvim_win_is_valid(state.floating_win) then
    M.close()
  else
    M.open()
  end
end

---@return void
function M.open()
  state.floating_win = ui.create_floating_window()
  ui.setup_window_keymaps(state.floating_win)
  utils.log("Shifty window opened", "info")
end

---@return void
function M.close()
  if state.floating_win and vim.api.nvim_win_is_valid(state.floating_win) then
    vim.api.nvim_win_close(state.floating_win, true)
    state.floating_win = nil
    utils.log("Shifty window closed", "info")
  end
end

---@return void
function M.run_current_block()
  local current_buf = vim.api.nvim_get_current_buf()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)
  
  local code_block = parser.extract_code_block_at_cursor(lines, cursor_pos[1])
  
  if not code_block then
    utils.log("No code block found at cursor position", "warn")
    return
  end
  
  M.execute_code(code_block.code, code_block)
end

---@param code string
---@param block_info {start_line: number, language: string}
---@return void
function M.execute_code(code, block_info)
  if not state.floating_win or not vim.api.nvim_win_is_valid(state.floating_win) then
    M.open()
  end
  
  local language = block_info.language or "lua"
  local block_name = string.format("%s block (line %d)", language, block_info.start_line or 0)
  
  -- Execute through proxy system
  local result = proxy.execute_code({
    language = language,
    code = code,
    block_info = block_info,
    config = config.get("languages." .. language) or {},
    timeout = config.get("execution.timeout"),
    capture_output = config.get("execution.capture_print"),
    safe_mode = true
  })
  
  table.insert(state.history, {
    code = code,
    result = result,
    timestamp = os.date("%H:%M:%S"),
    line = block_info.start_line,
    language = language
  })
  
  state.current_output = result.output
  ui.update_output(state.floating_win, result, block_name)
  
  utils.log(string.format("Executed %s block at line %d - %s", 
           language, block_info.start_line or 0, result.success and "SUCCESS" or "ERROR"), 
           result.success and "info" or "error")
end

---@return void
function M.clear_output()
  state.current_output = ""
  if state.floating_win and vim.api.nvim_win_is_valid(state.floating_win) then
    ui.clear_output(state.floating_win)
  end
  utils.log("Output cleared", "info")
end

---@return {code: string, result: string, timestamp: string, line: number}[]
---@return void
function M.get_history()
  return state.history
end

---@return {initialized: boolean, floating_win: number, current_output: string, history: {code: string, result: string, timestamp: string, line: number}[]}
function M.get_state()
  return state
end

---@return void
function M.show_info()
  local system_info = proxy.get_system_info()
  local discovery_stats = languages.get_discovery_stats()
  
  local info_lines = {
    "🎯 Shifty Multi-Language REPL System",
    "=" .. string.rep("=", 40),
    "",
    "📊 System Information:",
    string.format("  Version: %s", system_info.version),
    string.format("  Healthy: %s", system_info.healthy and "✓" or "✗"),
    "",
    "🌍 Language Registry:",
    string.format("  Total Languages: %d", system_info.registry_stats.total_languages),
    string.format("  Healthy Languages: %d", system_info.registry_stats.healthy_languages),
    string.format("  Total Aliases: %d", system_info.registry_stats.total_aliases),
    "",
    "📈 Performance Statistics:",
    string.format("  Total Executions: %d", system_info.performance_stats.total_executions),
    string.format("  Successful: %d", system_info.performance_stats.successful_executions),
    string.format("  Failed: %d", system_info.performance_stats.failed_executions),
    string.format("  Average Time: %.2fms", system_info.performance_stats.average_execution_time),
    "",
    "🔍 Available Languages:",
  }
  
  for _, language in ipairs(system_info.available_languages) do
    local capabilities = proxy.get_language_capabilities(language)
    local status = capabilities and "✓" or "✗"
    table.insert(info_lines, string.format("  %s %s", status, language))
  end
  
  -- Create a floating window to display the info
  local width = 60
  local height = #info_lines + 2
  
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, info_lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')
  
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = 'minimal',
    border = 'rounded',
    title = ' Shifty Info ',
    title_pos = 'center'
  })
  
  -- Close on any key
  vim.keymap.set('n', '<Esc>', function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, noremap = true })
  
  vim.keymap.set('n', 'q', function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, noremap = true })
end

-- Placeholder functions for backward compatibility
function M.run_smart()
  M.run_current_block()
end

function M.run_selection()
  -- TODO: Implement selection-based execution
  utils.log("Selection-based execution not yet implemented", "warn")
end

function M.run_context()
  -- TODO: Implement context-based execution
  utils.log("Context-based execution not yet implemented", "warn")
end

return M 