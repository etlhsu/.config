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
      table.insert(filelist, file)
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

  local handle = io.popen("jj diff --summary -r " .. rev)
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

      table.insert(files, file_path)
    end
  end

  handle:close()
  return files
end

function Get_oldfiles()
  local oldfiles = {}
  for _, file in ipairs(vim.v.oldfiles) do
    if vim.fn.filereadable(file) == 1 then
      table.insert(oldfiles, file)
    end
  end
  table.sort(oldfiles, function(a, b)
    local time_a = vim.fn.getftime(a)
    local time_b = vim.fn.getftime(b)

    return time_a > time_b
  end)
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
          local line = vim.api.nvim_buf_get_lines(buf, 0, -1, false)[1]
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
  set_fzf_keymap(lhs, function() return 'cd ' .. create_dir() .. ' && fzf --reverse --preview=\'cat {}\'' end, on_select)
end

function Set_fzf_files_keymap(lhs, create_files, on_select)
  set_fzf_keymap(lhs, function()
    return 'echo \"' .. table.concat(create_files(), '\n') .. '\" | fzf --reverse --preview=\'cat {}\''
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
