local M = {}

local base = require("andrew.plugins.custom.shifty.languages.base")
local utils = require("andrew.plugins.custom.shifty.utils")

-- Language metadata
local metadata = {
	name = "rust",
	version = "1.0.0",
	file_extensions = { ".rs" },
	executable_check = "rustc --version",
	aliases = { "rs", "rust" },
}

-- Create the Rust language module
local function create_rust_module(config)
	config = config or {}

	local module = base.create_base_module(metadata, config)

	-- Override execute_code with Rust-specific implementation
	module.execute_code = function(code, context)
		return M.execute_rust_code(module, code, context)
	end

	-- Override setup_environment with Rust-specific setup
	module.setup_environment = function(config)
		return M.setup_rust_environment(module, config)
	end

	-- Override get_capabilities with Rust-specific capabilities
	module.get_capabilities = function()
		return M.get_rust_capabilities(module)
	end

	-- Override health_check with Rust-specific health check
	module.health_check = function()
		return M.health_check_rust(module)
	end

	-- Override cleanup with Rust-specific cleanup
	module.cleanup = function()
		return M.cleanup_rust(module)
	end

	return module
end

-- Validate Rust code semantics
---@param code string The Rust code to validate
---@return boolean valid Whether the code is semantically valid
---@return string|nil error Error message if invalid
---@return table suggestions Suggestions for fixing the code
function M.validate_rust_semantics(code)
	local suggestions = {}
	local warnings = {}

	-- Check for main function
	if not code:match("fn%s+main%s*%(") then
		table.insert(suggestions, "Add 'fn main()' function as entry point")
		table.insert(warnings, "No main function found")
	end

	local common_imports = {
		["println!"] = "use std::io;",
		["print!"] = "use std::io;",
		["String::new"] = "use std::io;",
		["Vec::new"] = "use std::collections::Vec;",
		["HashMap::new"] = "use std::collections::HashMap;",
		["HashSet::new"] = "use std::collections::HashSet;",
		["thread::spawn"] = "use std::thread;",
		["Mutex::new"] = "use std::sync::Mutex;",
		["Arc::new"] = "use std::sync::Arc;",
		["RwLock::new"] = "use std::sync::RwLock;",
	}

	for func, import in pairs(common_imports) do
		if code:match(func:gsub("%%", "%%")) and not code:match(import:gsub("%%", "%%")) then
			table.insert(suggestions, string.format("Add '%s' for %s", import, func))
			table.insert(warnings, string.format("%s used without proper import", func))
		end
	end

	local lines = vim.split(code, "\n")
	for i, line in ipairs(lines) do
		local trimmed = vim.trim(line)
		if
			trimmed ~= ""
			and not trimmed:match("^//")
			and not trimmed:match("^///")
			and not trimmed:match("^use")
			and not trimmed:match("^mod")
		then
			if trimmed:match("let%s+[^=]+=") and not trimmed:match(";%s*$") and not trimmed:match("{%s*$") then
				table.insert(suggestions, string.format("Line %d: Add semicolon at end of statement", i))
				table.insert(warnings, string.format("Line %d: Missing semicolon", i))
			end
		end
	end

	-- Check for Result handling
	if
		code:match("Result<")
		and not code:match("%?%.")
		and not code:match("unwrap%(")
		and not code:match("expect%(")
	then
		table.insert(suggestions, "Handle Result values with ? operator, unwrap(), or expect()")
		table.insert(warnings, "Unhandled Result values")
	end

	-- Check for Option handling
	if
		code:match("Option<")
		and not code:match("%?%.")
		and not code:match("unwrap%(")
		and not code:match("expect%(")
	then
		table.insert(suggestions, "Handle Option values with ? operator, unwrap(), or expect()")
		table.insert(warnings, "Unhandled Option values")
	end

	return #warnings == 0, table.concat(warnings, "; "), suggestions
end

-- Execute Rust code
---@param module BaseLanguageModule The language module
---@param code string The code to execute
---@param context table Execution context
---@return table result The execution result
function M.execute_rust_code(module, code, context)
	context = context or {}

	local result = {
		success = false,
		output = "",
		error = nil,
		execution_time = 0,
		metadata = {},
	}

	-- Validate code
	local valid, error_msg = base.validate_code(code, "rust")
	if not valid then
		result.error = error_msg
		result.output = result.error
		return result
	end

	-- Check if environment is ready
	if not module.environment.ready then
		result.error = "Rust environment not ready"
		result.output = result.error
		return result
	end

	-- Validate Rust semantics
	local semantically_valid, semantic_error, suggestions = M.validate_rust_semantics(code)

	local start_time = vim.loop.hrtime()

	-- Create temporary files
	local temp_rs_file = os.tmpname() .. ".rs"
	local temp_exe_file = os.tmpname()

	local file = io.open(temp_rs_file, "w")
	if not file then
		result.error = "Failed to create temporary Rust file"
		result.output = result.error
		return result
	end

	-- Write code to file
	file:write(code)
	file:close()

	-- Compile the Rust code
	local compile_command = string.format("%s -o %s %s", module.environment.compiler, temp_exe_file, temp_rs_file)
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
		os.remove(temp_rs_file)
		return result
	end

	-- Execute the compiled program
	local exec_command = temp_exe_file
	local exec_output = vim.fn.system(exec_command)
	local exec_success = vim.v.shell_error == 0

	local end_time = vim.loop.hrtime()
	result.execution_time = (end_time - start_time) / 1000000 -- Convert to milliseconds

	-- Clean up temporary files
	os.remove(temp_rs_file)
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
			language = "rust",
			version = module.environment.rustc_version,
			execution_mode = "compiled",
			environment_ready = module.environment.ready,
			compilation_time = result.execution_time * 0.8, -- Rust compilation is typically slower
			execution_time = result.execution_time * 0.2, -- Rust execution is typically faster
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

-- Setup Rust environment
---@param module BaseLanguageModule The language module
---@param config table Configuration for environment setup
---@return boolean success Whether setup was successful
function M.setup_rust_environment(module, config)
	config = config or {}

	-- Call base setup first
	local base_success = base.setup_environment(module, config)
	if not base_success then
		return false
	end

	-- Get Rust version
	local version_output = vim.fn.system(module.metadata.executable_check)
	local version = version_output:match("rustc ([%d%.]+)")

	if not version then
		utils.log("Failed to get Rust version", "error")
		return false
	end

	-- Set up Rust-specific environment
	module.environment.rustc_version = version
	module.environment.compiler = config.compiler or "rustc"
	module.environment.flags = config.flags or ""
	module.environment.cargo_available = vim.fn.executable("cargo") == 1

	utils.log(string.format("Rust environment setup complete (rustc %s)", version), "info")
	return true
end

-- Get Rust capabilities
---@param module BaseLanguageModule The language module
---@return table capabilities The Rust capabilities
function M.get_rust_capabilities(module)
	local base_capabilities = base.get_capabilities(module)

	return vim.tbl_extend("force", base_capabilities, {
		rustc_version = module.environment.rustc_version,
		compiler = module.environment.compiler,
		flags = module.environment.flags,
		cargo_available = module.environment.cargo_available,
		compiled_execution = true,
		semantic_validation = true,
		memory_safety = true,
		error_suggestions = true,
		cargo_integration = module.environment.cargo_available,
	})
end

-- Health check for Rust
---@param module BaseLanguageModule The language module
---@return boolean healthy Whether Rust is healthy
function M.health_check_rust(module)
	-- Call base health check first
	if not base.health_check(module) then
		return false
	end

	-- Check Rust-specific health
	if not module.environment.rustc_version then
		return false
	end

	-- Test basic Rust compilation
	local test_code = [[
fn main() {
    println!("Hello, World!");
}
]]

	local temp_file = os.tmpname() .. ".rs"
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

-- Cleanup Rust environment
---@param module BaseLanguageModule The language module
function M.cleanup_rust(module)
	-- Call base cleanup
	base.cleanup(module)

	-- Rust-specific cleanup (if any)
	module.environment.rustc_version = nil
	module.environment.compiler = nil
	module.environment.flags = nil
	module.environment.cargo_available = nil
end

-- Create and return the Rust language module
local rust_module = create_rust_module()

return rust_module

