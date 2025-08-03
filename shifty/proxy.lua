local M = {}

local registry = require('andrew.plugins.custom.shifty.registry')
local utils = require('andrew.plugins.custom.shifty.utils')

---@class ExecutionContext
---@field language string The language name
---@field code string The code to execute
---@field block_info table Code block information
---@field config table Language-specific configuration
---@field timeout number Execution timeout in milliseconds
---@field capture_output boolean Whether to capture output
---@field safe_mode boolean Whether to run in safe mode

---@class ExecutionResult
---@field success boolean Whether execution was successful
---@field output string The execution output
---@field error string|nil Error message if execution failed
---@field execution_time number Execution time in milliseconds
---@field language string The language that was used
---@field metadata table Additional metadata

-- Performance monitoring
local performance_stats = {
  total_executions = 0,
  successful_executions = 0,
  failed_executions = 0,
  language_stats = {},
  average_execution_time = 0
}

-- Update performance statistics
---@param language string The language name
---@param success boolean Whether execution was successful
---@param execution_time number Execution time in milliseconds
local function update_performance_stats(language, success, execution_time)
  performance_stats.total_executions = performance_stats.total_executions + 1
  
  if success then
    performance_stats.successful_executions = performance_stats.successful_executions + 1
  else
    performance_stats.failed_executions = performance_stats.failed_executions + 1
  end
  
  -- Update language-specific stats
  if not performance_stats.language_stats[language] then
    performance_stats.language_stats[language] = {
      total = 0,
      successful = 0,
      failed = 0,
      total_time = 0,
      average_time = 0
    }
  end
  
  local lang_stats = performance_stats.language_stats[language]
  lang_stats.total = lang_stats.total + 1
  lang_stats.total_time = lang_stats.total_time + execution_time
  
  if success then
    lang_stats.successful = lang_stats.successful + 1
  else
    lang_stats.failed = lang_stats.failed + 1
  end
  
  lang_stats.average_time = lang_stats.total_time / lang_stats.total
  
  -- Update global average
  local total_time = 0
  local total_count = 0
  for _, stats in pairs(performance_stats.language_stats) do
    total_time = total_time + stats.total_time
    total_count = total_count + stats.total
  end
  
  if total_count > 0 then
    performance_stats.average_execution_time = total_time / total_count
  end
end

-- Execute code using the proxy system
---@param context ExecutionContext The execution context
---@return ExecutionResult result The execution result
function M.execute_code(context)
  local start_time = vim.loop.hrtime()
  
  local result = {
    success = false,
    output = "",
    error = nil,
    execution_time = 0,
    language = context.language,
    metadata = {}
  }
  
  -- Validate context
  if not context.language or not context.code then
    result.error = "Invalid execution context: missing language or code"
    result.output = result.error
    return result
  end
  
  -- Check if language is available
  if not registry.is_language_available(context.language) then
    result.error = string.format("Language '%s' is not available or not healthy", context.language)
    result.output = result.error
    return result
  end
  
  -- Get language module
  local language_module = registry.get_language(context.language)
  if not language_module then
    result.error = string.format("Failed to load language module for '%s'", context.language)
    result.output = result.error
    return result
  end
  
  -- Setup environment if needed
  local env_setup_success = pcall(function()
    return language_module.setup_environment(context.config or {})
  end)
  
  if not env_setup_success then
    result.error = string.format("Failed to setup environment for language '%s'", context.language)
    result.output = result.error
    return result
  end
  
  -- Execute code with error isolation
  local execution_success, execution_result = pcall(function()
    return language_module.execute_code(context.code, {
      timeout = context.timeout,
      capture_output = context.capture_output,
      safe_mode = context.safe_mode,
      block_info = context.block_info
    })
  end)
  
  local end_time = vim.loop.hrtime()
  result.execution_time = (end_time - start_time) / 1000000  -- Convert to milliseconds
  
  if execution_success then
    -- Validate execution result
    if type(execution_result) == "table" then
      result.success = execution_result.success or false
      result.output = execution_result.output or ""
      result.error = execution_result.error
      
      -- Copy additional metadata
      if execution_result.metadata then
        result.metadata = vim.tbl_extend("force", result.metadata, execution_result.metadata)
      end
    else
      result.success = false
      result.error = "Invalid execution result format"
      result.output = result.error
    end
  else
    result.success = false
    result.error = string.format("Execution failed: %s", execution_result or "unknown error")
    result.output = result.error
  end
  
  -- Update performance statistics
  update_performance_stats(context.language, result.success, result.execution_time)
  
  -- Log execution
  local log_level = result.success and "info" or "error"
  utils.log(string.format("Executed %s code - %s (%.2fms)", 
           context.language, result.success and "SUCCESS" or "ERROR", result.execution_time), 
           log_level)
  
  return result
end

-- Get language capabilities through proxy
---@param language_name string The language name
---@return table|nil capabilities The language capabilities or nil if not available
function M.get_language_capabilities(language_name)
  if not registry.is_language_available(language_name) then
    return nil
  end
  
  local capabilities = registry.get_language_capabilities(language_name)
  if not capabilities then
    return nil
  end
  
  -- Add proxy-specific capabilities
  capabilities.proxy_supported = true
  capabilities.performance_stats = performance_stats.language_stats[language_name] or {}
  
  return capabilities
end

-- Get all available languages
---@return string[] available_languages List of available language names
function M.get_available_languages()
  local available = {}
  local registered = registry.get_registered_languages()
  
  for _, language in ipairs(registered) do
    if registry.is_language_available(language) then
      table.insert(available, language)
    end
  end
  
  return available
end

-- Get performance statistics
---@return table stats Performance statistics
function M.get_performance_stats()
  return vim.deepcopy(performance_stats)
end

-- Reset performance statistics
function M.reset_performance_stats()
  performance_stats = {
    total_executions = 0,
    successful_executions = 0,
    failed_executions = 0,
    language_stats = {},
    average_execution_time = 0
  }
end

-- Health check for the proxy system
---@return boolean healthy Whether the proxy system is healthy
function M.health_check()
  local healthy = true
  local issues = {}
  
  -- Check registry health
  local stats = registry.get_statistics()
  if stats.total_languages == 0 then
    healthy = false
    table.insert(issues, "No languages registered")
  end
  
  if stats.healthy_languages == 0 then
    healthy = false
    table.insert(issues, "No healthy languages available")
  end
  
  -- Check performance stats integrity
  if performance_stats.total_executions < 0 then
    healthy = false
    table.insert(issues, "Invalid performance statistics")
  end
  
  if not healthy then
    utils.log("Proxy health check failed: " .. table.concat(issues, ", "), "error")
  end
  
  return healthy
end

-- Get proxy system information
---@return table info Proxy system information
function M.get_system_info()
  local stats = registry.get_statistics()
  local perf_stats = M.get_performance_stats()
  
  return {
    version = "1.0.0",
    registry_stats = stats,
    performance_stats = perf_stats,
    available_languages = M.get_available_languages(),
    healthy = M.health_check()
  }
end

return M 