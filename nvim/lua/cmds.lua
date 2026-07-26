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

vim.api.nvim_create_user_command('Wso', function(opts)
  vim.cmd('write | source')
end, {})

vim.api.nvim_create_user_command("Diff", function()
  local source_win = vim.api.nvim_get_current_win()

  -- 1. Capture the original buffer handle and file path
  local source_buf = vim.api.nvim_get_current_buf()
  local file_path = vim.api.nvim_buf_get_name(source_buf)

  if file_path == "" then
    vim.notify("Diff command requires a buffer with a saved file path.", vim.log.levels.WARN)
    return
  end

  -- Get relative file path to handle repo paths cleanly
  local relative_path = vim.fn.fnamemodify(file_path, ":.")

  local initial_lines = Fetch_jj_content("@-", relative_path)
  if not initial_lines then return end

  -- 3. Create a scratch buffer for the `@-` version and load initial content
  local diff_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(diff_buf, 0, -1, false, initial_lines)

  -- Set scratch buffer properties (readonly, unlisted scratch buffer, match filetype)
  local ft = vim.bo[source_buf].filetype
  vim.bo[diff_buf].filetype = ft
  vim.bo[diff_buf].buftype = "nofile"
  vim.bo[diff_buf].bufhidden = "wipe"
  vim.bo[diff_buf].modifiable = false
  vim.bo[diff_buf].readonly = true

  -- Name the buffer for visual context
  vim.api.nvim_buf_set_name(diff_buf, "jj://@-/" .. relative_path)

  -- 4. Open split, put scratch buffer in it, enable diffmode
  vim.cmd("split")
  local diff_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(diff_win, diff_buf)
  vim.cmd("diffthis")
  vim.wo[diff_win].winfixbuf = true

  -- Return focus to original window and enable diffmode on it too
  vim.cmd("wincmd p")
  vim.cmd("diffthis")

  -- Function to update diff content dynamically based on current source window buffer
  local function update_diff_buffer()
    if not vim.api.nvim_win_is_valid(source_win) or not vim.api.nvim_buf_is_valid(diff_buf) then
      return false -- returning false stops/deletes autocmd logic
    end

    local cur_buf = vim.api.nvim_win_get_buf(source_win)
    local cur_file = vim.api.nvim_buf_get_name(cur_buf)

    if cur_file == "" then return end

    local new_lines = Fetch_jj_content("@-", cur_file)
    if new_lines then
      -- Synchronize filetype and buffer content
      vim.bo[diff_buf].filetype = vim.bo[cur_buf].filetype
      vim.api.nvim_buf_set_name(diff_buf, "jj://@-/" .. vim.fn.fnamemodify(cur_file, ":."))

      vim.bo[diff_buf].readonly = false
      vim.bo[diff_buf].modifiable = true
      vim.api.nvim_buf_set_lines(diff_buf, 0, -1, false, new_lines)
      vim.bo[diff_buf].modifiable = false
      vim.bo[diff_buf].readonly = true

      -- Re-trigger diff update to re-align lines
      vim.cmd("diffupdate")

      -- Ensure diff mode is enabled on the active buffer inside source_win
      vim.api.nvim_win_call(source_win, function()
        if not vim.wo.diff then
          vim.cmd("diffthis")
        else
          vim.cmd("diffupdate")
        end
      end)
    end
  end

  local augroup = vim.api.nvim_create_augroup("JJDiffTracker_" .. diff_buf, { clear = true })

  -- Listen to edits AND buffer switching on the source window
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "TextChanged", "TextChangedI" }, {
    group = augroup,
    callback = function()
      -- Only trigger when active in or updating the source window
      if vim.api.nvim_get_current_win() == source_win
          or vim.api.nvim_get_current_buf() == vim.api.nvim_win_get_buf(source_win) then
        update_diff_buffer()
      end
    end,
  })

  -- Cleanup diff mode when either window/buffer is closed
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
end, { desc = "Diff current buffer with Jujutsu @- parent revision" })

vim.api.nvim_create_user_command('Cjj', function(_)
  local files = Get_jj_files("@")

  local items = {}
  for _, file in ipairs(files) do
    local item = { filename = file, lnum = 1, col = 1 }
    table.insert(items, item)
  end

  vim.fn.setqflist({}, 'u', {
    title = 'JJ Files @',
    items = items
  })
  vim.cmd('copen')
end, {})
