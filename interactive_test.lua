-- Interactive test for Shifty plugin
-- Run this in Neovim with: :source interactive_test.lua

print("🧪 Interactive Shifty Plugin Test")
print("==================================")

-- Test 1: Load the plugin
print("\n1. Testing plugin loading...")
local success, shifty = pcall(require, 'shifty')
if success then
    print("✅ Plugin loaded successfully")
else
    print("❌ Failed to load plugin: " .. tostring(shifty))
    return
end

-- Test 2: Setup the plugin
print("\n2. Testing plugin setup...")
local setup_success = pcall(function()
    shifty.setup({
        keymaps = {
            toggle = "<leader>st",
            run = "<leader>sr",
            clear = "<leader>sc",
            close = "<leader>sx",
        },
        languages = {
            python = {
                command = "python3",
                args = {"-u"},
                timeout = 5000,
            },
            javascript = {
                command = "node",
                args = {},
                timeout = 3000,
            },
                    lua = {
          command = "lua",
          args = {},
          timeout = 2000,
        },
        java = {
          command = "javac",
          args = {"-d", "/tmp"},
          run_command = "java",
          run_args = {"-cp", "/tmp"},
          timeout = 10000,
        },
        },
        execution = {
            timeout = 5000,
            capture_print = true,
            safe_mode = true,
        },
        ui = {
            window_width = 80,
            window_height = 20,
            border = "rounded",
        }
    })
end)

if setup_success then
    print("✅ Plugin setup successful")
else
    print("❌ Plugin setup failed")
    return
end

-- Test 3: Check commands
print("\n3. Testing commands...")
local commands = {
    'Shifty',
    'ShiftyToggle',
    'ShiftyRun',
    'ShiftyClear',
    'ShiftyClose',
    'ShiftyInfo'
}

for _, cmd in ipairs(commands) do
    local cmd_exists = vim.fn.exists(':' .. cmd) == 2
    if cmd_exists then
        print("✅ Command " .. cmd .. " is available")
    else
        print("❌ Command " .. cmd .. " is not available")
    end
end

-- Test 4: Check keymaps
print("\n4. Testing keymaps...")
local keymaps = {
    '<leader>st',
    '<leader>sr',
    '<leader>sc',
    '<leader>sx'
}

for _, keymap in ipairs(keymaps) do
    local map = vim.fn.maparg(keymap, 'n')
    if map ~= '' then
        print("✅ Keymap " .. keymap .. " is set: " .. map)
    else
        print("❌ Keymap " .. keymap .. " is not set")
    end
end

-- Test 5: Test code block parsing
print("\n5. Testing code block parsing...")
local test_lines = {
    "```python",
    "print('Hello, World!')",
    "```"
}

local parser = require('shifty.parser')
local code_block = parser.extract_code_block_at_cursor(test_lines, 2)

if code_block then
    print("✅ Code block parsing works")
    print("   Language: " .. (code_block.language or "unknown"))
    print("   Code: " .. code_block.code:gsub("\n", "\\n"))
else
    print("❌ Code block parsing failed")
end

print("\n🎉 Interactive test completed!")
print("\nNext steps:")
print("1. Open test_codeblocks.md")
print("2. Try :ShiftyToggle to open the window")
print("3. Place cursor in a code block and try :ShiftyRun")
print("4. Test keymaps: <leader>st, <leader>sr, <leader>sc, <leader>sx") 