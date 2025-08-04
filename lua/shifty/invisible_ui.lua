local M = {}

local config = require("shifty.config")
local utils = require("shifty.utils")

local invisible_windows = {}

---@param options table|nil Window options
---@return number|nil window_id Window ID or nil if failed
function M.create_invisible_window(options)
    options = options or {}
    
    local ui = vim.api.nvim_list_uis()[1]
    local width = options.width or 1
    local height = options.height or 1
    
    local row = ui.height + 100
    local col = ui.width + 100
    
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(buf, "filetype", "shifty-invisible")
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    
    local win_opts = {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "none",
        title = "",
        title_pos = "left",
        focusable = false,
        zindex = 1,
        noautocmd = true,
    }
    
    local success, win = pcall(vim.api.nvim_open_win, buf, false, win_opts)
    if not success then
        utils.log("Failed to create invisible window: " .. tostring(win), "error")
        return nil
    end
    
    vim.api.nvim_win_set_option(win, "wrap", false)
    vim.api.nvim_win_set_option(win, "cursorline", false)
    vim.api.nvim_win_set_option(win, "number", false)
    vim.api.nvim_win_set_option(win, "relativenumber", false)
    vim.api.nvim_win_set_option(win, "signcolumn", "no")
    vim.api.nvim_win_set_option(win, "foldcolumn", "0")
    vim.api.nvim_win_set_option(win, "list", false)
    vim.api.nvim_win_set_option(win, "spell", false)
    
    invisible_windows[win] = {
        buffer = buf,
        created_at = os.time(),
        purpose = options.purpose or "background_processing"
    }
    
    utils.log(string.format("Created invisible window %d for %s", win, options.purpose or "background_processing"), "debug")
    
    return win
end

---@param window_id number Window ID to close
---@return boolean success Whether window was closed successfully
function M.close_invisible_window(window_id)
    if not window_id or not vim.api.nvim_win_is_valid(window_id) then
        return false
    end
    
    local success = pcall(vim.api.nvim_win_close, window_id, true)
    if success then
        invisible_windows[window_id] = nil
        utils.log(string.format("Closed invisible window %d", window_id), "debug")
    end
    
    return success
end

---@return number closed_count Number of windows closed
function M.close_all_invisible_windows()
    local closed_count = 0
    
    for win_id, _ in pairs(invisible_windows) do
        if M.close_invisible_window(win_id) then
            closed_count = closed_count + 1
        end
    end
    
    utils.log(string.format("Closed %d invisible windows", closed_count), "info")
    return closed_count
end

---@param window_id number Window ID
---@return table|nil window_info Window information or nil
function M.get_invisible_window_info(window_id)
    return invisible_windows[window_id]
end

---@return table windows Table of invisible window IDs and their info
function M.get_all_invisible_windows()
    return vim.deepcopy(invisible_windows)
end

---@param content string|table Content to put in buffer
---@param options table|nil Buffer options
---@return number|nil buffer_id Buffer ID or nil if failed
function M.create_invisible_buffer(content, options)
    options = options or {}
    
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(buf, "filetype", options.filetype or "shifty-temp")
    vim.api.nvim_buf_set_option(buf, "modifiable", true)
    
    if content then
        if type(content) == "string" then
            local lines = vim.split(content, "\n")
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        elseif type(content) == "table" then
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
        end
    end
    
    if options.readonly then
        vim.api.nvim_buf_set_option(buf, "modifiable", false)
    end
    
    utils.log(string.format("Created invisible buffer %d for %s", buf, options.purpose or "temporary_processing"), "debug")
    
    return buf
end

---@param code string The code to wrap
---@param language string The detected language
---@param options table|nil Additional options
---@return number|nil buffer_id Buffer ID containing wrapped code
function M.create_markdown_wrapped_buffer(code, language, options)
    options = options or {}
    
    local wrapped_code = string.format("```%s\n%s\n```", language, code)
    
    if options.metadata then
        local metadata_lines = {}
        for key, value in pairs(options.metadata) do
            table.insert(metadata_lines, string.format("<!-- %s: %s -->", key, value))
        end
        if #metadata_lines > 0 then
            wrapped_code = table.concat(metadata_lines, "\n") .. "\n\n" .. wrapped_code
        end
    end
    
    return M.create_invisible_buffer(wrapped_code, {
        filetype = "markdown",
        purpose = "markdown_wrapped_code",
        readonly = true
    })
end

---@param code string The code to process
---@param language string The detected language
---@param processor function The processing function
---@param options table|nil Processing options
---@return table|nil result Processing result or nil if failed
function M.process_code_invisibly(code, language, processor, options)
    options = options or {}
    
    local win = M.create_invisible_window({
        purpose = "code_processing",
        width = 1,
        height = 1
    })
    
    if not win then
        return nil
    end
    
    local buf = M.create_markdown_wrapped_buffer(code, language, {
        metadata = {
            detected_language = language,
            confidence = options.confidence,
            source = options.source or "invisible_processing",
            timestamp = os.date("%Y-%m-%d %H:%M:%S")
        }
    })
    
    if not buf then
        M.close_invisible_window(win)
        return nil
    end
    
    vim.api.nvim_win_set_buf(win, buf)
    
    local success, result = pcall(processor, {
        window = win,
        buffer = buf,
        code = code,
        language = language,
        wrapped_code = vim.api.nvim_buf_get_lines(buf, 0, -1, false),
        options = options
    })
    
    M.close_invisible_window(win)
    
    if not success then
        utils.log("Error during invisible processing: " .. tostring(result), "error")
        return nil
    end
    
    return result
end

---@return table stats Statistics about invisible windows
function M.get_invisible_window_stats()
    local stats = {
        total_windows = 0,
        windows_by_purpose = {},
        oldest_window = nil,
        newest_window = nil
    }
    
    local oldest_time = math.huge
    local newest_time = 0
    
    for win_id, info in pairs(invisible_windows) do
        stats.total_windows = stats.total_windows + 1
        
        stats.windows_by_purpose[info.purpose] = (stats.windows_by_purpose[info.purpose] or 0) + 1
        
        if info.created_at < oldest_time then
            oldest_time = info.created_at
            stats.oldest_window = { id = win_id, created_at = info.created_at, purpose = info.purpose }
        end
        
        if info.created_at > newest_time then
            newest_time = info.created_at
            stats.newest_window = { id = win_id, created_at = info.created_at, purpose = info.purpose }
        end
    end
    
    return stats
end

---@param max_age_seconds number Maximum age in seconds
---@return number cleaned_count Number of windows cleaned up
function M.cleanup_old_invisible_windows(max_age_seconds)
    max_age_seconds = max_age_seconds or 300 -- Default 5 minutes
    
    local current_time = os.time()
    local cleaned_count = 0
    
    for win_id, info in pairs(invisible_windows) do
        if current_time - info.created_at > max_age_seconds then
            if M.close_invisible_window(win_id) then
                cleaned_count = cleaned_count + 1
            end
        end
    end
    
    if cleaned_count > 0 then
        utils.log(string.format("Cleaned up %d old invisible windows", cleaned_count), "info")
    end
    
    return cleaned_count
end

function M.init()
    vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
            M.close_all_invisible_windows()
        end
    })
    
    utils.log("Invisible window system initialized", "info")
end

return M 