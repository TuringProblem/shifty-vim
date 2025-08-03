# Testing Guide for Shifty Plugin

This guide will help you test the Shifty Neovim plugin to ensure it's working correctly.

## Quick Test

Run the automated test script:

```bash
./test_plugin.sh
```

This will test basic plugin loading and functionality.

## Interactive Testing

### 1. Basic Setup Test

1. Open Neovim in the plugin directory:
```bash
nvim
```

2. Source the test configuration:
```vim
:source test_config.lua
```

3. Run the interactive test:
```vim
:source interactive_test.lua
```

### 2. Manual Testing

1. Open a test file:
```vim
:edit test_codeblocks.md
```

2. Source the configuration:
```vim
:source test_config.lua
```

3. Test the commands:
```vim
:ShiftyToggle    " Open the Shifty window
:ShiftyInfo      " Show system information
```

4. Test code execution:
   - Place your cursor in a Python code block
   - Run `:ShiftyRun` or press `<leader>sr`
   - Check that the output appears in the floating window

5. Test keymaps:
   - `<leader>st` - Toggle Shifty window
   - `<leader>sr` - Run current code block
   - `<leader>sc` - Clear output
   - `<leader>sx` - Close window

## Lazy.nvim Testing

### Local Development Testing

Add this to your Neovim configuration:

```lua
{
  dir = "~/path/to/shifty-vim", -- Change to your local path
  name = "shifty-vim",
  config = function()
    require("shifty").setup({
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
  end,
}
```

### Production Testing

After publishing to GitHub:

```lua
{
  "TuringProblem/shifty-vim",
  config = function()
    require("shifty").setup({
      keymaps = {
        toggle = "<leader>st",
        run = "<leader>sr",
        clear = "<leader>sc",
        close = "<leader>sx",
      }
    })
  end,
}
```

## Testing Different Code Block Formats

The `test_codeblocks.md` file contains various code block formats to test:

### Standard Markdown
```python
print("Standard markdown code block")
```

### Language Aliases
```py
print("Python with 'py' alias")
```

### Different Fences
````python
print("Four backticks")
````

~~~python
print("Tilde fences")
~~~

### Edge Cases
- Empty code blocks
- Single line code
- Multi-line code
- Inline code (should be ignored)
- Nested code blocks

## Testing Different Languages

Make sure you have the required language runtimes installed:

### Python
```bash
python3 --version
```

### JavaScript
```bash
node --version
```

### Lua
```bash
lua --version
```

### Rust
```bash
rustc --version
```

### Java
```bash
javac --version
java --version
```

### C
```bash
gcc --version
# or
clang --version
```

## Expected Behavior

### ✅ What Should Work

1. **Code Block Detection**: Plugin should detect code blocks at cursor position
2. **Language Support**: Should execute code in supported languages
3. **Output Display**: Results should appear in a floating window
4. **Keymaps**: All configured keymaps should work
5. **Commands**: All Shifty commands should be available
6. **Error Handling**: Should handle missing languages gracefully

### ❌ What Should Not Work

1. **Inline Code**: `inline code` should not be executed
2. **Nested Blocks**: Should not execute nested code blocks
3. **Invalid Languages**: Should handle unsupported languages gracefully
4. **Missing Runtimes**: Should show appropriate error messages

## Troubleshooting

### Plugin Not Loading

1. Check plugin structure:
```bash
ls -la plugin/shifty.lua
ls -la lua/shifty/init.lua
```

2. Check require paths in all files:
```bash
grep -r "require.*shifty" lua/shifty/
```

### Commands Not Available

1. Check if plugin is loaded:
```vim
:echo exists('g:loaded_shifty')
```

2. Check if commands exist:
```vim
:command Shifty
```

### Keymaps Not Working

1. Check if keymaps are set:
```vim
:map <leader>st
:map <leader>sr
```

2. Check leader key:
```vim
:echo mapleader
```

### Code Execution Failing

1. Check language runtime:
```bash
which python3
which node
which lua
```

2. Check plugin logs:
```vim
:ShiftyInfo
```

3. Test language manually:
```bash
python3 -c "print('test')"
node -e "console.log('test')"
lua -e "print('test')"
```

## Performance Testing

Test with larger code blocks:

```python
import time
import random

def test_performance():
    start = time.time()
    numbers = [random.randint(1, 1000) for _ in range(10000)]
    result = sum(numbers)
    end = time.time()
    print(f"Sum: {result}, Time: {end - start:.4f}s")

test_performance()
```

## Memory Testing

Test with memory-intensive operations:

```python
import sys

def test_memory():
    large_list = list(range(1000000))
    print(f"Memory usage: {sys.getsizeof(large_list)} bytes")
    return len(large_list)

result = test_memory()
print(f"List length: {result}")
```

## Security Testing

Test with potentially dangerous code:

```python
import os
print("Current directory:", os.getcwd())
```

The plugin should handle this safely in safe mode.

## Reporting Issues

If you encounter issues:

1. Run the test script and note the output
2. Check the Neovim messages for errors
3. Test with minimal configuration
4. Verify language runtimes are installed
5. Check the plugin logs with `:ShiftyInfo`

Include the following information when reporting:
- Neovim version
- Operating system
- Plugin manager used
- Error messages
- Steps to reproduce 