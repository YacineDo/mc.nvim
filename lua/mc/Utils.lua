local api = vim.api

local M = {}

M.feedkey = function(mode, key)
  key = api.nvim_replace_termcodes(key, true, false, true)
  api.nvim_feedkeys(key, mode, false)
end

M.copy = function(...)
  return unpack({ ... })
end

return M
