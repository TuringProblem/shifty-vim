# Installation Guide for Shifty

This guide will help you install the Shifty Neovim plugin using various package managers.

## Prerequisites

- Neovim 0.7.0 or higher
- Git (for cloning the repository)

## Installation Methods

### Method 1: Using Lazy.nvim (Recommended)

If you're using [Lazy.nvim](https://github.com/folke/lazy.nvim), add this to your `init.lua`:

```lua
{
  "TuringProblem/shifty-vim",
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

### Method 2: Using vim-plug

If you're using [vim-plug](https://github.com/junegunn/vim-plug), add this to your `init.vim`:

```vim
Plug 'TuringProblem/shifty-vim'
```

Or in your `init.lua`:

```lua
vim.cmd [[Plug 'TuringProblem/shifty-vim']]
```

Then add the configuration:

```lua
require("shifty").setup({
  keymaps = {
    toggle = "<leader>st",
    run = "<leader>sr", 
    clear = "<leader>sc",
  }
})
```

### Method 3: Using Packer

If you're using [Packer](https://github.com/wbthomason/packer.nvim), add this to your `init.lua`:

```lua
use {
  'TuringProblem/shifty-vim',
  config = function()
    require("shifty").setup({
      keymaps = {
        toggle = "<leader>st",
        run = "<leader>sr",
        clear = "<leader>sc",
      }
    })
  end
}
```

### Method 4: Manual Installation

1. Clone the repository:
```bash
git clone https://github.com/TuringProblem/shifty-vim.git ~/.local/share/nvim/site/pack/plugins/start/shifty-vim
```

2. Add the configuration to your `init.lua`:
```lua
require("shifty").setup({
  keymaps = {
    toggle = "<leader>st",
    run = "<leader>sr",
    clear = "<leader>sc",
  }
})
```

## Configuration

### Basic Configuration

```lua
require("shifty").setup({
  keymaps = {
    toggle = "<leader>st",    -- Toggle Shifty window
    run = "<leader>sr",       -- Run current code block
    clear = "<leader>sc",     -- Clear output
    close = "<leader>sx",     -- Close window
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

### Language Runtimes

Make sure you have the following language runtimes installed:

- **Python**: `python3` or `python`
- **JavaScript**: `node` (Node.js)
- **Lua**: `lua`
- **Rust**: `rustc` (Rust compiler)
- **Java**: `javac` and `java`
- **C**: `gcc` or `clang`

## Usage

After installation and configuration:

1. Open a file with code blocks (like a markdown file)
2. Use `:ShiftyToggle` or your configured keymap to open the REPL window
3. Place your cursor in a code block and use `:ShiftyRun` to execute it

### Available Commands

- `:Shifty` or `:ShiftyToggle` - Toggle the Shifty window
- `:ShiftyRun` - Run the code block at cursor position
- `:ShiftyClear` - Clear the output window
- `:ShiftyClose` - Close the Shifty window
- `:ShiftyInfo` - Show system information and available languages

## Troubleshooting

### Plugin not loading

1. Check that the plugin is properly installed in your package manager
2. Verify that the repository URL is correct: `TuringProblem/shifty-vim`
3. Restart Neovim after installation

### Language not working

1. Ensure the language runtime is installed and in your PATH
2. Check the language configuration in your setup
3. Run `:ShiftyInfo` to see available languages

### Permission errors

For compiled languages, ensure:
1. Write permissions in the temporary directory
2. The compiler is properly installed
3. The output directory is writable

## Support

If you encounter any issues:

1. Check the [GitHub repository](https://github.com/TuringProblem/shifty-vim) for issues
2. Run `:ShiftyInfo` to get system information
3. Check that all language runtimes are properly installed 