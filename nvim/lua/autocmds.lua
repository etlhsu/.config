-- Save when switching buffers, windows, or leaving Neovim
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost" }, {
  group = vim.api.nvim_create_augroup('AutoWriteChange', {}),
  callback = function()
    -- Only save if the buffer is modifiable, has a name, and is modified
    if not vim.bo.readonly and vim.bo.modified and vim.fn.expand("%") ~= "" then
      vim.cmd("silent update")
    end
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup('RestoreCursor', {}),
  callback = function(args)
    local line                 = vim.fn.line("'\"")
    local last_line            = vim.fn.line('$')
    local filetype             = vim.bo[args.buf].filetype

    local disallowed_filetypes = { 'commit', 'xxd', 'gitrebase' }
    local is_allowed_filetype  = true
    for _, disallowed_filetype in pairs(disallowed_filetypes) do
      if disallowed_filetype == filetype then
        is_allowed_filetype = false
        break
      end
    end

    local diff = vim.wo[vim.api.nvim_get_current_win()].diff

    if line >= 1 and line <= last_line and is_allowed_filetype and not diff then
      vim.cmd('normal! g`"zz')
    end
  end,
})

vim.api.nvim_create_autocmd("CmdlineChanged", {
  group = vim.api.nvim_create_augroup('CmdlineAutocompletion', {}),
  pattern = { ":", "/", "%?" },
  callback = function()
    vim.fn.wildtrigger()
  end,
})
