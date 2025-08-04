local M = {}
local utils = require("shifty.utils")
local detector = require("shifty.detector")

local FILE_EXTENSION_MAP = {
    [".c"] = "c",
    [".h"] = "c", 
    [".cpp"] = "cpp",
    [".cc"] = "cpp",
    [".cxx"] = "cpp",
    [".hpp"] = "cpp",
    [".rs"] = "rust",
    [".java"] = "java",
    
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
    
    [".json"] = "javascript",
    [".yaml"] = "yaml",
    [".yml"] = "yaml",
    [".toml"] = "toml",
    [".ini"] = "ini",
    [".cfg"] = "ini",
    [".conf"] = "ini",
}

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

---@param buf number|nil Buffer number (defaults to current)
---@return string|nil language The detected language or nil
function M.get_language_from_buffer(buf)
    buf = buf or vim.api.nvim_get_current_buf()
    
    local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
    if not filetype or filetype == "" then
        return nil
    end
    
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

---@param buf number|nil Buffer number (defaults to current)
---@return string|nil extension The file extension or nil
function M.get_file_extension_from_buffer(buf)
    buf = buf or vim.api.nvim_get_current_buf()
    
    local filepath = vim.api.nvim_buf_get_name(buf)
    if not filepath or filepath == "" then
        return nil
    end
    
    local extension = filepath:match("%.[^%.]+$")
    return extension and extension:lower() or nil
end

---@param lines table Array of lines
---@param cursor_line number Current cursor line (1-based)
---@return string|nil context_code Extracted context code or nil
function M.extract_context_block(lines, cursor_line)
    local line_idx = cursor_line - 1
    local current_line = lines[line_idx] or ""
    
    if current_line:match("^%s*$") then
        return nil
    end
    
    local function_code = M.extract_function_context(lines, line_idx)
    if function_code then
        return function_code
    end
    
    local class_code = M.extract_class_context(lines, line_idx)
    if class_code then
        return class_code
    end
    
    local block_code = M.extract_block_context(lines, line_idx)
    if block_code then
        return block_code
    end
    
    return current_line
end

---@param lines table Array of lines
---@param line_idx number Current line index (0-based)
---@return string|nil function_code Function code or nil
function M.extract_function_context(lines, line_idx)
    local start_line = line_idx
    local end_line = line_idx
    
    for i = line_idx, 0, -1 do
        local line = lines[i] or ""
        if line:match("^%s*function%s+") or 
           line:match("^%s*def%s+") or 
           line:match("^%s*fn%s+") or
           line:match("^%s*public%s+static%s+") or
           line:match("^%s*private%s+") or
           line:match("^%s*protected%s+") then
            start_line = i
            break
        end
    end
    
    local brace_count = 0
    local found_start = false
    
    for i = start_line, #lines - 1 do
        local line = lines[i] or ""
        
        for char in line:gmatch("[{}]") do
            if char == "{" then
                brace_count = brace_count + 1
                found_start = true
            elseif char == "}" then
                brace_count = brace_count - 1
            end
        end
        
        if not found_start and line:match("^%s*def%s+") then
            for j = i + 1, #lines - 1 do
                local next_line = lines[j] or ""
                if next_line:match("^%s*def%s+") or next_line:match("^%s*class%s+") or next_line:match("^%s*$") then
                    end_line = j - 1
                    break
                end
                end_line = j
            end
            break
        end
        
        if found_start and brace_count == 0 then
            end_line = i
            break
        end
    end
    
    if end_line >= start_line then
        local function_lines = {}
        for i = start_line, end_line do
            table.insert(function_lines, lines[i] or "")
        end
        return table.concat(function_lines, "\n")
    end
    
    return nil
end

---@param lines table Array of lines
---@param line_idx number Current line index (0-based)
---@return string|nil class_code Class code or nil
function M.extract_class_context(lines, line_idx)
    local start_line = line_idx
    local end_line = line_idx
    
    for i = line_idx, 0, -1 do
        local line = lines[i] or ""
        if line:match("^%s*class%s+") then
            start_line = i
            break
        end
    end
    
    local brace_count = 0
    local found_start = false
    
    for i = start_line, #lines - 1 do
        local line = lines[i] or ""
        
        for char in line:gmatch("[{}]") do
            if char == "{" then
                brace_count = brace_count + 1
                found_start = true
            elseif char == "}" then
                brace_count = brace_count - 1
            end
        end
        
        if not found_start and line:match("^%s*class%s+") then
            for j = i + 1, #lines - 1 do
                local next_line = lines[j] or ""
                if next_line:match("^%s*class%s+") or next_line:match("^%s*$") then
                    end_line = j - 1
                    break
                end
                end_line = j
            end
            break
        end
        
        if found_start and brace_count == 0 then
            end_line = i
            break
        end
    end
    
    if end_line >= start_line then
        local class_lines = {}
        for i = start_line, end_line do
            table.insert(class_lines, lines[i] or "")
        end
        return table.concat(class_lines, "\n")
    end
    
    return nil
end

---@param lines table Array of lines
---@param line_idx number Current line index (0-based)
---@return string|nil block_code Block code or nil
function M.extract_block_context(lines, line_idx)
    local start_line = line_idx
    local end_line = line_idx
    
    for i = line_idx, 0, -1 do
        local line = lines[i] or ""
        if line:match("^%s*if%s+") or 
           line:match("^%s*for%s+") or 
           line:match("^%s*while%s+") or
           line:match("^%s*try%s*%{") or
           line:match("^%s*try%s*:") then
            start_line = i
            break
        end
    end
    
    local brace_count = 0
    local found_start = false
    
    for i = start_line, #lines - 1 do
        local line = lines[i] or ""
        
        for char in line:gmatch("[{}]") do
            if char == "{" then
                brace_count = brace_count + 1
                found_start = true
            elseif char == "}" then
                brace_count = brace_count - 1
            end
        end
        
        if not found_start and (line:match("^%s*if%s+") or line:match("^%s*for%s+") or line:match("^%s*while%s+")) then
            local base_indent = line:match("^(%s*)")
            for j = i + 1, #lines - 1 do
                local next_line = lines[j] or ""
                local next_indent = next_line:match("^(%s*)")
                if next_indent and #next_indent <= #base_indent and next_line:match("%S") then
                    end_line = j - 1
                    break
                end
                end_line = j
            end
            break
        end
        
        if found_start and brace_count == 0 then
            end_line = i
            break
        end
    end
    
    if end_line >= start_line then
        local block_lines = {}
        for i = start_line, end_line do
            table.insert(block_lines, lines[i] or "")
        end
        return table.concat(block_lines, "\n")
    end
    
    return nil
end

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
    
    local start_line = start_pos[2] - 1
    local end_line = end_pos[2] - 1
    
    local lines = vim.api.nvim_buf_get_lines(buf, start_line, end_line + 1, false)
    local code = table.concat(lines, "\n")
    
    local context = {
        file_extension = M.get_file_extension_from_buffer(buf),
        buffer_filetype = M.get_language_from_buffer(buf)
    }
    
    local detection_result = detector.detect_language(code, context)
    local language = detection_result.language
    local confidence = detection_result.confidence
    
    utils.log(string.format("Selected code detection: %s (%.1f%% confidence)", language, confidence), "info")
    
    if not detector.is_confidence_sufficient(confidence) and #detection_result.alternatives > 0 then
        local alt_str = ""
        for _, alt in ipairs(detection_result.alternatives) do
            alt_str = alt_str .. string.format("%s(%.1f%%) ", alt.language, alt.confidence)
        end
        utils.log("Low confidence detection. Alternatives: " .. alt_str, "warn")
    end
    
    return {
        code = code,
        language = language,
        confidence = confidence,
        alternatives = detection_result.alternatives,
        start_line = start_line + 1,
        end_line = end_line + 1,
        source = "selection",
        mode = mode,
        detection_analysis = detection_result.analysis
    }
end

---@param buf number|nil Buffer number (defaults to current)
---@param cursor_line number|nil Cursor line (defaults to current)
---@return table|nil code_info Code information or nil
function M.extract_code_smart(buf, cursor_line)
    buf = buf or vim.api.nvim_get_current_buf()
    cursor_line = cursor_line or vim.api.nvim_win_get_cursor(0)[1]
    
    local selected_code = M.extract_selected_code(buf)
    if selected_code then
        return selected_code
    end
    
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local code_block = M.extract_code_block_at_cursor(lines, cursor_line)
    
    if code_block then
        code_block.source = "fenced_block"
        return code_block
    end
    
    return M.extract_context_code(buf, cursor_line)
end

---@param buf number Buffer number
---@param cursor_line number Current cursor line
---@return table|nil code_info Code information or nil
function M.extract_context_code(buf, cursor_line)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    
    local context = {
        file_extension = M.get_file_extension_from_buffer(buf),
        buffer_filetype = M.get_language_from_buffer(buf)
    }
    
    local current_line = lines[cursor_line - 1] or ""
    if current_line:match("^%s*$") then
        return nil
    end
    
    local context_code = M.extract_context_block(lines, cursor_line)
    local code = context_code or current_line
    
    local detection_result = detector.detect_language(code, context)
    local language = detection_result.language
    local confidence = detection_result.confidence
    
    utils.log(string.format("Context code detection: %s (%.1f%% confidence)", language, confidence), "info")
    
    return {
        code = code,
        language = language,
        confidence = confidence,
        alternatives = detection_result.alternatives,
        start_line = cursor_line,
        end_line = cursor_line,
        source = "context_line",
        detection_analysis = detection_result.analysis
    }
end

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

	for i = cursor_line, 1, -1 do
		if lines[i] and lines[i]:match("^```") then
			start_line = i
			break
		end
	end

	if not start_line then
		return nil, nil
	end

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

	local language = line:match("^```%s*(%w+)")

	if language then
		return language:lower(), nil
	end

	if line:match("^```%s*$") then
		return "lua", nil
	end

	return nil, nil
end

function M.find_all_code_blocks(lines)
	local blocks = {}
	local i = 1

	while i <= #lines do
		if lines[i] and lines[i]:match("^```") then
			local start_line = i
			local language, name = M.parse_opening_line(lines[i])

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
