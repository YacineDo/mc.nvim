local fn = vim.fn
local api = vim.api

local M = {}

M.buf = function(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = fn.bufnr()
  end
  return bufnr
end

M.get_row_len = function()
  return fn.line "$" - 1
end

M.get_col_len = function(row)
  return fn.col { row + 1, "$" } - 1
end

M.feedkey = function(mode, key)
  key = api.nvim_replace_termcodes(key, true, false, true)
  api.nvim_feedkeys(key, mode, false)
end

M.copy = function(...)
  return unpack({ ... })
end

return M
