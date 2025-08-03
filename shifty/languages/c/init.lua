local M = {}

local base = require("andrew.plugins.custom.shifty.languages.base")
local utils = require("andrew.plugins.custom.shifty.utils")

-- Language metadata
local metadata = {
	name = "c",
	version = "1.0.0",
	file_extensions = { ".c", ".h" },
	executable_check = "gcc --version", -- Will be updated during setup
	aliases = { "c", "gcc", "clang" },
}

-- Create the C language module
local function create_c_module(config)
	config = config or {}

	local module = base.create_base_module(metadata, config)

	-- Override execute_code with C-specific implementation
	module.execute_code = function(code, context)
		return M.execute_c_code(module, code, context)
	end

	-- Override setup_environment with C-specific setup
	module.setup_environment = function(config)
		return M.setup_c_environment(module, config)
	end

	-- Override get_capabilities with C-specific capabilities
	module.get_capabilities = function()
		return M.get_c_capabilities(module)
	end

	-- Override health_check with C-specific health check
	module.health_check = function()
		return M.health_check_c(module)
	end

	-- Override cleanup with C-specific cleanup
	module.cleanup = function()
		return M.cleanup_c(module)
	end

	return module
end

-- Validate C code semantics
---@param code string The C code to validate
---@return boolean valid Whether the code is semantically valid
---@return string|nil error Error message if invalid
---@return table suggestions Suggestions for fixing the code

function M.validate_c_semantics(code)
	local suggestions = {}
	local warnings = {}

	-- Check for required elements
	if not code:match("int%s+main%s*%(") and not code:match("void%s+main%s*%(") then
		table.insert(suggestions, "Add 'int main()' function as entry point")
		table.insert(warnings, "No main function found")
	end

	-- Common header validation
	local common_headers_v2 = {
		["#include <stdio.h>"] = {
			scanf = true,
		},
		["#include <stdlib.h>"] = {
			malloc = true,
			free = true,
			rand = true,
			exit = true,
		},
		["#include <string.h>"] = {
			strlen = true,
			strcpy = true,
			strcmp = true,
		},
		["#include <math.h>"] = {
			sqrt = true,
			sin = true,
			cos = true,
			pow = true,
		},
		["#include <time.h>"] = {
			time = true,
		},
	}

	for header, functions in pairs(common_headers_v2) do
		for func in pairs(functions) do
			if code:match(func .. "%s*%(") and not code:match(header) then
				table.insert(suggestions, string.format("Add '%s' for %s() function", header, func))
				table.insert(warnings, string.format("Function %s() used without %s", func, header))
			end
		end
	end

	if code:match("int%s+main") and not code:match("return%s+[^;]+;") then
		table.insert(suggestions, "Add 'return 0;' at the end of main function")
		table.insert(warnings, "int main() should return a value")
	end

	local lines = vim.split(code, "\n")
	for i, line in ipairs(lines) do
		local trimmed = vim.trim(line)
		if trimmed ~= "" and not trimmed:match("^#") and not trimmed:match("^//") and not trimmed:match("^/%*") then
			if
				trimmed:match("[a-zA-Z_][a-zA-Z0-9_]*%s*%(")
				and not trimmed:match(";%s*$")
				and not trimmed:match("{%s*$")
			then
				table.insert(suggestions, string.format("Line %d: Add semicolon at end of statement", i))
				table.insert(warnings, string.format("Line %d: Missing semicolon", i))
			end
		end
	end

	return #warnings == 0, table.concat(warnings, "; "), suggestions
end
-- Execute C code
---@param module BaseLanguageModule The language module
---@param code string The code to execute
---@param context table Execution context
---@return table result The execution result
function M.execute_c_code(module, code, context)
	context = context or {}

	local result = {
		success = false,
		output = "",
		error = nil,
		execution_time = 0,
		metadata = {},
	}

	-- Validate code
	local valid, error_msg = base.validate_code(code, "c")
	if not valid then
		result.error = error_msg
		result.output = result.error
		return result
	end

	-- Check if environment is ready
	if not module.environment.ready then
		result.error = "C environment not ready"
		result.output = result.error
		return result
	end

	-- Validate C semantics
	local semantically_valid, semantic_error, suggestions = M.validate_c_semantics(code)

	local start_time = vim.loop.hrtime()

	-- Create temporary files
	local temp_c_file = os.tmpname() .. ".c"
	local temp_exe_file = os.tmpname()

	local file = io.open(temp_c_file, "w")
	if not file then
		result.error = "Failed to create temporary C file"
		result.output = result.error
		return result
	end

	-- Write code to file
	file:write(code)
	file:close()

	-- Compile the C code
	local compile_command = string.format("%s -o %s %s", module.environment.compiler, temp_exe_file, temp_c_file)
	local compile_output = vim.fn.system(compile_command)
	local compile_success = vim.v.shell_error == 0

	if not compile_success then
		result.success = false
		result.error = "Compilation failed"
		result.output = "Compilation Error:\n" .. compile_output

		-- Add semantic suggestions if compilation failed
		if not semantically_valid and #suggestions > 0 then
			result.output = result.output .. "\n\n💡 Suggestions:\n"
			for _, suggestion in ipairs(suggestions) do
				result.output = result.output .. "  • " .. suggestion .. "\n"
			end
		end

		-- Clean up
		os.remove(temp_c_file)
		return result
	end

	-- Execute the compiled program
	local exec_command = temp_exe_file
	local exec_output = vim.fn.system(exec_command)
	local exec_success = vim.v.shell_error == 0

	local end_time = vim.loop.hrtime()
	result.execution_time = (end_time - start_time) / 1000000 -- Convert to milliseconds

	-- Clean up temporary files
	os.remove(temp_c_file)
	os.remove(temp_exe_file)

	if exec_success then
		result.success = true
		result.output = exec_output

		-- Remove trailing newlines
		result.output = result.output:gsub("\n*$", "")

		if result.output == "" then
			result.output = "✓ Program executed successfully (no output)"
		end

		-- Add metadata
		result.metadata = {
			language = "c",
			version = module.environment.compiler_version,
			compiler = module.environment.compiler_name,
			execution_mode = "compiled",
			environment_ready = module.environment.ready,
			compilation_time = result.execution_time * 0.7, -- Rough estimate
			execution_time = result.execution_time * 0.3, -- Rough estimate
		}
	else
		result.success = false
		result.error = "Runtime error"
		result.output = "Runtime Error:\n" .. exec_output
	end

	-- Add semantic warnings even if successful
	if not semantically_valid and #suggestions > 0 then
		result.output = result.output .. "\n\n⚠️  Warnings:\n"
		for _, suggestion in ipairs(suggestions) do
			result.output = result.output .. "  • " .. suggestion .. "\n"
		end
	end

	return result
end

-- Setup C environment
---@param module BaseLanguageModule The language module
---@param config table Configuration for environment setup
---@return boolean success Whether setup was successful
function M.setup_c_environment(module, config)
	config = config or {}

	-- Detect available C compilers
	local compilers = {
		{ name = "gcc", check = "gcc --version", version_pattern = "gcc %(([^%)]+)%) ([%d%.]+)" },
		{ name = "clang", check = "clang --version", version_pattern = "clang version ([%d%.]+)" },
		{ name = "cc", check = "cc --version", version_pattern = "([%d%.]+)" },
	}

	local selected_compiler = nil
	local compiler_version = nil

	-- Try to find an available compiler
	for _, compiler in ipairs(compilers) do
		if vim.fn.executable(compiler.name) == 1 then
			local version_output = vim.fn.system(compiler.check)
			local version = version_output:match(compiler.version_pattern)

			if version then
				selected_compiler = compiler.name
				compiler_version = version
				break
			end
		end
	end

	if not selected_compiler then
		utils.log("No C compiler found (gcc, clang, or cc)", "error")
		return false
	end

	-- Update metadata for the detected compiler
	module.metadata.executable_check = selected_compiler .. " --version"

	-- Call base setup with updated metadata
	local base_success = base.setup_environment(module, config)
	if not base_success then
		return false
	end

	-- Set up C-specific environment
	module.environment.compiler_name = selected_compiler
	module.environment.compiler_version = compiler_version
	module.environment.compiler = config.compiler or selected_compiler

	-- Set appropriate flags based on compiler
	if selected_compiler == "clang" then
		module.environment.flags = config.flags or "-Wall -Wextra -std=c99"
		module.environment.optimization = config.optimization or "-O0"
	else
		module.environment.flags = config.flags or "-Wall -Wextra -std=c99"
		module.environment.optimization = config.optimization or "-O0"
	end

	utils.log(string.format("C environment setup complete (%s %s)", selected_compiler, compiler_version), "info")
	return true
end

-- Get C capabilities
---@param module BaseLanguageModule The language module
---@return table capabilities The C capabilities
function M.get_c_capabilities(module)
	local base_capabilities = base.get_capabilities(module)

	return vim.tbl_extend("force", base_capabilities, {
		compiler_name = module.environment.compiler_name,
		compiler_version = module.environment.compiler_version,
		compiler = module.environment.compiler,
		flags = module.environment.flags,
		optimization = module.environment.optimization,
		compiled_execution = true,
		semantic_validation = true,
		header_detection = true,
		error_suggestions = true,
	})
end

-- Health check for C
---@param module BaseLanguageModule The language module
---@return boolean healthy Whether C is healthy
function M.health_check_c(module)
	-- Call base health check first
	if not base.health_check(module) then
		return false
	end

	-- Check C-specific health
	if not module.environment.compiler_version then
		return false
	end

	-- Test basic C compilation
	local test_code = [[
#include <stdio.h>
int main() {
    printf("Hello, World!\n");
    return 0;
}
]]

	local temp_file = os.tmpname() .. ".c"
	local temp_exe = os.tmpname()

	local file = io.open(temp_file, "w")
	if not file then
		return false
	end

	file:write(test_code)
	file:close()

	local compile_command = string.format("%s -o %s %s", module.environment.compiler, temp_exe, temp_file)
	local compile_success = vim.fn.system(compile_command)
	local success = vim.v.shell_error == 0

	-- Clean up
	os.remove(temp_file)
	if success then
		os.remove(temp_exe)
	end

	return success
end

-- Cleanup C environment
---@param module BaseLanguageModule The language module
function M.cleanup_c(module)
	-- Call base cleanup
	base.cleanup(module)

	-- C-specific cleanup (if any)
	module.environment.compiler_name = nil
	module.environment.compiler_version = nil
	module.environment.compiler = nil
	module.environment.flags = nil
	module.environment.optimization = nil
end

-- Create and return the C language module
local c_module = create_c_module()

return c_module
