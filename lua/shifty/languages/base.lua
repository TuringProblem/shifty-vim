local M = {}

---@class BaseLanguageModule
---@field metadata LanguageMetadata Language metadata
---@field config table Language-specific configuration
---@field environment table Execution environment
---@field capabilities table Language capabilities

-- Create a new base language module
---@param metadata LanguageMetadata The language metadata
---@param config table|nil Language-specific configuration
---@return BaseLanguageModule module The base language module
function M.create_base_module(metadata, config)
	local module = {
		metadata = metadata,
		config = config or {},
		environment = {},
		capabilities = {},
	}

	-- Set up the module with required interface
	module.execute_code = function(code, context)
		return M.execute_code(module, code, context)
	end

	module.setup_environment = function(config)
		return M.setup_environment(module, config)
	end

	module.get_capabilities = function()
		return M.get_capabilities(module)
	end

	module.health_check = function()
		return M.health_check(module)
	end

	module.cleanup = function()
		return M.cleanup(module)
	end

	return module
end

-- Default implementation of execute_code
---@param module BaseLanguageModule The language module
---@param code string The code to execute
---@param context table Execution context
---@return table result The execution result
function M.execute_code(module, code, context)
	context = context or {}

	local result = {
		success = false,
		output = "",
		error = nil,
		execution_time = 0,
		metadata = {},
	}

	if not module.environment.ready then
		result.error = string.format("Environment not ready for language '%s'", module.metadata.name)
		result.output = result.error
		return result
	end

	result.error = string.format("execute_code not implemented for language '%s'", module.metadata.name)
	result.output = result.error

	return result
end

-- Default implementation of setup_environment
---@param module BaseLanguageModule The language module
---@param config table Configuration for environment setup
---@return boolean success Whether setup was successful
function M.setup_environment(module, config)
	config = config or {}

	-- Merge configuration
	module.config = vim.tbl_deep_extend("force", module.config, config)

	-- Check if language executable is available
	local executable_available = M.check_executable(module)
	if not executable_available then
		vim.notify(
			string.format("Shifty: Executable check failed for language '%s'", module.metadata.name),
			vim.log.levels.ERROR
		)
		return false
	end

	module.environment = {
		ready = true,
		executable = module.metadata.executable_check:match("^([%w%-]+)"),
		config = module.config,
		created_at = os.time(),
	}

	return true
end

-- Default implementation of get_capabilities
---@param module BaseLanguageModule The language module
---@return table capabilities The language capabilities
function M.get_capabilities(module)
	return {
		name = module.metadata.name,
		version = module.metadata.version,
		file_extensions = module.metadata.file_extensions,
		aliases = module.metadata.aliases or {},
		environment_ready = module.environment.ready or false,
		executable_available = M.check_executable(module),
		base_module = true,
	}
end

-- Default implementation of health_check
---@param module BaseLanguageModule The language module
---@return boolean healthy Whether the language is healthy
function M.health_check(module)
	-- Check if environment is ready
	if not module.environment.ready then
		return false
	end

	-- Check if executable is available
	if not M.check_executable(module) then
		return false
	end

	-- Check if metadata is valid
	if not module.metadata or not module.metadata.name then
		return false
	end

	return true
end

-- Default implementation of cleanup
---@param module BaseLanguageModule The language module
function M.cleanup(module)
	if module.environment then
		module.environment.ready = false
	end

	-- Clear any cached data
	module.environment = {}
end

-- Check if the language executable is available
---@param module BaseLanguageModule The language module
---@return boolean available Whether the executable is available
function M.check_executable(module)
	if not module.metadata.executable_check then
		return false
	end

	-- Extract the command from executable_check
	local command = module.metadata.executable_check:match("^([%w%-]+)")
	if not command then
		return false
	end

	if command == "lua" then
		return true
	end

	-- Check if command exists using vim.fn.executable
	return vim.fn.executable(command) == 1
end

-- Utility function to create a safe execution environment
---@param module BaseLanguageModule The language module
---@param context table Execution context
---@return table env The safe execution environment
function M.create_safe_environment(module, context)
	context = context or {}

	local env = {
		-- Basic environment variables
		language = module.metadata.name,
		version = module.metadata.version,
		config = module.config,

		-- Execution context
		timeout = context.timeout or 5000,
		capture_output = context.capture_output ~= false,
		safe_mode = context.safe_mode ~= false,

		-- Utility functions
		log = function(message, level)
			vim.notify(string.format("[%s] %s", module.metadata.name, message), level or vim.log.levels.INFO)
		end,

		inspect = function(obj)
			return vim.inspect(obj)
		end,
	}

	return env
end

-- Utility function to handle execution timeout
---@param func function The function to execute
---@param timeout_ms number Timeout in milliseconds
---@return boolean success Whether execution was successful
---@return any result The execution result or error
function M.execute_with_timeout(func, timeout_ms)
	timeout_ms = timeout_ms or 5000

	-- For now, use simple pcall
	-- In a more advanced implementation, you might use coroutines or separate threads
	local success, result = pcall(func)
	return success, result
end

-- Utility function to capture output
---@param module BaseLanguageModule The language module
---@param capture_func function Function that captures output
---@return table captured_output The captured output
function M.capture_output(module, capture_func)
	local output = {}

	-- Create a capture function
	local function capture(...)
		local args = { ... }
		local output_parts = {}

		for i, arg in ipairs(args) do
			table.insert(output_parts, tostring(arg))
		end

		local output_line = table.concat(output_parts, "\t")
		table.insert(output, output_line)
	end

	-- Execute the capture function
	local success, result = pcall(capture_func, capture)

	if not success then
		table.insert(output, string.format("Error: %s", result or "unknown error"))
	end

	return {
		output = table.concat(output, "\n"),
		success = success,
		result = result,
	}
end

-- Utility function to validate code block
---@param code string The code to validate
---@param language string The language name
---@return boolean valid Whether the code is valid
---@return string|nil error Error message if invalid
function M.validate_code(code, language)
	if not code or type(code) ~= "string" then
		return false, "Code must be a non-empty string"
	end

	if code:match("^%s*$") then
		return false, "Code cannot be empty or whitespace only"
	end

	if not language or type(language) ~= "string" then
		return false, "Language must be specified"
	end

	return true
end

return M

