-- Test configuration for Shifty plugin
-- This file can be sourced in Neovim to test the plugin locally

-- Add the current directory to runtime path for local testing
vim.opt.runtimepath:prepend(vim.fn.getcwd())

-- Test the plugin setup
local function test_shifty()
  print("Testing Shifty plugin...")
  
  -- Try to require the plugin
  local success, shifty = pcall(require, 'shifty')
  if not success then
    print("❌ Failed to require shifty module: " .. tostring(shifty))
    return false
  end
  
  print("✅ Successfully required shifty module")
  
  -- Test setup
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
  
  if not setup_success then
    print("❌ Failed to setup shifty plugin")
    return false
  end
  
  print("✅ Successfully setup shifty plugin")
  
  -- Test commands
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
  
  -- Test keymaps
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
  
  print("🎉 Shifty plugin test completed!")
  return true
end

-- Run the test
test_shifty() 