local M = {}

local config = require('shifty.config')
local parser = require('shifty.parser')
local proxy = require('shifty.proxy')
local ui = require('shifty.ui')
local utils = require('shifty.utils')
local languages = require('shifty.languages')
local detector = require('shifty.detector')
local invisible_ui = require('shifty.invisible_ui')

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

  languages.init(opts.languages or {})

  invisible_ui.init()

  vim.api.nvim_create_user_command('ShiftyToggle', M.toggle, {})
  vim.api.nvim_create_user_command('ShiftyRun', M.run_current_block, {})
  vim.api.nvim_create_user_command('ShiftySmart', M.run_smart, {})
  vim.api.nvim_create_user_command('ShiftySelection', M.run_selection, {})
  vim.api.nvim_create_user_command('ShiftyContext', M.run_context, {})
  vim.api.nvim_create_user_command('ShiftyClear', M.clear_output, {})
  vim.api.nvim_create_user_command('ShiftyClose', M.close, {})
  vim.api.nvim_create_user_command('ShiftyInfo', M.show_info, {})
  vim.api.nvim_create_user_command('ShiftyDetect', M.detect_language, {})
  vim.api.nvim_create_user_command('ShiftyMagic', M.run_magic_execution, {})

  if config.options.keymaps.toggle then
    vim.keymap.set('n', config.options.keymaps.toggle, M.toggle, { desc = 'Toggle Shifty window' })
  end

  if config.options.keymaps.run then
    vim.keymap.set('n', config.options.keymaps.run, M.run_current_block, { desc = 'Run current code block' })
  end

  if config.options.keymaps.smart then
    vim.keymap.set('n', config.options.keymaps.smart, M.run_smart, { desc = 'Smart execute (selection/block/context)' })
  end

  if config.options.keymaps.selection then
    vim.keymap.set('v', config.options.keymaps.selection, M.run_selection, { desc = 'Execute selected code' })
  end

  if config.options.keymaps.context then
    vim.keymap.set('n', config.options.keymaps.context, M.run_context, { desc = 'Execute current line/context' })
  end

  if config.options.keymaps.clear then
    vim.keymap.set('n', config.options.keymaps.clear, M.clear_output, { desc = 'Clear Shifty output' })
  end

  if config.options.keymaps.close then
    vim.keymap.set('n', config.options.keymaps.close, M.close, { desc = 'Close Shifty window' })
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

---@return void
function M.run_smart()
  local current_buf = vim.api.nvim_get_current_buf()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)

  local code_info = parser.extract_code_smart(current_buf, cursor_pos[1])

  if not code_info then
    utils.log("No code found to execute. Try selecting code or placing cursor in a code block.", "warn")
    return
  end

  M.execute_code(code_info.code, code_info)
end

---@return void
function M.run_selection()
  local current_buf = vim.api.nvim_get_current_buf()
  local code_info = parser.extract_selected_code(current_buf)

  if not code_info then
    utils.log("No text selected. Select code in visual mode first.", "warn")
    return
  end

  M.execute_code(code_info.code, code_info)
end

---@return void
function M.run_context()
  local current_buf = vim.api.nvim_get_current_buf()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)

  local code_info = parser.extract_context_code(current_buf, cursor_pos[1])

  if not code_info then
    utils.log("No executable code found at cursor position.", "warn")
    return
  end

  M.execute_code(code_info.code, code_info)
end

---@param code string
---@param block_info {start_line: number, language: string, source?: string}
---@return void
function M.execute_code(code, block_info)
  if not state.floating_win or not vim.api.nvim_win_is_valid(state.floating_win) then
    M.open()
  end

  local language = block_info.language or "lua"
  local source = block_info.source or "unknown"

  local block_name
  if source == "selection" then
    block_name = string.format("%s selection (lines %d-%d)", language, block_info.start_line, block_info.end_line)
  elseif source == "fenced_block" then
    block_name = string.format("%s block (line %d)", language, block_info.start_line)
  elseif source == "context_line" then
    block_name = string.format("%s line %d", language, block_info.start_line)
  else
    block_name = string.format("%s code (line %d)", language, block_info.start_line or 0)
  end

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
    language = language,
    source = source
  })

  state.current_output = result.output
  ui.update_output(state.floating_win, result, block_name)

  utils.log(string.format("Executed %s %s at line %d - %s",
      language, source, block_info.start_line or 0, result.success and "SUCCESS" or "ERROR"),
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

-- Magic execution: Auto-detect language and execute seamlessly
---@return void
function M.run_magic_execution()
  if not state.initialized then
    utils.log("Shifty not initialized. Run :lua require('shifty').setup()", "error")
    return
  end

  local current_buf = vim.api.nvim_get_current_buf()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)

  -- Try to extract code with intelligent detection
  local code_info = parser.extract_code_smart(current_buf, cursor_pos[1])

  if not code_info then
    utils.log("No code found to execute. Try selecting code or placing cursor in a code block.", "warn")
    return
  end

  -- Check if we have sufficient confidence for automatic execution
  if code_info.confidence and not detector.is_confidence_sufficient(code_info.confidence) then
    -- Show language selection dialog for low confidence
    M.show_language_selection_dialog(code_info)
    return
  end

  -- Execute with invisible processing
  M.execute_code_magically(code_info)
end

-- Execute code using invisible window system
---@param code_info table Code information with detection results
---@return void
function M.execute_code_magically(code_info)
  -- Create processor function for invisible execution
  local processor = function(context)
    -- Use the existing execution pipeline
    local result = proxy.execute_code({
      language = context.language,
      code = context.code,
      block_info = {
        language = context.language,
        start_line = code_info.start_line,
        end_line = code_info.end_line,
        source = code_info.source
      },
      config = config.get("languages." .. context.language) or {},
      timeout = config.get("execution.timeout"),
      capture_output = config.get("execution.capture_print"),
      safe_mode = true
    })

    return result
  end

  -- Process through invisible window system
  local result = invisible_ui.process_code_invisibly(
    code_info.code,
    code_info.language,
    processor,
    {
      confidence = code_info.confidence,
      source = code_info.source,
      alternatives = code_info.alternatives
    }
  )

  if not result then
    utils.log("Failed to execute code through invisible processing", "error")
    return
  end

  -- Update UI with results
  if not state.floating_win or not vim.api.nvim_win_is_valid(state.floating_win) then
    M.open()
  end

  -- Create descriptive block name
  local confidence_level = detector.get_confidence_level(code_info.confidence or 0)
  local block_name = string.format("%s %s (%.1f%% confidence, %s)",
    code_info.language, code_info.source,
    code_info.confidence or 0, confidence_level)

  -- Add to history
  table.insert(state.history, {
    code = code_info.code,
    result = result.output,
    timestamp = os.date("%H:%M:%S"),
    line = code_info.start_line,
    language = code_info.language,
    source = code_info.source,
    confidence = code_info.confidence
  })

  state.current_output = result.output
  ui.update_output(state.floating_win, result, block_name)

  utils.log(string.format("Magic execution: %s %s (%.1f%% confidence) - %s",
      code_info.language, code_info.source, code_info.confidence or 0,
      result.success and "SUCCESS" or "ERROR"),
    result.success and "info" or "error")
end

-- Show language selection dialog for low confidence detection
---@param code_info table Code information with alternatives
---@return void
function M.show_language_selection_dialog(code_info)
  local alternatives = code_info.alternatives or {}
  table.insert(alternatives, 1, {
    language = code_info.language,
    confidence = code_info.confidence
  })

  local lines = {
    "🔍 Language Detection - Low Confidence",
    "=" .. string.rep("=", 40),
    "",
    "Detected languages (please select one):",
    ""
  }

  for i, alt in ipairs(alternatives) do
    local confidence_level = detector.get_confidence_level(alt.confidence)
    table.insert(lines, string.format("%d. %s (%.1f%% - %s)",
      i, alt.language, alt.confidence, confidence_level))
  end

  table.insert(lines, "")
  table.insert(lines, "Press number to select, or <Esc> to cancel")

  -- Create selection window
  local width = 50
  local height = #lines + 2

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
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
    title = ' Language Selection ',
    title_pos = 'center'
  })

  -- Set up keymaps for selection
  for i = 1, #alternatives do
    vim.keymap.set('n', tostring(i), function()
      local selected_language = alternatives[i].language
      vim.api.nvim_win_close(win, true)

      -- Update code_info with selected language
      code_info.language = selected_language
      code_info.confidence = alternatives[i].confidence

      -- Execute with selected language
      M.execute_code_magically(code_info)
    end, { buffer = buf, noremap = true })
  end

  -- Close on escape
  vim.keymap.set('n', '<Esc>', function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, noremap = true })
end

-- Detect language of current code
---@return void
function M.detect_language()
  if not state.initialized then
    utils.log("Shifty not initialized. Run :lua require('shifty').setup()", "error")
    return
  end

  local current_buf = vim.api.nvim_get_current_buf()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)

  -- Extract code for detection
  local code_info = parser.extract_code_smart(current_buf, cursor_pos[1])

  if not code_info then
    utils.log("No code found to detect language.", "warn")
    return
  end

  -- Show detection results
  local lines = {
    "🔍 Language Detection Results",
    "=" .. string.rep("=", 40),
    "",
    string.format("Primary Detection: %s (%.1f%% confidence)",
      code_info.language, code_info.confidence or 0),
    "",
    "Detection Analysis:",
    string.format("  Total Lines: %d", code_info.detection_analysis.total_lines),
    string.format("  Code Length: %d characters", code_info.detection_analysis.code_length),
    string.format("  Context Used: %s", code_info.detection_analysis.context_used and "Yes" or "No"),
    ""
  }

  if code_info.alternatives and #code_info.alternatives > 0 then
    table.insert(lines, "Alternative Languages:")
    for _, alt in ipairs(code_info.alternatives) do
      table.insert(lines, string.format("  • %s (%.1f%% confidence)", alt.language, alt.confidence))
    end
    table.insert(lines, "")
  end

  table.insert(lines, "Supported Languages:")
  local supported = detector.get_supported_languages()
  for _, lang in ipairs(supported) do
    table.insert(lines, string.format("  • %s", lang))
  end

  -- Create info window
  local width = 60
  local height = #lines + 2

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
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
    title = ' Language Detection ',
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

---@return void
function M.show_info()
  local system_info = proxy.get_system_info()
  local discovery_stats = languages.get_discovery_stats()
  local invisible_stats = invisible_ui.get_invisible_window_stats()

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
    "🔍 Language Detection:",
    string.format("  Supported Languages: %d", #detector.get_supported_languages()),
    string.format("  Detection Patterns: %d", 6), -- python, js, java, c, rust, lua
    "",
    "👻 Invisible Windows:",
    string.format("  Active Windows: %d", invisible_stats.total_windows),
    string.format("  Background Processing: %s", invisible_stats.total_windows > 0 and "Active" or "Idle"),
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

  vim.keymap.set('n', '<Esc>', function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, noremap = true })

  vim.keymap.set('n', 'q', function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, noremap = true })
end

return M

