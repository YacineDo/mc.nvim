local M = {}

M.create_highlight_groups = function()
  vim.cmd([[
    hi default MCCursor gui=bold guibg=#ef5f6b guifg=#242b38
  ]])
end

return M
