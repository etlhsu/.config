-- Starting Options
vim.o.autocomplete = true
vim.o.autowriteall = true
vim.o.colorcolumn = '100'
vim.o.completeopt = 'fuzzy,menu,menuone,noinsert,noselect,popup'
vim.o.gdefault = true
vim.o.hidden = false
vim.o.number = true
vim.o.shiftwidth = 2
vim.o.swapfile = false
vim.o.undofile = true
vim.o.splitbelow = true
vim.g.mapleader = ' '
vim.g.netrw_banner = 0
vim.g.netrw_list_hide = '^\\./$,^\\.\\./$,.DS_Store';
vim.g.netrw_winsize = 20
vim.cmd.colorscheme('retrobox')

-- Navigate netrw like ranger
vim.cmd([[ au filetype netrw map <buffer> h -^| map <buffer> l <CR>| map <buffer> . gh| ]])
vim.cmd([[ au filetype netrw map <buffer> L <CR><C-R>=vim.g.netrw_preview| ]])

-- Install plugins
vim.pack.add({
  'https://github.com/nvim-treesitter/nvim-treesitter.git',
})

-- Telescope
local hasTelescope, telescope = pcall(require, 'telescope')
if hasTelescope then
  telescope.setup({
    defaults = {
      sorting_strategy = 'ascending',
      layout_strategy = 'center',
    }
  })
end

-- Treesitter
require('nvim-treesitter').install { 'astro', 'bash', 'c', 'css', 'go', 'html', 'java', 'kotlin',
  'lua', 'markdown', 'markdown_inline', 'proto', 'tsx', 'typescript', 'vim', 'vimdoc' }
