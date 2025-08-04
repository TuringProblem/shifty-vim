local M = {}

local base = require("shifty.languages.base")
local utils = require("shifty.utils")

local metadata = {
	name = "lua",
	version = "1.0.0",
	file_extensions = { ".lua" },
	executable_check = "lua",
	aliases = { "lua" },
}

local function create_lua_module(config)
	config = config or {}

	local module = base.create_base_module(metadata, config)

	module.execute_code = function(code, context)
		return M.execute_lua_code(module, code, context)
	end

	module.setup_environment = function(config)
		return M.setup_lua_environment(module, config)
	end

	module.get_capabilities = function()
		return M.get_lua_capabilities(module)
	end

	module.health_check = function()
		return M.health_check_lua(module)
	end

	module.cleanup = function()
		return M.cleanup_lua(module)
	end

	return module
end

---@param module BaseLanguageModule The language module
---@param code string The code to execute
---@param context table Execution context
---@return table result The execution result
function M.execute_lua_code(module, code, context)
	context = context or {}

	local result = {
		success = false,
		output = "",
		error = nil,
		execution_time = 0,
		metadata = {},
	}

	local valid, error_msg = base.validate_code(code, "lua")
	if not valid then
		result.error = error_msg
		result.output = result.error
		return result
	end

	if not module.environment.ready then
		result.error = "Lua environment not ready"
		result.output = result.error
		return result
	end

	local start_time = vim.loop.hrtime()

	local env = M.create_lua_environment(module, context)

	local captured = base.capture_output(module, function(capture_print)
		if context.capture_output ~= false then
			env.print = capture_print
		end

		local chunk, compile_error = load(code, "lua_block", "t", env)

		if not chunk then
			error("Compilation error: " .. (compile_error or "unknown error"))
		end

		local success, exec_result = base.execute_with_timeout(chunk, context.timeout or 5000)

		if not success then
			error(exec_result or "Execution failed")
		end

		return exec_result
	end)

	local end_time = vim.loop.hrtime()
	result.execution_time = (end_time - start_time) / 1000000

	if captured.success then
		result.success = true
		result.output = captured.output

		if captured.output == "" and captured.result ~= nil then
			result.output = tostring(captured.result)
		end

		if result.output == "" then
			result.output = "✓ Executed successfully (no output)"
		end

		result.metadata = {
			language = "lua",
			version = _VERSION,
			execution_mode = "safe",
			environment_ready = module.environment.ready,
		}
	else
		result.success = false
		result.error = captured.output
		result.output = "Error: " .. result.error
	end

	return result
end

---@param module BaseLanguageModule The language module
---@param config table Configuration for environment setup
---@return boolean success Whether setup was successful
function M.setup_lua_environment(module, config)
	config = config or {}

	local base_success = base.setup_environment(module, config)
	if not base_success then
		return false
	end

	module.environment.lua_version = _VERSION
	module.environment.jit_available = jit ~= nil

	if jit then
		module.environment.jit_version = jit.version
		module.environment.jit_os = jit.os
		module.environment.jit_arch = jit.arch
	end

	utils.log("Lua environment setup complete", "info")
	return true
end

---@param module BaseLanguageModule The language module
---@return table capabilities The Lua capabilities
function M.get_lua_capabilities(module)
	local base_capabilities = base.get_capabilities(module)

	return vim.tbl_extend("force", base_capabilities, {
		lua_version = _VERSION,
		jit_available = jit ~= nil,
		jit_version = jit and jit.version or nil,
		jit_os = jit and jit.os or nil,
		jit_arch = jit and jit.arch or nil,
		safe_execution = true,
		output_capture = true,
		timeout_support = true,
		neovim_integration = true,
	})
end

---@param module BaseLanguageModule The language module
---@return boolean healthy Whether Lua is healthy
function M.health_check_lua(module)
	if not base.health_check(module) then
		return false
	end

	if not _VERSION then
		return false
	end

	local success = pcall(function()
		return 1 + 1 == 2
	end)

	if not success then
		return false
	end

	return true
end

---@param module BaseLanguageModule The language module
function M.cleanup_lua(module)
	base.cleanup(module)

	module.environment.lua_version = nil
	module.environment.jit_available = nil
	module.environment.jit_version = nil
	module.environment.jit_os = nil
	module.environment.jit_arch = nil
end

---@param module BaseLanguageModule The language module
---@param context table Execution context
---@return table env The safe execution environment
function M.create_lua_environment(module, context)
	local base_env = base.create_safe_environment(module, context)

	local env = vim.tbl_extend("force", base_env, {
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

		string = string,

		table = table,

		math = math,

		os = {
			clock = os.clock,
			date = os.date,
			time = os.time,
			difftime = os.difftime,
		},

		coroutine = coroutine,

		utf8 = utf8,

		inspect = function(obj)
			return vim.inspect(obj)
		end,

		vim = {
			inspect = vim.inspect,
			tbl_extend = vim.tbl_extend,
			tbl_deep_extend = vim.tbl_deep_extend,
			split = vim.split,
			trim = vim.trim,
			startswith = vim.startswith,
			endswith = vim.endswith,
		},
	})

	setmetatable(env, {
		__index = function(t, k)
			local safe_globals = {
				_VERSION = _VERSION,
				_G = env,
			}
			return safe_globals[k]
		end,
	})

	return env
end

local lua_module = create_lua_module()

return lua_module

