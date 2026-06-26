-- Create a file in the directory of the current file
vim.api.nvim_create_user_command('E', function(opts)
  local file = opts.args
  if file[0] ~= '/' then
    file = vim.fn.expand('%:h') .. '/' .. file
  end
  vim.cmd('edit ' .. file)
end, {
  complete = function(input)
    local dir = ''
    local dir_path = vim.fn.expand('%:h')
    local start_dir, end_dir = input:find('.+/')
    if start_dir ~= nil then dir = input:sub(start_dir, end_dir) end
    local start_input = ''
    if dir ~= '' then
      dir_path = dir_path .. '/' .. dir
      if #input ~= #dir then
        start_input = input:sub(#dir + 1, #input)
      end
    else
    end
    local handle = io.popen('cd ' .. dir_path .. ' && ls -p')
    if handle == nil then error("Cannot create handle for " .. dir_path) end
    local results = handle:read("*a")
    handle:close()
    local completes = {}
    for result in string.gmatch(results, "[^%s]+") do
      if input ~= ' ' and result:find('^' .. start_input) ~= nil then
        completes[#completes + 1] = dir .. result
      end
    end
    return completes
  end,
  nargs = 1
})

-- Rename/move the current file to a new location
vim.api.nvim_create_user_command('Mv', function(opts)
  local file = opts.args
  local oldfile = vim.fn.expand('%')
  if string.match(file, '/') == nil then
    file = vim.fn.expand('%:h') .. '/' .. file
  end
  local old_buf = vim.api.nvim_get_current_buf()
  local old_bufname = vim.fn.bufname(old_buf)
  vim.cmd('saveas ' .. file)
  os.remove(oldfile)
  vim.api.nvim_buf_delete(vim.fn.bufnr(old_bufname), {})
end, { complete = 'file', nargs = 1 })
