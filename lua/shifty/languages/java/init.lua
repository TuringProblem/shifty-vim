local M = {}

local base = require("shifty.languages.base")
local utils = require("shifty.utils")

local metadata = {
	name = "java",
	version = "1.0.0",
	extensions = { ".java", ".jar" },
	executable = "javac --version",
}
