#!/bin/bash

# Test script for Shifty Neovim plugin
echo "🧪 Testing Shifty Neovim Plugin"
echo "================================"

# Check if we're in the right directory
if [ ! -f "plugin/shifty.lua" ]; then
    echo "❌ Error: plugin/shifty.lua not found. Are you in the shifty-vim directory?"
    exit 1
fi

if [ ! -f "lua/shifty/init.lua" ]; then
    echo "❌ Error: lua/shifty/init.lua not found. Plugin structure is incomplete."
    exit 1
fi

echo "✅ Plugin structure looks good"

# Test basic Neovim loading
echo ""
echo "🔍 Testing basic plugin loading..."
nvim --headless --noplugin -c "set runtimepath+=." -c "source test_config.lua" -c "q"

if [ $? -eq 0 ]; then
    echo "✅ Basic plugin loading test passed"
else
    echo "❌ Basic plugin loading test failed"
    exit 1
fi

# Test with a sample file
echo ""
echo "🔍 Testing with sample code blocks..."
nvim --headless --noplugin -c "set runtimepath+=." -c "source test_config.lua" -c "edit test_codeblocks.md" -c "call cursor(6, 1)" -c "ShiftyInfo" -c "q"

echo ""
echo "🎉 Plugin test completed!"
echo ""
echo "To test interactively:"
echo "1. Run: nvim test_codeblocks.md"
echo "2. Source the test config: :source test_config.lua"
echo "3. Try the commands: :ShiftyToggle, :ShiftyRun, :ShiftyInfo"
echo "4. Test keymaps: <leader>st, <leader>sr, <leader>sc"
echo ""
echo "For lazy.nvim testing, use the configuration in lazy_config_example.lua" 