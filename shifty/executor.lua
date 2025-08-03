local M = {}
local utils = require('andrew.plugins.custom.shifty.utils')
local config = require('andrew.plugins.custom.shifty.config')

-- Captured output storage
local captured_output = {}

-- Custom print function that captures output
local function capture_print(...)
  local args = {...}
  local output_parts = {}
  
  for i, arg in ipairs(args) do
    table.insert(output_parts, tostring(arg))
  end
  
  local output_line = table.concat(output_parts, "\t")
  table.insert(captured_output, output_line)
end

-- Execute Lua code safely
function M.run_lua_code(code, name)
  name = name or "anonymous"
  captured_output = {}
  
  local result = {
    success = false,
    output = "",
    error = nil,
    execution_time = 0
  }
  
  -- Prepare execution environment
  local env = M.create_safe_environment()
  
  -- Override print if capture is enabled
  if config.get("execution.capture_print") then
    env.print = capture_print
  end
  
  local start_time = vim.loop.hrtime()
  
  -- Compile the code
  local chunk, compile_error = load(code, name, "t", env)
  
  if not chunk then
    result.error = "Compilation error: " .. (compile_error or "unknown error")
    result.output = result.error
    return result
  end
  
  -- Execute with timeout protection
  local success, exec_result = M.execute_with_timeout(chunk, config.get("execution.timeout"))
  
  local end_time = vim.loop.hrtime()
  result.execution_time = (end_time - start_time) / 1000000  -- Convert to milliseconds
  
  if success then
    result.success = true
    result.output = table.concat(captured_output, "\n")
    
    -- If no output was captured and there's a return value, show it
    if #captured_output == 0 and exec_result ~= nil then
      result.output = tostring(exec_result)
    end
    
    -- If still no output, show success message
    if result.output == "" then
      result.output = "✓ Executed successfully (no output)"
    end
  else
    result.error = exec_result or "Execution failed"
    result.output = "Error: " .. result.error
  end
  
  return result
end

-- Create a safe execution environment
function M.create_safe_environment()
  local env = {
    -- Basic Lua functions
    assert = assert,
    error = error,
    ipairs = ipairs,
    next = next,
    pairs = pairs,
    pcall = pcall,
    print = print,
    select = select,
    tonumber = tonumber,
    tostring = tostring,
    type = type,
    unpack = unpack or table.unpack,
    xpcall = xpcall,
    
    -- String library
    string = string,
    
    -- Table library  
    table = table,
    
    -- Math library
    math = math,
    
    -- OS library (limited)
    os = {
      clock = os.clock,
      date = os.date,
      time = os.time,
      difftime = os.difftime
    },
    
    -- Coroutine library
    coroutine = coroutine,
    
    -- UTF8 library (if available)
    utf8 = utf8,
    
    -- Custom utilities
    inspect = function(obj)
      return vim.inspect(obj)
    end,
    
    -- Neovim API access (limited)
    vim = {
      inspect = vim.inspect,
      tbl_extend = vim.tbl_extend,
      tbl_deep_extend = vim.tbl_deep_extend,
      split = vim.split,
      trim = vim.trim,
      startswith = vim.startswith,
      endswith = vim.endswith
    }
  }
  
  -- Set up metatable for global access
  setmetatable(env, {
    __index = function(t, k)
      -- Allow access to safe globals
      local safe_globals = {
        _VERSION = _VERSION,
        _G = env  -- Self-reference
      }
      return safe_globals[k]
    end
  })
  
  return env
end

-- Execute function with timeout
function M.execute_with_timeout(func, timeout_ms)
  timeout_ms = timeout_ms or 5000
  
  -- For now, we'll use a simple pcall
  -- In a more advanced implementation, you might use coroutines
  -- or a separate thread for timeout handling
  
  local success, result = pcall(func)
  return success, result
end

return M
