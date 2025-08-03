local M = {}
local utils = require("andrew.plugins.custom.shifty.utils")

-- Language mapping from file extensions to language names
local FILE_EXTENSION_MAP = {
    -- Compiled languages
    [".c"] = "c",
    [".h"] = "c", 
    [".cpp"] = "cpp",
    [".cc"] = "cpp",
    [".cxx"] = "cpp",
    [".hpp"] = "cpp",
    [".rs"] = "rust",
    [".java"] = "java",
    
    -- Interpreted languages
    [".py"] = "python",
    [".pyw"] = "python",
    [".js"] = "javascript",
    [".mjs"] = "javascript",
    [".ts"] = "typescript",
    [".tsx"] = "typescript",
    [".lua"] = "lua",
    [".rb"] = "ruby",
    [".php"] = "php",
    [".sh"] = "bash",
    [".bash"] = "bash",
    [".zsh"] = "bash",
    [".fish"] = "fish",
    
    -- Configuration files (treat as their respective languages)
    [".json"] = "javascript",
    [".yaml"] = "yaml",
    [".yml"] = "yaml",
    [".toml"] = "toml",
    [".ini"] = "ini",
    [".cfg"] = "ini",
    [".conf"] = "ini",
}

-- Get language from file extension
---@param filepath string The file path
---@return string|nil language The detected language or nil
function M.get_language_from_file(filepath)
    if not filepath then
        return nil
    end
    
    local extension = filepath:match("%.[^%.]+$")
    if extension then
        return FILE_EXTENSION_MAP[extension:lower()]
    end
    
    return nil
end

-- Get language from buffer filetype
---@param buf number|nil Buffer number (defaults to current)
---@return string|nil language The detected language or nil
function M.get_language_from_buffer(buf)
    buf = buf or vim.api.nvim_get_current_buf()
    
    local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
    if not filetype or filetype == "" then
        return nil
    end
    
    -- Map common filetypes to language names
    local filetype_map = {
        c = "c",
        cpp = "cpp", 
        rust = "rust",
        java = "java",
        python = "python",
        javascript = "javascript",
        typescript = "typescript",
        lua = "lua",
        ruby = "ruby",
        php = "php",
        sh = "bash",
        bash = "bash",
        zsh = "bash",
        fish = "fish",
        json = "javascript",
        yaml = "yaml",
        toml = "toml",
        ini = "ini",
        conf = "ini",
    }
    
    return filetype_map[filetype]
end

-- Extract code from visual selection
---@param buf number|nil Buffer number (defaults to current)
---@return table|nil code_info Code information or nil if no selection
function M.extract_selected_code(buf)
    buf = buf or vim.api.nvim_get_current_buf()
    
    local mode = vim.fn.mode()
    if mode ~= "v" and mode ~= "V" and mode ~= "" then
        return nil
    end
    
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    
    if not start_pos or not end_pos then
        return nil
    end
    
    -- Convert to 0-based indexing
    local start_line = start_pos[2] - 1
    local end_line = end_pos[2] - 1
    
    local lines = vim.api.nvim_buf_get_lines(buf, start_line, end_line + 1, false)
    local code = table.concat(lines, "\n")
    
    -- Detect language from buffer context
    local language = M.get_language_from_buffer(buf)
    if not language then
        -- Fallback to file extension
        local filepath = vim.api.nvim_buf_get_name(buf)
        language = M.get_language_from_file(filepath)
    end
    
    return {
        code = code,
        language = language or "lua", -- Default fallback
        start_line = start_line + 1, -- Convert back to 1-based for display
        end_line = end_line + 1,
        source = "selection",
        mode = mode
    }
end

-- Smart code extraction: tries selection first, then code blocks
---@param buf number|nil Buffer number (defaults to current)
---@param cursor_line number|nil Cursor line (defaults to current)
---@return table|nil code_info Code information or nil
function M.extract_code_smart(buf, cursor_line)
    buf = buf or vim.api.nvim_get_current_buf()
    cursor_line = cursor_line or vim.api.nvim_win_get_cursor(0)[1]
    
    -- First, try to extract from visual selection
    local selected_code = M.extract_selected_code(buf)
    if selected_code then
        return selected_code
    end
    
    -- Fallback to code block extraction
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local code_block = M.extract_code_block_at_cursor(lines, cursor_line)
    
    if code_block then
        code_block.source = "fenced_block"
        return code_block
    end
    
    -- Last resort: extract current line or function
    return M.extract_context_code(buf, cursor_line)
end

-- Extract code from current context (line, function, etc.)
---@param buf number Buffer number
---@param cursor_line number Current cursor line
---@return table|nil code_info Code information or nil
function M.extract_context_code(buf, cursor_line)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local language = M.get_language_from_buffer(buf) or M.get_language_from_file(vim.api.nvim_buf_get_name(buf))
    
    if not language then
        return nil
    end
    
    -- For now, extract current line
    -- TODO: Implement function extraction based on language
    local current_line = lines[cursor_line - 1] or ""
    if current_line:match("^%s*$") then
        return nil
    end
    
    return {
        code = current_line,
        language = language,
        start_line = cursor_line,
        end_line = cursor_line,
        source = "context_line"
    }
end

-- Extract code block at cursor position
function M.extract_code_block_at_cursor(lines, cursor_line)
	local start_line, end_line = M.find_code_block_bounds(lines, cursor_line)

	if not start_line or not end_line then
		return nil
	end

	local block_lines = {}
	local language = nil

	local opening_line = lines[start_line]
	language = M.parse_opening_line(opening_line)

	for i = start_line + 1, end_line - 1 do
		table.insert(block_lines, lines[i])
	end

	local code = table.concat(block_lines, "\n")

	return {
		code = code,
		language = language,
		start_line = start_line,
		end_line = end_line,
	}
end

function M.find_code_block_bounds(lines, cursor_line)
	local start_line = nil
	local end_line = nil

	-- Search backward for opening ```
	for i = cursor_line, 1, -1 do
		if lines[i] and lines[i]:match("^```") then
			start_line = i
			break
		end
	end

	if not start_line then
		return nil, nil
	end

	-- Search forward for closing ```
	for i = start_line + 1, #lines do
		if lines[i] and lines[i]:match("^```%s*$") then
			end_line = i
			break
		end
	end

	if not end_line then
		return nil, nil
	end

	return start_line, end_line
end

function M.parse_opening_line(line)
	if not line then
		return nil, nil
	end

	-- Standard markdown code fence: ```language
	local language = line:match("^```%s*(%w+)")

	if language then
		return language:lower(), nil
	end

	-- Plain ``` without language - assume lua for backward compatibility
	if line:match("^```%s*$") then
		return "lua", nil
	end

	return nil, nil -- Not a valid code block
end

-- Find all code blocks in buffer
function M.find_all_code_blocks(lines)
	local blocks = {}
	local i = 1

	while i <= #lines do
		if lines[i] and lines[i]:match("^```") then
			local start_line = i
			local language, name = M.parse_opening_line(lines[i])

			-- Find closing ```
			local end_line = nil
			for j = i + 1, #lines do
				if lines[j] and lines[j]:match("^```%s*$") then
					end_line = j
					break
				end
			end

			if end_line then
				local block_lines = {}
				for k = start_line + 1, end_line - 1 do
					table.insert(block_lines, lines[k])
				end

				table.insert(blocks, {
					code = table.concat(block_lines, "\n"),
					language = language,
					name = name,
					start_line = start_line,
					end_line = end_line,
				})

				i = end_line + 1
			else
				i = i + 1
			end
		else
			i = i + 1
		end
	end

	return blocks
end

return M
