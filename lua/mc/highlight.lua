local M = {}

M.create_highlight_groups = function()
  vim.schedule(function()
    vim.cmd([[
      highlight! default MCCursor gui=bold guibg=#ef5f6b guifg=#242b38
    ]])
  end)
end

return M
