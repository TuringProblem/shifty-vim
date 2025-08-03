local M = {}

local registry = require("andrew.plugins.custom.shifty.registry")
local utils = require("andrew.plugins.custom.shifty.utils")

-- Language discovery paths
local language_paths = {
	"lua/andrew/plugins/custom/shifty/languages",
}

-- Cache for discovered languages
local discovered_languages = {}

-- Discover and load all available language modules
---@param config table|nil Configuration for language discovery
---@return table discovered List of discovered languages
function M.discover_languages(config)
	config = config or {}
	discovered_languages = {}

	utils.log("Starting language discovery...", "info")

	-- Search in language paths
	for _, path in ipairs(language_paths) do
		local success, languages = pcall(function()
			return M.scan_language_directory(path, config)
		end)

		if success then
			for _, language in ipairs(languages) do
				table.insert(discovered_languages, language)
			end
		else
			utils.log(string.format("Failed to scan directory %s: %s", path, languages), "error")
		end
	end

	utils.log(string.format("Discovered %d language modules", #discovered_languages), "info")
	return discovered_languages
end

-- Scan a directory for language modules
---@param directory_path string The directory path to scan
---@param config table Configuration for scanning
---@return table languages List of discovered languages
function M.scan_language_directory(directory_path, config)
	local languages = {}

	-- Check if directory exists
	local dir = vim.fn.stdpath("config") .. "/" .. directory_path
	if vim.fn.isdirectory(dir) == 0 then
		return languages
	end

	-- Scan for language directories
	local items = vim.fn.readdir(dir)
	for _, item in ipairs(items) do
		local item_path = dir .. "/" .. item

		-- Check if it's a directory and has an init.lua file
		if vim.fn.isdirectory(item_path) == 1 then
			local init_file = item_path .. "/init.lua"
			if vim.fn.filereadable(init_file) == 1 then
				local language_info = M.load_language_module(item, "andrew.plugins.custom.shifty.languages", config)
				if language_info then
					table.insert(languages, language_info)
				end
			end
		end
	end

	return languages
end

-- Load a language module
---@param language_name string The language name
---@param base_path string The base path for the language
---@param config table Configuration for loading
---@return table|nil language_info Language information or nil if failed
function M.load_language_module(language_name, base_path, config)
	local module_path = base_path .. "." .. language_name

	utils.log(
		string.format("Attempting to load language module '%s' from path '%s'", language_name, module_path),
		"info"
	)

	local success, module = pcall(require, module_path)
	if not success then
		utils.log(string.format("Failed to load language module '%s': %s", language_name, module), "error")
		return nil
	end

	utils.log(string.format("Successfully loaded language module '%s'", language_name), "info")

	if not M.validate_language_module(module, language_name) then
		utils.log(string.format("Invalid language module structure for '%s'", language_name), "error")
		return nil
	end

	-- Register the language
	local registered = registry.register_language(language_name, module)
	if not registered then
		utils.log(string.format("Failed to register language '%s'", language_name), "error")
		return nil
	end

	utils.log(string.format("Successfully registered language '%s'", language_name), "info")

	return {
		name = language_name,
		path = module_path,
		module = module,
		registered = true,
	}
end

-- Validate a language module structure
---@param module table The language module
---@param language_name string The language name
---@return boolean valid Whether the module is valid
function M.validate_language_module(module, language_name)
	-- Check if module is a table
	if type(module) ~= "table" then
		return false
	end

	-- Check required methods
	local required_methods = { "execute_code", "setup_environment", "get_capabilities", "health_check", "cleanup" }
	for _, method in ipairs(required_methods) do
		if type(module[method]) ~= "function" then
			return false
		end
	end

	-- Check metadata
	if not module.metadata or type(module.metadata) ~= "table" then
		return false
	end

	local required_metadata = { "name", "version", "file_extensions", "executable_check" }
	for _, field in ipairs(required_metadata) do
		if not module.metadata[field] then
			return false
		end
	end

	-- Validate metadata.name matches language_name
	if module.metadata.name ~= language_name then
		return false
	end

	return true
end

-- Auto-register built-in languages
---@param config table|nil Configuration for auto-registration
function M.auto_register_builtin_languages(config)
	config = config or {}

	utils.log("Auto-registering built-in languages...", "info")

	-- Built-in languages that should always be available
	local builtin_languages = {
		"lua",
		"python",
		"javascript",
		"c",
		"rust",
	}

	for _, language in ipairs(builtin_languages) do
		local success, _ = pcall(function()
			return M.load_language_module(language, "andrew.plugins.custom.shifty.languages", config)
		end)

		if not success then
			utils.log(string.format("Failed to auto-register built-in language '%s'", language), "warn")
		end
	end
end

-- Get all discovered languages
---@return table languages List of discovered languages
function M.get_discovered_languages()
	return vim.deepcopy(discovered_languages)
end

-- Reload a specific language module
---@param language_name string The language name to reload
---@return boolean success Whether reload was successful
function M.reload_language(language_name)
	-- Unregister existing language
	registry.unregister_language(language_name)

	-- Try to reload from discovered languages
	for _, language_info in ipairs(discovered_languages) do
		if language_info.name == language_name then
			local success, new_module = pcall(require, language_info.path)
			if success and M.validate_language_module(new_module, language_name) then
				local registered = registry.register_language(language_name, new_module)
				if registered then
					utils.log(string.format("Successfully reloaded language '%s'", language_name), "info")
					return true
				end
			end
			break
		end
	end

	utils.log(string.format("Failed to reload language '%s'", language_name), "error")
	return false
end

-- Get language discovery statistics
---@return table stats Discovery statistics
function M.get_discovery_stats()
	local registry_stats = registry.get_statistics()

	return {
		discovered_count = #discovered_languages,
		registered_count = registry_stats.total_languages,
		healthy_count = registry_stats.healthy_languages,
		discovery_paths = language_paths,
		discovered_languages = discovered_languages,
	}
end

-- Initialize language discovery system
---@param config table|nil Configuration for initialization
function M.init(config)
	config = config or {}

	utils.log("Initializing language discovery system...", "info")

	-- Discover languages
	M.discover_languages(config)

	-- Auto-register built-in languages
	M.auto_register_builtin_languages(config)

	-- Log final statistics
	local stats = M.get_discovery_stats()
	utils.log(
		string.format(
			"Language discovery complete: %d discovered, %d registered, %d healthy",
			stats.discovered_count,
			stats.registered_count,
			stats.healthy_count
		),
		"info"
	)
end

return M

