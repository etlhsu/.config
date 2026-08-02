-- Options
vim.g.mapleader = ' '
vim.g.netrw_banner = 0
vim.g.netrw_list_hide = '^\\./$,^\\.\\./$,.DS_Store';
vim.g.netrw_winsize = 20
vim.o.autocomplete = true
vim.o.autoread = true
vim.o.autowriteall = true
vim.o.clipboard = "unnamedplus" -- Copies to clipboard, use standard paste for pasting
vim.o.colorcolumn = '100'
vim.o.complete = 'o,.,]'
vim.o.completeopt = 'fuzzy,menu,menuone,noinsert,noselect,popup,preview'
vim.o.fillchars = "stl:-,stlnc:-"
vim.o.gdefault = true
vim.o.hidden = false
vim.o.laststatus = 0
vim.o.number = true
vim.o.pumheight = 50
vim.o.shiftwidth = 2
vim.o.splitbelow = true
vim.o.swapfile = false
vim.o.undofile = true
vim.o.wildmode = "noselect:lastused"
vim.o.updatetime = 250

vim.cmd.colorscheme('retrobox')

-- Navigate netrw like ranger
vim.cmd([[ au filetype netrw map <buffer> h -^| map <buffer> l <CR>| map <buffer> . gh| ]])
vim.cmd([[ au filetype netrw map <buffer> L <CR><C-R>=vim.g.netrw_preview| ]])

-- Update winbar to match status line, and for status line to be a separator
local new_statusline = "%="
local statusline = vim.opt.statusline:get()
if statusline ~= new_statusline then
  vim.o.winbar = statusline
  vim.o.statusline = new_statusline
end
local status_line_hl = vim.api.nvim_get_hl(0, { name = "StatusLine" })
local status_line_nc_hl = vim.api.nvim_get_hl(0, { name = "StatusLineNC" })
vim.api.nvim_set_hl(0, "WinBar", status_line_hl)
vim.api.nvim_set_hl(0, "WinBarNC", status_line_nc_hl)
vim.api.nvim_set_hl(0, "StatusLine", { link = "WinSeperator" })
vim.api.nvim_set_hl(0, "StatusLineNC", { link = "WinSeperator" })
