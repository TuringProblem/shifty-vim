local M = {}

-- Logging levels
local LOG_LEVELS = {
  error = 1,
  warn = 2,
  info = 3,
  debug = 4
}

-- Current log level
local current_log_level = LOG_LEVELS.info

-- Log a message
function M.log(message, level)
  level = level or "info"
  
  if LOG_LEVELS[level] and LOG_LEVELS[level] <= current_log_level then
    local prefix = string.format("[Shifty:%s]", level:upper())
    vim.notify(string.format("%s %s", prefix, message), vim.log.levels[level:upper()])
  end
end

-- Set log level
function M.set_log_level(level)
  if LOG_LEVELS[level] then
    current_log_level = LOG_LEVELS[level]
  end
end

-- Safely get buffer lines
function M.get_buffer_lines(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  
  if not vim.api.nvim_buf_is_valid(buf) then
    return {}
  end
  
  return vim.api.nvim_buf_get_lines(buf, 0, -1, false)
end

-- Check if cursor is in a valid position
function M.is_cursor_valid(cursor_pos, lines)
  if not cursor_pos or not lines then
    return false
  end
  
  local row = cursor_pos[1]
  return row >= 1 and row <= #lines
end

-- Escape special characters for patterns
function M.escape_pattern(str)
  return str:gsub("([^%w])", "%%%1")
end

-- Deep copy table
function M.deep_copy(obj)
  if type(obj) ~= "table" then
    return obj
  end
  
  local copy = {}
  for key, value in pairs(obj) do
    copy[M.deep_copy(key)] = M.deep_copy(value)
  end
  
  return copy
end

-- Measure execution time
function M.measure_time(func, ...)
  local start_time = vim.loop.hrtime()
  local results = {func(...)}
  local end_time = vim.loop.hrtime()
  
  local execution_time = (end_time - start_time) / 1000000  -- Convert to milliseconds
  
  return execution_time, unpack(results)
end

-- Check if a string is empty or whitespace
function M.is_empty(str)
  return not str or str:match("^%s*$") ~= nil
end

-- Trim whitespace from string
function M.trim(str)
  if not str then
    return ""
  end
  return str:match("^%s*(.-)%s*$")
end

-- Split string by delimiter
function M.split(str, delimiter)
  delimiter = delimiter or "%s+"
  local result = {}
  
  if str then
    for match in str:gmatch("([^" .. delimiter .. "]+)") do
      table.insert(result, match)
    end
  end
  
  return result
end

return M
