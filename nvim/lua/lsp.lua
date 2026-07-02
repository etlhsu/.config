-- From https://github.com/neovim/nvim-lspconfig
vim.lsp.config['bashls'] = {
  cmd = { 'bash-language-server', 'start' },
  settings = {
    bashIde = {
      globPattern = vim.env.GLOB_PATTERN or '*@(.sh|.inc|.bash|.command)',
    },
  },
  filetypes = { 'bash', 'sh' },
  root_markers = { '.git' },
}
vim.lsp.config['kotlin_lsp'] = {
  filetypes = { 'kotlin' },
  cmd = { 'kotlin-lsp' },
  root_markers = { 'settings.gradle', 'settings.gradle.kts', 'build.gradle', 'build.gradle.kts' },
}
vim.lsp.config['lua_ls'] = {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc' },
}

vim.lsp.enable({ 'bashls', 'kotlin_lsp', 'lua_ls' })
