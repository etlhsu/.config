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

-- Telescope keymaps
local hasTelescope = pcall(require, 'telescope')
if hasTelescope then
  local builtin = require('telescope.builtin')

  vim.keymap.set('n', '<C-p>', builtin.find_files)
  vim.keymap.set('n', '<leader>ff',
    function() builtin.find_files({ find_command = { 'rg', '--files', '--no-ignore-vcs', } }) end)
  vim.keymap.set('n', '<leader>fs',
    function() builtin.live_grep({ additional_args = { '--no-ignore-vcs' } }) end)

  vim.keymap.set('n', '<leader>bf', builtin.buffers)
  vim.keymap.set('n', '<leader>bs', function()
    local results = {}
    for _, v in pairs(Get_open_files(true, vim.loop.cwd())) do
      if vim.fn.isdirectory(v) == 0 then
        table.insert(results, v)
      end
    end
    builtin.live_grep({ search_dirs = results })
  end)

  vim.keymap.set('n', '<leader>df', function()
    builtin.find_files({ search_dirs = { Get_current_buf_dir() } })
  end)
  vim.keymap.set('n', '<leader>ds', function()
    builtin.live_grep({ search_dirs = { Get_current_buf_dir() } })
  end)

  vim.keymap.set('n', '<leader>hs', builtin.help_tags)

  vim.keymap.set('n', '<leader>of', builtin.oldfiles)
  vim.keymap.set('n', '<leader>os', function()
    local results = {}
    for _, v in pairs(vim.v.oldfiles) do
      if vim.fn.isdirectory(v) == 0 then
        table.insert(results, v)
      end
    end
    builtin.live_grep({ search_dirs = results })
  end)

  vim.keymap.set('n', '<leader>te', builtin.resume)

  vim.keymap.set('n', '<leader>vf', function()
    builtin.find_files({ search_dirs = Get_jj_files("@") })
  end
  )
  vim.keymap.set('n', '<leader>vs', function()
    builtin.live_grep({ search_dirs = Get_jj_files("@") })
  end
  )
end

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
