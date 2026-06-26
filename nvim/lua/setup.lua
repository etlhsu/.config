-- Starting Options
vim.opt.autowriteall = true
vim.opt.colorcolumn = '100'
vim.opt.completeopt = { "menu", "menuone", "noselect", "noinsert" }
vim.opt.gdefault = true
vim.opt.hidden = false
vim.opt.number = true
vim.opt.shiftwidth = 2
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.splitbelow = true
vim.g.mapleader = ' '
vim.g.netrw_banner = 0
vim.g.netrw_list_hide = '^\\./$,^\\.\\./$,.DS_Store';
vim.g.netrw_winsize = 20
vim.cmd.colorscheme('retrobox')

-- Abbreviations (triggered by entering a sequence and <space> in insert mode)
vim.cmd([[
  func! Eatchar()
     let c = nr2char(getchar(0))
     return (c =~ '\s') ? '' : c
  endfunc
  command! -nargs=+ Eia ia<space><args><C-R>=Eatchar()<CR>
  Eia uenv #!/usr/bin/env
  Eia ktci import kotlinx.coroutines.
  Eia ktcf import kotlinx.coroutines.flow.
  Eia moci import org.mockito.kotlin.
  Eia comi import androidx.compose.
]])

-- Navigate netrw like ranger
vim.cmd([[ au filetype netrw map <buffer> h -^| map <buffer> l <CR>| map <buffer> . gh| ]])
vim.cmd([[ au filetype netrw map <buffer> L <CR><C-R>=vim.g.netrw_preview| ]])

-- Install plugins
vim.pack.add({
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-treesitter/nvim-treesitter.git',
  'https://github.com/neovim/nvim-lspconfig.git',
  'https://github.com/nvim-mini/mini.nvim.git',
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

-- Treesitter and LSP
local hasTreesitterConfigs, treesitterConfigs = pcall(require, 'nvim-treesitter.configs')
if hasTreesitterConfigs then
  treesitterConfigs.setup {
    ensure_installed = { 'astro', 'bash', 'c', 'css', 'go', 'html', 'java', 'kotlin', 'lua', 'markdown',
      'markdown_inline', 'proto', 'query', 'tsx', 'typescript', 'vim', 'vimdoc' },
    highlight = { enable = true }, }
end
require('mini.completion').setup({})
vim.lsp.enable({ 'astro', 'bashls', 'kotlin_lsp', 'lua_ls' })
