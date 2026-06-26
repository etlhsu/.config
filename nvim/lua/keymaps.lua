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

-- Telescope keymaps
local hasTelescope = pcall(require, 'telescope')
if hasTelescope then
  local builtin = require('telescope.builtin')
  local utils = require('telescope.utils')

  vim.keymap.set('n', '<C-p>', builtin.find_files)
  vim.keymap.set('n', '<leader>ff',
    function() builtin.find_files({ find_command = { 'rg', '--files', '--no-ignore-vcs', } }) end)
  vim.keymap.set('n', '<leader>fs',
    function() builtin.live_grep({ additional_args = { '--no-ignore-vcs' } }) end)

  vim.keymap.set('n', '<leader>bf', builtin.buffers)
  vim.keymap.set('n', '<leader>bs', function()
    local results = {}
    for _, v in pairs(get_open_filelist(true, vim.loop.cwd())) do
      if vim.fn.isdirectory(v) == 0 then
        table.insert(results, v)
      end
    end
    builtin.live_grep({ search_dirs = results })
  end)

  vim.keymap.set('n', '<leader>df', function()
    builtin.find_files({ search_dirs = { vim.fn.expand('%:h') } })
  end)
  vim.keymap.set('n', '<leader>ds', function()
    builtin.live_grep({ search_dirs = { vim.fn.expand('%:h') } })
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

  local function get_git_files(rev)
    local handle = io.popen("cd " .. vim.loop.cwd() .. "&& git rev-parse --show-toplevel")
    if handle == nil then
      error("Could not read handle")
    end
    local root = handle:read("*a")
    root = root:sub(1, -2) .. "/"
    handle:close()

    local files = {}
    for _, file in pairs(utils.get_os_command_output({ "git", "diff", rev, "--name-only", }, root)) do
      table.insert(files, root .. file)
    end
    for _, file in pairs(utils.get_os_command_output({ "git", "ls-files", "--others", "--exclude-standard", }, root)) do
      table.insert(files, root .. file)
    end

    for _, v in pairs(files) do
      print(v)
    end
    return files
  end

  vim.keymap.set('n', '<leader>vf', function()
    builtin.find_files({ search_dirs = get_git_files("HEAD~1") })
  end
  )
  vim.keymap.set('n', '<leader>vs', function()
    builtin.live_grep({ search_dirs = get_git_files("HEAD~1") })
  end
  )
  vim.keymap.set('n', '<leader>vaf', function()
    builtin.find_files({ search_dirs = get_git_files("HEAD~3") })
  end
  )
  vim.keymap.set('n', '<leader>vas', function()
    builtin.live_grep({ search_dirs = get_git_files("HEAD~3") })
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
