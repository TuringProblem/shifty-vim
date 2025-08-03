local M = {}
local config = require("andrew.plugins.custom.shifty.config")
local utils = require("andrew.plugins.custom.shifty.utils")
local title = "󰢱 Shifty - NeoVim HOT Compiler"

-- Create the main floating window
function M.create_floating_window()
	local opts = config.get("window")

	-- Calculate window position (centered)
	local ui = vim.api.nvim_list_uis()[1]
	local width = math.min(opts.width, ui.width - 4)
	local height = math.min(opts.height, ui.height - 4)

	local row = math.floor((ui.height - height) / 2)
	local col = math.floor((ui.width - width) / 2)

	-- Create buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	vim.api.nvim_buf_set_option(buf, "filetype", "shifty-output")

	-- Window options
	local win_opts = {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = opts.border,
		title = opts.title,
		title_pos = opts.title_pos,
		focusable = opts.focusable,
		zindex = opts.zindex,
	}

	-- Create window
	local win = vim.api.nvim_open_win(buf, true, win_opts)

	-- Set window options
	vim.api.nvim_win_set_option(win, "wrap", true)
	vim.api.nvim_win_set_option(win, "cursorline", false)

	if not config.get("ui.show_line_numbers") then
		vim.api.nvim_win_set_option(win, "number", false)
		vim.api.nvim_win_set_option(win, "relativenumber", false)
	end

	-- Set initial content
	M.set_initial_content(buf)

	return win
end

-- Set initial content in the buffer
function M.set_initial_content(buf)
	local lines = {
		title,
		"━━━━━━━━━━━━━━━━━━━━━━━━━━",
		"",
		"Ready to execute code!",
		"",
		"Usage:",
		"• In single-language files: Select code and press " .. (config.get("keymaps.selection") or "<leader>ss"),
		"• Or place cursor on a line and press " .. (config.get("keymaps.context") or "<leader>sl"),
		"• Or use smart execution: " .. (config.get("keymaps.smart") or "<leader>se"),
		"• In markdown/notebooks: Place cursor in ```{language} code block",
		"• Press " .. (config.get("keymaps.run") or "<leader>sr") .. " to execute fenced blocks",
		"• Press " .. (config.get("keymaps.clear") or "<leader>sc") .. " to clear output",
		"",
		"Waiting for code execution...",
	}

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
end

-- Update output in the floating window
function M.update_output(win, result, block_identifier)
	if not win or not vim.api.nvim_win_is_valid(win) then
		return
	end

	local buf = vim.api.nvim_win_get_buf(win)
	vim.api.nvim_buf_set_option(buf, "modifiable", true)

	local timestamp = config.get("ui.show_timestamp") and (" [" .. os.date("%H:%M:%S") .. "]") or ""
	local status_icon = result.success and "✓" or "✗"
	local exec_time = string.format("%.2fms", result.execution_time or 0)

	local lines = {
		title,
		"━━━━━━━━━━━━━━━━━━━━━━━━━━",
		"",
		string.format("%s %s%s (%s)", status_icon, block_identifier or "Lua block", timestamp, exec_time),
		"━━━━━━━━━━━━━━━━━━━━━━━━━━",
		"",
	}

	-- Add output lines
	local output_lines = vim.split(result.output or "", "\n")
	for _, line in ipairs(output_lines) do
		table.insert(lines, line)
	end

	table.insert(lines, "")
	table.insert(lines, "━━━━━━━━━━━━━━━━━━━━━━━━━━")
	table.insert(
		lines,
		-- "Place cursor in ```lua block and press " .. (config.get("keymaps.run") or "<leader>sr") .. " to execute"
	)

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)

	-- Auto-scroll to bottom if enabled
	if config.get("ui.auto_scroll") then
		vim.api.nvim_win_set_cursor(win, { #lines, 0 })
	end

	-- Apply syntax highlighting based on result
	M.apply_output_highlighting(buf, result.success)
end

-- Apply syntax highlighting to output
function M.apply_output_highlighting(buf, success)
	if not config.get("ui.syntax_highlighting") then
		return
	end

	local highlight_group = success and config.get("ui.colors.success") or config.get("ui.colors.error")

	-- This is a simplified version - you might want to add more sophisticated highlighting
	vim.api.nvim_buf_add_highlight(buf, -1, highlight_group, 3, 0, -1) -- Status line
end

-- Clear output window
function M.clear_output(win)
	if not win or not vim.api.nvim_win_is_valid(win) then
		return
	end

	local buf = vim.api.nvim_win_get_buf(win)
	M.set_initial_content(buf)
end

-- Setup window-specific keymaps
function M.setup_window_keymaps(win)
	local buf = vim.api.nvim_win_get_buf(win)

	-- Close window
	local close_key = config.get("keymaps.close")
	if close_key then
		vim.keymap.set("n", close_key, function()
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, true)
			end
		end, { buffer = buf, desc = "Close Shifty window" })
	end

	-- Make window moveable (basic implementation)
	vim.keymap.set("n", "<C-w>h", "<C-w>h", { buffer = buf })
	vim.keymap.set("n", "<C-w>j", "<C-w>j", { buffer = buf })
	vim.keymap.set("n", "<C-w>k", "<C-w>k", { buffer = buf })
	vim.keymap.set("n", "<C-w>l", "<C-w>l", { buffer = buf })
end

return M
