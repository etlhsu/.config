local filter = vim.tbl_filter
Path = require("plenary.path")
function get_open_filelist(grep_open_files, cwd)
  if not grep_open_files then
    return nil
  end

  local bufnrs = filter(function(b)
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
      table.insert(filelist, Path:new(file):make_relative(cwd))
    end
  end
  return filelist
end
