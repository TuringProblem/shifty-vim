if vim.g.loaded_shifty then
    return
end
vim.g.loaded_shifty = 1

if vim.fn.has('nvim-0.7.0') ~= 1 then
    vim.api.nvim_err_writeln('Shifty requires Neovim 0.7.0 or higher')
    return
end

-- Get the plugin root directory
local plugin_root = debug.getinfo(1, "S").source:match("@?(.*/)") or ""

-- Add the plugin root to the package path so we can require modules
local package_path = vim.opt.runtimepath:get()
if not package_path:find(plugin_root, 1, true) then
    vim.opt.runtimepath:prepend(plugin_root)
end

-- Create the main Shifty command
vim.api.nvim_create_user_command('Shifty', function(opts)
    local shifty = require('shifty')
    
    if opts.args == 'toggle' or opts.args == '' then
      shifty.toggle()
    elseif opts.args == 'run' then
      shifty.run_current_block()
    elseif opts.args == 'clear' then
      shifty.clear_output()
    elseif opts.args == 'close' then
      shifty.close()
    elseif opts.args == 'info' then
      shifty.show_info()
    else
      print('Unknown command: ' .. opts.args)
      print('Available commands: toggle, run, clear, close, info')
    end
  end, {
    nargs = '?',
    complete = function()
      return {'toggle', 'run', 'clear', 'close', 'info'}
    end,
    desc = 'Shifty Multi-Language REPL commands'
  }) 