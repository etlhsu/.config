-- Save when switching buffers, windows, or leaving Neovim
vim.api.nvim_create_autocmd({ "BufLeave" }, {
  callback = function()
    -- Only save if the buffer is modifiable, has a name, and is modified
    if not vim.bo.readonly and vim.bo.modified and vim.fn.expand("%") ~= "" then
      vim.cmd("update")
    end
  end,
})

-- Show LSP completion
-- vim.api.nvim_create_autocmd('LspAttach', {
--   callback = function(ev)
--     -- Enable completion provided by the language server
--     vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, { autotrigger = true })
--   end,
-- })
