local M = {}

local base = require('andrew.plugins.custom.shifty.languages.base')
local utils = require('andrew.plugins.custom.shifty.utils')

-- Language metadata
local metadata = {
  name = "python",
  version = "1.0.0",
  file_extensions = {".py", ".python"},
  executable_check = "python3 --version",
  aliases = {"py", "python3"}
}

-- Create the Python language module
local function create_python_module(config)
  config = config or {}
  
  local module = base.create_base_module(metadata, config)
  
  -- Override execute_code with Python-specific implementation
  module.execute_code = function(code, context)
    return M.execute_python_code(module, code, context)
  end
  
  -- Override setup_environment with Python-specific setup
  module.setup_environment = function(config)
    return M.setup_python_environment(module, config)
  end
  
  -- Override get_capabilities with Python-specific capabilities
  module.get_capabilities = function()
    return M.get_python_capabilities(module)
  end
  
  -- Override health_check with Python-specific health check
  module.health_check = function()
    return M.health_check_python(module)
  end
  
  -- Override cleanup with Python-specific cleanup
  module.cleanup = function()
    return M.cleanup_python(module)
  end
  
  return module
end

-- Execute Python code
---@param module BaseLanguageModule The language module
---@param code string The code to execute
---@param context table Execution context
---@return table result The execution result
function M.execute_python_code(module, code, context)
  context = context or {}
  
  local result = {
    success = false,
    output = "",
    error = nil,
    execution_time = 0,
    metadata = {}
  }
  
  -- Validate code
  local valid, error_msg = base.validate_code(code, "python")
  if not valid then
    result.error = error_msg
    result.output = result.error
    return result
  end
  
  -- Check if environment is ready
  if not module.environment.ready then
    result.error = "Python environment not ready"
    result.output = result.error
    return result
  end
  
  local start_time = vim.loop.hrtime()
  
  -- Create temporary file for Python code
  local temp_file = os.tmpname() .. ".py"
  local file = io.open(temp_file, "w")
  if not file then
    result.error = "Failed to create temporary file"
    result.output = result.error
    return result
  end
  
  -- Write code to file
  file:write(code)
  file:close()
  
  -- Execute Python code
  local command = string.format("%s %s", module.environment.executable, temp_file)
  local output = ""
  local error_output = ""
  
  -- Use vim.fn.system to execute the command
  local output = vim.fn.system(command)
  local exit_code = vim.v.shell_error
  local output_lines = vim.split(output, "\n")
  
  -- Clean up temporary file
  os.remove(temp_file)
  
  local end_time = vim.loop.hrtime()
  result.execution_time = (end_time - start_time) / 1000000  -- Convert to milliseconds
  
  -- Process output
  if exit_code == 0 then
    result.success = true
    result.output = table.concat(output_lines, "\n")
    
    -- Remove empty lines at the end
    result.output = result.output:gsub("\n*$", "")
    
    if result.output == "" then
      result.output = "✓ Executed successfully (no output)"
    end
    
    -- Add metadata
    result.metadata = {
      language = "python",
      version = module.environment.python_version,
      execution_mode = "subprocess",
      environment_ready = module.environment.ready
    }
  else
    result.success = false
    result.error = "Python execution failed"
    result.output = "Error: " .. table.concat(output_lines, "\n")
  end
  
  return result
end

-- Setup Python environment
---@param module BaseLanguageModule The language module
---@param config table Configuration for environment setup
---@return boolean success Whether setup was successful
function M.setup_python_environment(module, config)
  config = config or {}
  
  -- Call base setup first
  local base_success = base.setup_environment(module, config)
  if not base_success then
    return false
  end
  
  -- Get Python version
  local version_output = vim.fn.system(module.metadata.executable_check)
  local version = version_output:match("Python (%d+%.%d+%.%d+)")
  
  if not version then
    -- Try alternative version formats
    version = version_output:match("Python (%d+%.%d+)")
  end
  
  if not version then
    utils.log("Failed to get Python version", "error")
    return false
  end
  
  -- Set up Python-specific environment
  module.environment.python_version = version
  module.environment.executable = config.interpreter or "python3"
  module.environment.venv_support = config.venv_support or false
  
  -- Check for virtual environment support
  if module.environment.venv_support then
    local venv_check = vim.fn.system("python3 -c 'import venv' 2>/dev/null")
    module.environment.venv_available = vim.v.shell_error == 0
  end
  
  utils.log(string.format("Python environment setup complete (v%s)", version), "info")
  return true
end

-- Get Python capabilities
---@param module BaseLanguageModule The language module
---@return table capabilities The Python capabilities
function M.get_python_capabilities(module)
  local base_capabilities = base.get_capabilities(module)
  
  return vim.tbl_extend("force", base_capabilities, {
    python_version = module.environment.python_version,
    executable = module.environment.executable,
    venv_support = module.environment.venv_support,
    venv_available = module.environment.venv_available,
    subprocess_execution = true,
    file_based_execution = true,
    timeout_support = true
  })
end

-- Health check for Python
---@param module BaseLanguageModule The language module
---@return boolean healthy Whether Python is healthy
function M.health_check_python(module)
  -- Call base health check first
  if not base.health_check(module) then
    return false
  end
  
  -- Check Python-specific health
  if not module.environment.python_version then
    return false
  end
  
  -- Test basic Python functionality
  local test_code = "print('Hello, World!')"
  local temp_file = os.tmpname() .. ".py"
  local file = io.open(temp_file, "w")
  
  if not file then
    return false
  end
  
  file:write(test_code)
  file:close()
  
  local command = string.format("%s %s", module.environment.executable, temp_file)
  local exit_code = vim.fn.system(command)
  
  -- Clean up
  os.remove(temp_file)
  
  return exit_code == 0
end

-- Cleanup Python environment
---@param module BaseLanguageModule The language module
function M.cleanup_python(module)
  -- Call base cleanup
  base.cleanup(module)
  
  -- Python-specific cleanup (if any)
  module.environment.python_version = nil
  module.environment.executable = nil
  module.environment.venv_support = nil
  module.environment.venv_available = nil
end

-- Create and return the Python language module
local python_module = create_python_module()

return python_module 