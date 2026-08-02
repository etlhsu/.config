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

vim.api.nvim_create_user_command('Wso', function()
  vim.cmd('write | source')
end, {})

-- Function to update diff content dynamically based on current source window buffer
local function update_diff_buffer(source_win, diff_win, rev)
  if not vim.api.nvim_win_is_valid(source_win) or not vim.api.nvim_win_is_valid(diff_win) then
    return false
  end

  local source_buf = vim.api.nvim_win_get_buf(source_win)
  local source_file = vim.api.nvim_buf_get_name(source_buf)
  local diff_buf = vim.api.nvim_win_get_buf(diff_win)

  local source_buf_type = vim.bo[source_buf].buftype
  local root = Get_jj_root()

  local skip_text = ""
  if source_buf_type ~= "" then
    skip_text = 'source buffer type is ' .. source_buf_type .. ', must be a normal buffer'
  elseif source_file:sub(1, #root) ~= root then
    skip_text = 'file is not in JJ root ' .. root
  end

  local new_content = {}
  local enable_diff = false
  if skip_text == "" then
    local content, err = Fetch_jj_content(rev, source_file)
    if err == nil then
      new_content = content
      enable_diff = true
      vim.bo[diff_buf].filetype = vim.bo[source_buf].filetype
    else
      new_content = { 'File was added' }
      vim.bo[diff_buf].filetype = 'markdown'
    end
  else
    new_content = { 'Skipping: ' .. skip_text }
    vim.bo[diff_buf].filetype = 'markdown'
  end
  -- Synchronize filetype and buffer content
  local relative_path = Create_relative_path(source_file)
  vim.api.nvim_buf_set_name(diff_buf, 'jj(' .. rev .. '):' .. relative_path)

  vim.bo[diff_buf].readonly = false
  vim.bo[diff_buf].modifiable = true
  vim.api.nvim_buf_set_lines(diff_buf, 0, -1, false, new_content)
  vim.bo[diff_buf].modifiable = false
  vim.bo[diff_buf].readonly = true

  vim.api.nvim_win_call(diff_win, function()
    if enable_diff then
      vim.cmd("diffthis")
    else
      vim.cmd("diffoff")
    end
  end)

  vim.api.nvim_win_call(source_win, function()
    if enable_diff then
      if not vim.wo.diff then
        vim.cmd("diffthis")
      end
      vim.cmd("diffupdate")
    end
  end)
end

vim.api.nvim_create_user_command("Diff", function(opts)
  local rev = opts.args
  if opts.args == "" then
    rev = "@-"
  end
  local source_win = vim.api.nvim_get_current_win()

  local diff_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[diff_buf].buftype = "nofile"
  vim.bo[diff_buf].bufhidden = "wipe"
  vim.cmd("split")
  local diff_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(diff_win, diff_buf)
  update_diff_buffer(source_win, diff_win, rev)
  vim.wo[diff_win].winfixbuf = true
  vim.cmd("wincmd p")

  local augroup = vim.api.nvim_create_augroup("JJDiffTracker_" .. diff_buf, { clear = true })
  vim.api.nvim_create_autocmd({ "BufEnter" }, {
    group = augroup,
    callback = function()
      -- Only trigger when active in or updating the source window
      if vim.api.nvim_get_current_win() == source_win then
        update_diff_buffer(source_win, diff_win, rev)
      end
    end,
  })
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = augroup,
    buffer = diff_buf,
    callback = function()
      if vim.api.nvim_win_is_valid(source_win) then
        vim.api.nvim_win_call(source_win, function()
          vim.cmd("diffoff")
        end)
      end
    end,
  })
end, { nargs = "?" })

vim.api.nvim_create_user_command('Cjj', function(opts)
  local rev = opts.args
  if opts.args == "" then
    rev = "@"
  end

  local summary, err = Create_jj_summary(rev)
  if err ~= nil then
    vim.notify("Error when getting jj summary: " .. err, vim.log.levels.ERROR)
  end

  local items = {}
  for _, entry in ipairs(summary) do
    local item = { filename = entry:sub(3, -1), lnum = 1, col = 1, type = entry:sub(1, 1) }
    table.insert(items, item)
  end

  vim.fn.setqflist({}, ' ', {
    title = 'JJ Files ' .. rev,
    items = items
  })
  vim.cmd('copen')
end, { nargs = "?" })

vim.api.nvim_create_user_command('Messages', function()
  vim.cmd("enew")
  local buf = vim.api.nvim_get_current_buf()

  local messages = vim.fn.execute('messages')
  local lines = vim.split(messages, '\n', { plain = true })
  table.remove(lines, 1)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].modifiable = false
  vim.bo[buf].readonly = true
end, {})

vim.api.nvim_create_user_command('Cdiagnostic', function()
  vim.diagnostic.setqflist()
  vim.cmd('copen')
end, {})
