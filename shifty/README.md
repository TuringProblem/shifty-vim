# Shifty - Multi-Language REPL for Neovim

A powerful multi-language REPL (Read-Eval-Print Loop) plugin for Neovim that allows you to execute code blocks in various programming languages directly from your editor.

## Features

- 🚀 **Multi-language support**: Execute code in Python, JavaScript, Lua, Rust, Java, C, and more
- 🎯 **Smart code block detection**: Automatically detects and executes code blocks at cursor position
- 📊 **Real-time output**: View execution results in a floating window
- 🔄 **History tracking**: Keep track of all executed code and results
- ⚡ **Fast execution**: Optimized for quick code testing and experimentation
- 🛡️ **Safe execution**: Built-in safety measures for secure code execution

## Requirements

- Neovim 0.7.0 or higher
- Various language runtimes (Python, Node.js, etc.) depending on your needs

## Installation

### Using Lazy.nvim

Add this to your `init.lua`:

```lua
{
  "your-username/shifty",
  config = function()
    require("shifty").setup({
      keymaps = {
        toggle = "<leader>st",  -- Toggle Shifty window
        run = "<leader>sr",     -- Run current code block
        clear = "<leader>sc",   -- Clear output
      },
      languages = {
        -- Custom language configurations
        python = {
          command = "python3",
          args = {"-u"},
        },
        javascript = {
          command = "node",
        },
      }
    })
  end,
}
```

### Using vim-plug

Add this to your `init.vim` or `init.lua`:

```vim
" For init.vim
Plug 'your-username/shifty'

" For init.lua
vim.cmd [[Plug 'your-username/shifty']]
```

Then in your config:

```lua
require("shifty").setup({
  keymaps = {
    toggle = "<leader>st",
    run = "<leader>sr", 
    clear = "<leader>sc",
  }
})
```

## Usage

### Commands

- `:Shifty` or `:ShiftyToggle` - Toggle the Shifty window
- `:ShiftyRun` - Run the code block at cursor position
- `:ShiftyClear` - Clear the output window
- `:ShiftyClose` - Close the Shifty window
- `:ShiftyInfo` - Show system information and available languages

### Keymaps

The plugin will automatically set up keymaps if configured:

- `<leader>st` - Toggle Shifty window
- `<leader>sr` - Run current code block
- `<leader>sc` - Clear output

### Code Block Detection

Shifty automatically detects code blocks in various formats:

**Markdown code blocks:**
````markdown
```python
print("Hello, World!")
```
````

**Fenced code blocks:**
````
```javascript
console.log("Hello from JavaScript!");
```
````

**Language-specific files:**
Just place your cursor anywhere in a Python, JavaScript, Lua, etc. file and run the command.

## Configuration

### Default Configuration

```lua
require("shifty").setup({
  keymaps = {
    toggle = "<leader>st",
    run = "<leader>sr",
    clear = "<leader>sc",
    close = "<leader>sx",
  },
  languages = {
    -- Language-specific configurations
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
    rust = {
      command = "rustc",
      args = {"-o", "/tmp/rust_out", "-"},
      run_command = "/tmp/rust_out",
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
```

### Language Configuration

Each language can be configured with:

- `command`: The executable to run
- `args`: Arguments passed to the command
- `timeout`: Execution timeout in milliseconds
- `run_command`: For compiled languages, the command to run the compiled output
- `file_extension`: File extension for temporary files

## Supported Languages

- **Python** (`python`, `py`)
- **JavaScript** (`javascript`, `js`, `node`)
- **Lua** (`lua`)
- **Rust** (`rust`, `rs`)
- **Java** (`java`)
- **C** (`c`, `cc`, `cpp`)
- **Shell** (`bash`, `sh`, `zsh`)

## Troubleshooting

### Language not found

If a language isn't working, check:

1. The language runtime is installed and in your PATH
2. The language configuration is correct
3. Run `:ShiftyInfo` to see available languages

### Execution timeout

If code execution times out:

1. Increase the timeout in the language configuration
2. Check if the code has infinite loops
3. Verify the language runtime is working

### Permission errors

For compiled languages, ensure:

1. Write permissions in the temporary directory
2. The compiler is properly installed
3. The output directory is writable

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details. 