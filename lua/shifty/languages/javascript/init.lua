local M = {}

local base = require("shifty.languages.base")
local utils = require("shifty.utils")

local metadata = {
	name = "javascript",
	version = "1.0.0",
	file_extensions = { ".js", ".javascript" },
	executable_check = "node --version",
	aliases = { "js", "node" },
}

local function create_javascript_module(config)
	config = config or {}

	local module = base.create_base_module(metadata, config)

	module.execute_code = function(code, context)
		return M.execute_javascript_code(module, code, context)
	end

	module.setup_environment = function(config)
		return M.setup_javascript_environment(module, config)
	end

	module.get_capabilities = function()
		return M.get_javascript_capabilities(module)
	end

	module.health_check = function()
		return M.health_check_javascript(module)
	end

	module.cleanup = function()
		return M.cleanup_javascript(module)
	end

	return module
end

---@param module BaseLanguageModule The language module
---@param code string The code to execute
---@param context table Execution context
---@return table result The execution result
function M.execute_javascript_code(module, code, context)
	context = context or {}

	local result = {
		success = false,
		output = "",
		error = nil,
		execution_time = 0,
		metadata = {},
	}

	local valid, error_msg = base.validate_code(code, "javascript")
	if not valid then
		result.error = error_msg
		result.output = result.error
		return result
	end

	if not module.environment.ready then
		result.error = "JavaScript environment not ready"
		result.output = result.error
		return result
	end

	local start_time = vim.loop.hrtime()

	local temp_file = os.tmpname() .. ".js"
	local file = io.open(temp_file, "w")
	if not file then
		result.error = "Failed to create temporary file"
		result.output = result.error
		return result
	end

	file:write(code)
	file:close()

	local command = string.format("%s %s", module.environment.executable, temp_file)
	local output = ""
	local error_output = ""

	local output = vim.fn.system(command)
	local exit_code = vim.v.shell_error
	local output_lines = vim.split(output, "\n")

	os.remove(temp_file)

	local end_time = vim.loop.hrtime()
	result.execution_time = (end_time - start_time) / 1000000

	if exit_code == 0 then
		result.success = true
		result.output = table.concat(output_lines, "\n")

		result.output = result.output:gsub("\n*$", "")

		if result.output == "" then
			result.output = "✓ Executed successfully (no output)"
		end

		result.metadata = {
			language = "javascript",
			version = module.environment.node_version,
			execution_mode = "subprocess",
			environment_ready = module.environment.ready,
		}
	else
		result.success = false
		result.error = "JavaScript execution failed"
		result.output = "Error: " .. table.concat(output_lines, "\n")
	end

	return result
end

---@param module BaseLanguageModule The language module
---@param config table Configuration for environment setup
---@return boolean success Whether setup was successful
function M.setup_javascript_environment(module, config)
	config = config or {}

	local base_success = base.setup_environment(module, config)
	if not base_success then
		return false
	end

	local version_output = vim.fn.system(module.metadata.executable_check)
	local version = version_output:match("v(%d+%.%d+%.%d+)")

	if not version then
		version = version_output:match("v(%d+%.%d+)")
	end

	if not version then
		utils.log("Failed to get Node.js version", "error")
		return false
	end

	module.environment.node_version = version
	module.environment.executable = config.runtime or "node"
	module.environment.npm_support = config.npm_support or false

	if module.environment.npm_support then
		local npm_check = vim.fn.system("npm --version 2>/dev/null")
		module.environment.npm_available = vim.v.shell_error == 0
	end

	utils.log(string.format("JavaScript environment setup complete (Node.js v%s)", version), "info")
	return true
end

-- Get JavaScript capabilities
---@param module BaseLanguageModule The language module
---@return table capabilities The JavaScript capabilities
function M.get_javascript_capabilities(module)
	local base_capabilities = base.get_capabilities(module)

	return vim.tbl_extend("force", base_capabilities, {
		node_version = module.environment.node_version,
		executable = module.environment.executable,
		npm_support = module.environment.npm_support,
		npm_available = module.environment.npm_available,
		subprocess_execution = true,
		file_based_execution = true,
		timeout_support = true,
	})
end

---@param module BaseLanguageModule The language module
---@return boolean healthy Whether JavaScript is healthy
function M.health_check_javascript(module)
	if not base.health_check(module) then
		return false
	end

	if not module.environment.node_version then
		return false
	end

	local test_code = "console.log('Hello, World!');"
	local temp_file = os.tmpname() .. ".js"
	local file = io.open(temp_file, "w")

	if not file then
		return false
	end

	file:write(test_code)
	file:close()

	local command = string.format("%s %s", module.environment.executable, temp_file)
	local exit_code = vim.fn.system(command)

	os.remove(temp_file)

	return exit_code == 0
end

---@param module BaseLanguageModule The language module
function M.cleanup_javascript(module)
	base.cleanup(module)

	module.environment.node_version = nil
	module.environment.executable = nil
	module.environment.npm_support = nil
	module.environment.npm_available = nil
end

local javascript_module = create_javascript_module()

return javascript_module

