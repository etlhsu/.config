function Get_open_files(grep_open_files, cwd)
  if not grep_open_files then
    return nil
  end

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

    local Path = require("plenary.path")
    if ft == "netrw" or bt ~= "" then
    else
      table.insert(filelist, Path:new(file):make_relative(cwd))
    end
  end
  return filelist
end

function Get_current_buf_dir()
  if vim.bo.filetype == "netrw" then
    return vim.fn.expand('%')
  else
    vim.fn.expand('%:h')
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
