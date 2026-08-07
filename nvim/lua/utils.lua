local expansion_keywords = { '~' }
local expansion_keywords_map = {}
for _, expansion_keyword in pairs(expansion_keywords) do
  expansion_keywords_map[expansion_keyword] = vim.fn.expand(expansion_keyword)
end
function Shorten_path(path)
  for expansion_keyword, expansion_keyword_value in pairs(expansion_keywords_map) do
    local start_index, end_index = path:find(expansion_keyword_value, 1, true)
    if start_index ~= nil and end_index ~= nil then
      path = path:sub(1, start_index - 1) .. expansion_keyword .. path:sub(end_index + 1, -1)
    end
  end
  return path
end

function Create_relative_path(absolute_path)
  local cwd = vim.fn.getcwd() .. "/"
  if absolute_path:sub(1, #cwd) == cwd then
    return absolute_path:sub(#cwd + 1)
  end
  return absolute_path
end

function Get_open_files()
  local bufnrs = vim.tbl_filter(function(b)
    return 1 == vim.fn.buflisted(b)
  end, vim.api.nvim_list_bufs())
  if not next(bufnrs) then
    return
  end

  local filelist = {}
  for _, bufnr in ipairs(bufnrs) do
    local file = vim.api.nvim_buf_get_name(bufnr)

    local ft = vim.api.nvim_get_option_value("ft", { buf = bufnr })
    local bt = vim.api.nvim_get_option_value("bt", { buf = bufnr })

    if ft == "netrw" or bt ~= "" then
    else
      local relative_path = Create_relative_path(file)
      local shortened_path = Shorten_path(relative_path)
      table.insert(filelist, shortened_path)
    end
  end
  return filelist
end

function Get_current_buf_dir()
  if vim.bo.filetype == "netrw" then
    return vim.fn.expand('%')
  else
    return vim.fn.expand('%:h')
  end
end

function Get_jj_files(rev)
  local files = {}

  local handle = io.popen("jj diff --summary -r " .. "\"" .. rev .. "\"")
  if not handle then
    error("Command did not execute successfully")
  end

  for line in handle:lines() do
    local status = string.sub(line, 1, 1)

    -- Checking for eligible statues
    if status == "A" or status == "M" or status == "C" or status == "R" then
      local file_path = ""
      -- If there is an arrow in the status line, use the file path after the arrow
      local _, end_pos = string.find(line, "->", 1, true)
      if end_pos then
        file_path = string.sub(line, end_pos + 2)
      else
        file_path = string.sub(line, 3)
      end
      local short_path = Shorten_path(file_path)

      table.insert(files, short_path)
    end
  end

  handle:close()
  return files
end

function Get_oldfiles(check_files)
  local oldfiles = {}
  for _, file in ipairs(vim.v.oldfiles) do
    if not check_files or vim.fn.filereadable(file) == 1 then
      table.insert(oldfiles, file)
    end
  end
  if check_files then
    table.sort(oldfiles, function(a, b)
      local time_a = vim.uv.fs_stat(a).mtime.sec
      local time_b = vim.uv.fs_stat(b).mtime.sec

      return time_a > time_b
    end)
  end

  for i, file in ipairs(oldfiles) do
    local relative_path = Create_relative_path(file)
    local shortened_path = Shorten_path(relative_path)
    oldfiles[i] = shortened_path
  end
  return oldfiles
end

local function open_fzf_float(fzf_cmd, on_select)
  local width = math.min(math.floor(vim.o.columns * 0.75), 150)
  local height = math.min(math.floor(vim.o.lines * 0.75), 50)
  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
  }

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, win_opts)

  vim.fn.jobstart(
    fzf_cmd,
    {
      term = true,
      on_exit = function(_, exit_code, _)
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
        end

        if exit_code == 0 then
          local line = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '')
          if on_select == nil then
            vim.cmd("edit " .. line)
          else
            on_select(line)
          end
        end
      end
    }
  )

  vim.cmd("startinsert")
end

local function set_fzf_keymap(lhs, create_fzf_cmd, on_select)
  vim.keymap.set("n", lhs, function()
    open_fzf_float(create_fzf_cmd(), on_select)
  end)
end

local function set_rg_fzf_keymap(lhs, create_rg_cmd, on_select)
  set_fzf_keymap(lhs, create_rg_cmd,
    function(selection)
      local first_colon_pos = string.find(selection, ":")
      local second_colon_pos = string.find(selection, ":", first_colon_pos + 1)
      local file = string.sub(selection, 1, first_colon_pos - 1)
      local line = string.sub(selection, first_colon_pos + 1, second_colon_pos - 1)
      if on_select == nil then
        vim.cmd("edit +" .. line .. " " .. file)
      else
        on_select(file, line)
      end
    end
  )
end

function Set_fzf_dir_keymap(lhs, create_dir, on_select)
  set_fzf_keymap(lhs, function() return 'cd ' .. create_dir() .. ' && fzf --reverse' end, on_select)
end

function Set_fzf_files_keymap(lhs, create_files, on_select)
  set_fzf_keymap(lhs, function()
    return 'echo \"' .. table.concat(create_files(), '\n') .. '\" | fzf --reverse'
  end, on_select)
end

function Set_rg_fzf_dir_keymap(lhs, create_dir, on_select)
  set_rg_fzf_keymap(lhs, function()
    return 'cd ' ..
        create_dir() ..
        [[ && rg --color=always --line-number --no-heading "" | fzf --reverse --ansi --color "hl:-1:underline,hl+:-1:underline:reverse" --delimiter : ]]
  end, on_select)
end

function Set_rg_fzf_files_keymap(lhs, create_files, on_select)
  set_rg_fzf_keymap(lhs, function()
    return 'rg --color=always --line-number --no-heading "" ' ..
        table.concat(create_files(), " ") .. [[ | \
  fzf --reverse --ansi --color "hl:-1:underline,hl+:-1:underline:reverse" --delimiter : ]]
  end, on_select)
end

function Fetch_jj_content(rev, relative_path)
  local cmd = { "jj", "file", "show", "-r", rev, relative_path }
  local result = vim.system(cmd, { text = true }):wait()

  if result.code ~= 0 then
    return nil, result.stderr
  end

  local split_lines = vim.split(result.stdout or "", "\n", { trimempty = false })
  -- Remove the last line which is a newline separator
  table.remove(split_lines)
  return split_lines, nil
end

function Get_jj_root()
  local result = vim.system({ 'jj', 'root' }, { text = true }):wait()

  if result.code ~= 0 then
    vim.notify("Error when running jj root: " .. result.stderr, vim.log.levels.ERROR)
    return nil
  end

  -- Remove the last character which is a newline separator
  return string.sub(result.stdout, 1, -2)
end

function Create_jj_summary(rev)
  local cmd = { "jj", "diff", "-r", rev, "--summary" }
  local result = vim.system(cmd, { text = true }):wait()

  if result.code ~= 0 then
    return nil, result.stderr
  end

  local split_lines = vim.split(result.stdout or "", "\n", { trimempty = false })
  -- Remove the last line which is a newline separator
  table.remove(split_lines)
  return split_lines, nil
end

function Get_jj_file_list(rev)
  local cmd = { "jj", "file", "list", "-r", rev }
  local result = vim.system(cmd, { text = true }):wait()

  if result.code ~= 0 then
    vim.notify("Error when running jj file list: " .. result.stderr, vim.log.levels.ERROR)
    return nil
  end

  local split_lines = vim.split(result.stdout or "", "\n", { trimempty = false })
  -- Remove the last line which is a newline separator
  table.remove(split_lines)
  return split_lines
end

local candidates = {}
function Set_complete_file_keymap(lhs, cmd, create_candidates, opts)
  local select_cmd = opts.cmd
  vim.api.nvim_create_user_command(cmd, function(opts)
    local input = opts.args

    -- Set the file to be the first matching candidate
    local file = nil
    for _, candidate in ipairs(candidates[cmd]) do
      if candidate == input then
        file = candidate
        break
      end
    end

    if file == nil then
      for _, candidate in ipairs(candidates[cmd]) do
        if string.find(candidate:lower(), input:lower()) ~= nil then
          file = candidate
          break
        end
      end
    else
      file = input
    end

    if select_cmd == nil then
      vim.cmd('edit ' .. vim.fn.expand(file))
    else
      select_cmd(file)
    end
  end, {
    nargs = '?',
    complete = function(arg_lead, _, _)
      return vim.tbl_filter(
        function(item)
          return string.find(item:lower(), arg_lead:lower()) ~= nil
        end, candidates[cmd])
    end
  })

  vim.keymap.set('n', lhs, function()
    candidates[cmd] = create_candidates()
    vim.api.nvim_feedkeys(':' .. cmd .. ' ', 'n', false)
  end)
end

function Get_files_recursive(dir)
  local files = {}
  -- Runs shell command to find only files (-type f)
  local handle = io.popen('find "' .. dir .. '" -type f')

  if handle then
    for line in handle:lines() do
      table.insert(files, line)
    end
    handle:close()
  end

  return files
end
