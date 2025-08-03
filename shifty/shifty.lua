if vim.g.loaded_shifty then
    return
end
vim.g.loaded_shifty = 1

if vim.fn.has('nvim-0.7.0') ~= 1 then
    vim.api.nvim_err_writeln('Shifty requires Neovim 0.7.0 or higher')
    return
end

vim.api.nvim_create_user_command('Shifty', function(opts)
    local shifty = require('andrew.plugins.custom.shifty')
    
    if opts.args == 'toggle' or opts.args == '' then
      shifty.toggle()
    elseif opts.args == 'run' then
      shifty.run_current_block()
    elseif opts.args == 'clear' then
      shifty.clear_output()
    elseif opts.args == 'close' then
      shifty.close()
    else
      print('Unknown command: ' .. opts.args)
      print('Available commands: toggle, run, clear, close')
    end
  end, {
    nargs = '?',
    complete = function()
      return {'toggle', 'run', 'clear', 'close'}
    end,
    desc = 'Shifty HOT compiler commands'
  })
