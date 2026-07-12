-- Begin escaping terminal insert mode using Ctrl-W
vim.keymap.set('t', '<C-w>', '<C-\\><C-n><C-w>')

-- Go to import section in Java/Kotlin
vim.keymap.set('n', '<leader>gi', '?^import.*\\n.*\\n<CR>:noh<CR>')

-- Yanks file path of current buffer
vim.keymap.set("n", "<leader>yf", function()
  local filename = vim.fn.expand("%")
  vim.fn.setreg("\"", filename)
end)

-- Yanks directory path of current buffer
vim.keymap.set("n", "<leader>yd", function()
  local filename = vim.fn.expand("%")
  local dirname = vim.fs.dirname(filename)
  vim.fn.setreg("\"", dirname)
end)

-- Starts substitution command for replacing the current word
vim.keymap.set('n', '<leader>gr', function()
  vim.api.nvim_feedkeys(':%s/' .. vim.fn.expand('<cword>') .. '/', 'n', {})
end)

-- LSP Keymaps
vim.keymap.set('n', '<leader>ln', vim.lsp.buf.rename)
vim.keymap.set('n', '<leader>la', vim.lsp.buf.code_action)
vim.keymap.set('n', '<leader>lr', vim.lsp.buf.references)
vim.keymap.set('n', '<leader>li', vim.lsp.buf.implementation)
vim.keymap.set('n', '<leader>lt', vim.lsp.buf.type_definition)
vim.keymap.set('n', '<leader>lo', vim.lsp.buf.document_symbol)
vim.keymap.set('n', '<leader>lh', vim.lsp.buf.signature_help)
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)
vim.keymap.set('n', '<leader>ld', vim.lsp.buf.definition)
vim.keymap.set('n', '<leader>K', function() vim.diagnostic.open_float() end)

-- Abbreviations
vim.keymap.set('ia', 'uenv', '#!/usr/bin/env')
vim.keymap.set('ia', 'ktci', 'kotlinx.coroutines')
vim.keymap.set('ia', 'moci', 'org.mockito.kotlin.')
vim.keymap.set('ia', 'comi', 'androidx.compose.')

Set_fzf_files_keymap("<leader>bf", Get_open_files)
Set_fzf_dir_keymap("<leader>ff", function() return vim.loop.cwd() end)
Set_fzf_dir_keymap("<leader>df", function() return Get_current_buf_dir() end,
  function(selection) vim.cmd("edit " .. Get_current_buf_dir() .. "/" .. selection) end
)
Set_fzf_files_keymap("<leader>of", Get_oldfiles)
Set_fzf_files_keymap("<leader>vf", function() return Get_jj_files("@--..@") end)
Set_fzf_files_keymap("<leader>vdf", function() return Get_jj_files("@") end)
Set_fzf_files_keymap("<leader>vaf", function() return Get_jj_files("immutable()..@") end)

Set_rg_fzf_files_keymap("<leader>bs", Get_open_files)
Set_rg_fzf_dir_keymap("<leader>fs", function() return vim.loop.cwd() end)
Set_rg_fzf_dir_keymap("<leader>ds", function() return Get_current_buf_dir() end,
  function(file, line)
    vim.cmd("edit +" .. line .. " " .. Get_current_buf_dir() .. "/" .. file)
  end
)
Set_rg_fzf_files_keymap("<leader>os", Get_oldfiles)
Set_rg_fzf_files_keymap("<leader>vs", function() return Get_jj_files("@") end)
Set_rg_fzf_files_keymap("<leader>vds", function() return Get_jj_files("@") end)
Set_rg_fzf_files_keymap("<leader>vas", function() return Get_jj_files("immutable()..@") end)
