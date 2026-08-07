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

-- Update status line to be a separator, and winbar to be status line with improvements
_G.short_path = function()
  local buf = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(buf)
  local relative_path = Create_relative_path(name)
  return Shorten_path(relative_path)
end
vim.o.statusline = "%="
vim.o.winbar =
"%<%{%v:lua.short_path()%} %h%w%m%r %{% v:lua.require('vim._core.util').term_exitcode() %}%=%{% luaeval('(package.loaded[''vim.ui''] and vim.api.nvim_get_current_win() == tonumber(vim.g.actual_curwin or -1) and vim.ui.progress_status()) or '''' ')%}%{% &showcmdloc == 'statusline' ? '%-10.S ' : '' %}%{% exists('b:keymap_name') ? '<'..b:keymap_name..'> ' : '' %}%{% &busy > 0 ? '◐ ' : '' %}%{% luaeval('(package.loaded[''vim.diagnostic''] and next(vim.diagnostic.count()) and vim.diagnostic.status() .. '' '') or '''' ') %}%{% &ruler ? ( &rulerformat == '' ? '%-14.(%l,%c%V%) %P' : &rulerformat ) : '' %}"
local status_line_hl = vim.api.nvim_get_hl(0, { name = "StatusLine" })
local status_line_nc_hl = vim.api.nvim_get_hl(0, { name = "StatusLineNC" })
vim.api.nvim_set_hl(0, "WinBar", status_line_hl)
vim.api.nvim_set_hl(0, "WinBarNC", status_line_nc_hl)
vim.api.nvim_set_hl(0, "StatusLine", { link = "WinSeperator" })
vim.api.nvim_set_hl(0, "StatusLineNC", { link = "WinSeperator" })
