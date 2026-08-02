-- From https://github.com/neovim/nvim-lspconfig
vim.lsp.config['bashls'] = {
  cmd = { 'bash-language-server', 'start' },
  filetypes = { 'bash', 'sh' },
}
vim.lsp.config['kotlin_lsp'] = {
  filetypes = { 'kotlin' },
  cmd = { 'kotlin-lsp', '--stdio' },
  root_markers = { 'settings.gradle', 'settings.gradle.kts', 'build.gradle', 'build.gradle.kts' },
}
vim.lsp.config['lua_ls'] = {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc' },
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if path ~= vim.fn.stdpath('config')
          and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
      then
        return
      end
    end

    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = {
        version = 'LuaJIT',
        path = {
          'lua/?.lua',
          'lua/?/init.lua',
        },
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        library = vim.api.nvim_get_runtime_file('', true),
      },
    })
  end,
  settings = {
    Lua = {},
  },
}

vim.lsp.enable({ 'bashls', 'kotlin_lsp', 'lua_ls' })
vim.lsp.codelens.enable(true)
vim.lsp.linked_editing_range.enable(true)
vim.lsp.inlay_hint.enable(true)
vim.lsp.inline_completion.enable(true)
