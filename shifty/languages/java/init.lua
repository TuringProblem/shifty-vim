local M = {}

local base = require("andrew.plugins.custom.shifty.languages.base")
local utils = require("andrew.plugins.custom.shifty.utils")

local metadata = {
	name = "java",
	version = "1.0.0",
	extensions = { ".java", ".jar" },
	executable = "javac --version",
}
