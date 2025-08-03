local M = {}

-- Default configuration
local defaults = {
	-- Window settings
	window = {
		width = 80,
		height = 20,
		border = "rounded",
		title = " Shifty - Multi-Language REPL ",
		title_pos = "right",
		relative = "editor",
		style = "minimal",
		focusable = true,
		zindex = 100,
	},

	-- Keymaps
	keymaps = {
		toggle = "<leader>st",
		run = "<leader>sr",
		smart = "<leader>se", -- New: Smart execution (selection/block/context)
		selection = "<leader>ss", -- New: Execute selection
		context = "<leader>sl", -- New: Execute current line/context
		clear = "<leader>sc", -- Clear output
		close = "<Esc>", -- In floating window
	},

	-- Execution settings
	execution = {
		timeout = 5000, -- 5 seconds
		capture_print = true,
		show_errors = true,
		auto_clear = false,
	},

	-- UI settings
	ui = {
		show_line_numbers = false,
		syntax_highlighting = true,
		auto_scroll = true,
		show_timestamp = true,
		auto_language_detection = true,
		show_language_info = true,
		colors = {
			success = "DiagnosticOk",
			error = "DiagnosticError",
			info = "DiagnosticInfo",
			border = "FloatBorder",
		},
	},

	-- Parser settings
	parser = {
		supported_languages = { "lua", "python", "javascript", "c", "rust" },
		block_pattern = "```%s*(%w+)%s*\n(.-)\n```",
		require_language_tag = false,
	},

	-- Language-specific configurations
	languages = {
		lua = {
			enabled = true,
			timeout = 5000,
			safe_mode = true,
		},
		python = {
			enabled = true,
			interpreter = "python3",
			venv_support = true,
			timeout = 10000,
		},
		javascript = {
			enabled = true,
			runtime = "node",
			npm_support = false,
			timeout = 8000,
		},
		c = {
			enabled = true,
			compiler = "gcc",
			flags = "-Wall -Wextra -std=c99",
			optimization = "-O0",
			timeout = 15000,
		},
		rust = {
			enabled = true,
			compiler = "rustc",
			flags = "",
			timeout = 20000,
		},
	},
}

M.options = {}

-- Setup configuration
function M.setup(user_opts)
	M.options = vim.tbl_deep_extend("force", defaults, user_opts or {})

	-- Validate configuration
	M.validate()
end

-- Validate configuration options
function M.validate()
	-- Validate window dimensions
	if M.options.window.width <= 0 or M.options.window.width > 200 then
		M.options.window.width = defaults.window.width
	end

	if M.options.window.height <= 0 or M.options.window.height > 50 then
		M.options.window.height = defaults.window.height
	end

	-- Validate timeout
	if M.options.execution.timeout <= 0 then
		M.options.execution.timeout = defaults.execution.timeout
	end
end

-- Get option value with fallback
function M.get(key)
	local keys = vim.split(key, ".", { plain = true })
	local value = M.options

	for _, k in ipairs(keys) do
		if type(value) == "table" and value[k] then
			value = value[k]
		else
			return nil
		end
	end

	return value
end

return M

