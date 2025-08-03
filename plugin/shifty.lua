if vim.g.loaded_shifty then
    return
end
vim.g.loaded_shifty = 1

if vim.fn.has('nvim-0.7.0') ~= 1 then
    vim.api.nvim_err_writeln('Shifty requires Neovim 0.7.0 or higher')
    return
end

-- Create the main Shifty command
vim.api.nvim_create_user_command('Shifty', function(opts)
    local success, shifty = pcall(require, 'shifty')
    if not success then
      vim.api.nvim_err_writeln('Shifty plugin not loaded. Run :lua require("shifty").setup() first.')
      return
    end
    
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