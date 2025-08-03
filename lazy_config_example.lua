-- Lazy.nvim configuration example for testing Shifty plugin
-- Add this to your init.lua or a separate config file

return {
  -- Local development setup (for testing before publishing)
  {
    dir = "~/shifty-vim", -- Change this to your local path
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
    end,
  },
  
  -- Production setup (after publishing to GitHub)
  -- {
  --   "TuringProblem/shifty-vim",
  --   config = function()
  --     require("shifty").setup({
  --       keymaps = {
  --         toggle = "<leader>st",
  --         run = "<leader>sr",
  --         clear = "<leader>sc",
  --         close = "<leader>sx",
  --       },
  --       languages = {
  --         python = {
  --           command = "python3",
  --           args = {"-u"},
  --           timeout = 5000,
  --         },
  --         javascript = {
  --           command = "node",
  --           args = {},
  --           timeout = 3000,
  --         },
  --         lua = {
  --           command = "lua",
  --           args = {},
  --           timeout = 2000,
  --         },
  --       },
  --       execution = {
  --         timeout = 5000,
  --         capture_print = true,
  --         safe_mode = true,
  --       },
  --       ui = {
  --         window_width = 80,
  --         window_height = 20,
  --         border = "rounded",
  --       }
  --     })
  --   end,
  -- },
} 