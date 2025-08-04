local M = {}

local base = require("shifty.languages.base")
local utils = require("shifty.utils")

local metadata = {
	name = "java",
	version = "1.0.0",
	extensions = { ".java", ".jar" },
	executable = "javac --version",
	aliases = { "java", "javac" },
}

-- Java language configuration
local config = {
	command = "javac",
	args = { "-d", "/tmp" },
	run_command = "java",
	run_args = { "-cp", "/tmp" },
	timeout = 10000,
	file_extension = ".java",
	compile_first = true,
}

-- Template for a simple Java program
local template = [[
public class Main {
    public static void main(String[] args) {
        %s
    }
}
]]

-- Function to create a complete Java program from code snippet
local function create_java_program(code)
	-- Remove any existing class declaration and main method
	local clean_code = code:gsub("public%s+class%s+%w+%s*{.*}", "")
	clean_code = clean_code:gsub("public%s+static%s+void%s+main%s*%(.*%)%s*{.*}", "")
	clean_code = clean_code:gsub("^%s*", ""):gsub("%s*$", "")
	
	-- If the code already has a complete program structure, return as is
	if code:match("public%s+class%s+%w+%s*{") and code:match("public%s+static%s+void%s+main") then
		return code
	end
	
	-- Otherwise, wrap in template
	return string.format(template, clean_code)
end

-- Function to extract class name from Java code
local function extract_class_name(code)
	local class_match = code:match("public%s+class%s+(%w+)")
	if class_match then
		return class_match
	end
	return "Main"
end

-- Function to generate unique class name
local function generate_class_name()
	return "ShiftyClass_" .. math.random(1000, 9999)
end

-- Import the semantic evaluator
local evaluator = require("shifty.languages.java.evaluator")

-- Override the execute function for Java with semantic analysis
function M.execute(context)
	return evaluator.execute_with_semantics(context)
end

-- Register the language
return base.register_language(metadata, config, M)
