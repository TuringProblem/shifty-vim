local M = {}

---@class LanguageMetadata
---@field name string The language name (e.g., "python", "javascript")
---@field version string The language module version
---@field file_extensions string[] Supported file extensions
---@field executable_check string Command to check if language is available
---@field aliases string[] Language aliases (e.g., {"js", "javascript"})

---@class LanguageModule
---@field metadata LanguageMetadata Language metadata
---@field execute_code fun(code: string, context: table): table Execute code and return result
---@field setup_environment fun(config: table): boolean Setup execution environment
---@field get_capabilities fun(): table Get language capabilities
---@field health_check fun(): boolean Check if language is healthy
---@field cleanup fun(): nil Cleanup resources

---@type table<string, LanguageModule>
local language_registry = {}

---@type table<string, string> Language aliases mapping
local language_aliases = {}

---@type table<string, boolean> Health status cache
local health_cache = {}

-- Register a language module
---@param language_name string The language name
---@param module LanguageModule The language module
---@return boolean success Whether registration was successful
function M.register_language(language_name, module)
  if not language_name or type(language_name) ~= "string" then
    vim.notify("Shifty: Invalid language name provided", vim.log.levels.ERROR)
    return false
  end
  
  if not module or type(module) ~= "table" then
    vim.notify("Shifty: Invalid language module provided", vim.log.levels.ERROR)
    return false
  end
  
  -- Validate required interface
  local required_methods = {"execute_code", "setup_environment", "get_capabilities", "health_check", "cleanup"}
  for _, method in ipairs(required_methods) do
    if type(module[method]) ~= "function" then
      vim.notify(string.format("Shifty: Language module missing required method: %s", method), vim.log.levels.ERROR)
      return false
    end
  end
  
  -- Validate metadata
  if not module.metadata or type(module.metadata) ~= "table" then
    vim.notify("Shifty: Language module missing metadata", vim.log.levels.ERROR)
    return false
  end
  
  local required_metadata = {"name", "version", "file_extensions", "executable_check"}
  for _, field in ipairs(required_metadata) do
    if not module.metadata[field] then
      vim.notify(string.format("Shifty: Language module missing required metadata: %s", field), vim.log.levels.ERROR)
      return false
    end
  end
  
  -- Register the language
  language_registry[language_name] = module
  
  -- Register aliases
  if module.metadata.aliases then
    for _, alias in ipairs(module.metadata.aliases) do
      language_aliases[alias] = language_name
    end
  end
  
  -- Clear health cache for this language
  health_cache[language_name] = nil
  
  vim.notify(string.format("Shifty: Registered language '%s' v%s", language_name, module.metadata.version), vim.log.levels.INFO)
  return true
end

-- Unregister a language module
---@param language_name string The language name
---@return boolean success Whether unregistration was successful
function M.unregister_language(language_name)
  if not language_registry[language_name] then
    return false
  end
  
  -- Cleanup the language module
  local module = language_registry[language_name]
  if module.cleanup then
    pcall(module.cleanup)
  end
  
  -- Remove from registry
  language_registry[language_name] = nil
  
  -- Remove aliases
  for alias, name in pairs(language_aliases) do
    if name == language_name then
      language_aliases[alias] = nil
    end
  end
  
  -- Clear health cache
  health_cache[language_name] = nil
  
  vim.notify(string.format("Shifty: Unregistered language '%s'", language_name), vim.log.levels.INFO)
  return true
end

-- Get a language module by name (with alias resolution)
---@param language_name string The language name or alias
---@return LanguageModule|nil The language module or nil if not found
function M.get_language(language_name)
  -- Check direct match first
  if language_registry[language_name] then
    return language_registry[language_name]
  end
  
  -- Check aliases
  local resolved_name = language_aliases[language_name]
  if resolved_name and language_registry[resolved_name] then
    return language_registry[resolved_name]
  end
  
  return nil
end

-- Get all registered languages
---@return string[] List of registered language names
function M.get_registered_languages()
  local languages = {}
  for name, _ in pairs(language_registry) do
    table.insert(languages, name)
  end
  table.sort(languages)
  return languages
end

-- Check if a language is available (with health check)
---@param language_name string The language name or alias
---@return boolean available Whether the language is available and healthy
function M.is_language_available(language_name)
  local module = M.get_language(language_name)
  if not module then
    return false
  end
  
  -- Check health cache first
  if health_cache[language_name] ~= nil then
    return health_cache[language_name]
  end
  
  -- Perform health check
  local healthy = pcall(function()
    return module.health_check()
  end)
  
  health_cache[language_name] = healthy
  return healthy
end

-- Get language capabilities
---@param language_name string The language name or alias
---@return table|nil Capabilities or nil if language not found
function M.get_language_capabilities(language_name)
  local module = M.get_language(language_name)
  if not module then
    return nil
  end
  
  local success, capabilities = pcall(function()
    return module.get_capabilities()
  end)
  
  if success then
    return capabilities
  end
  
  return nil
end

-- Clear health cache
function M.clear_health_cache()
  health_cache = {}
end

-- Get registry statistics
---@return table Statistics about the registry
function M.get_statistics()
  local stats = {
    total_languages = 0,
    total_aliases = 0,
    healthy_languages = 0,
    languages = {}
  }
  
  for name, module in pairs(language_registry) do
    stats.total_languages = stats.total_languages + 1
    local healthy = M.is_language_available(name)
    if healthy then
      stats.healthy_languages = stats.healthy_languages + 1
    end
    
    stats.languages[name] = {
      version = module.metadata.version,
      healthy = healthy,
      aliases = module.metadata.aliases or {}
    }
  end
  
  for _ in pairs(language_aliases) do
    stats.total_aliases = stats.total_aliases + 1
  end
  
  return stats
end

return M 