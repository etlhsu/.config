-- Save when switching buffers, windows, or leaving Neovim
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost" }, {
  callback = function()
    -- Only save if the buffer is modifiable, has a name, and is modified
    if not vim.bo.readonly and vim.bo.modified and vim.fn.expand("%") ~= "" then
      vim.cmd("update")
    end
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("autocompletion-sanitizer", { clear = true }),
  callback = function(ev)
    if vim.bo[ev.buf].buftype ~= "" then vim.bo[ev.buf].autocomplete = false end
  end,
})
