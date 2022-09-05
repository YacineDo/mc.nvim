local M = {}

M.create_highlight_groups = function()
  vim.cmd([[
    " highlight default link MCCursor Cursor
    " highlight default link MCCursor Search
    " guifg=#242b38 guibg=#ef5f6b
    " hi MCCursor ctermfg=1 ctermbg=15 guifg=#242b38 guibg=#f0d197 
  ]])
  -- vim.cmd.highlight "MCCursor ctermfg=1 ctermbg=15 guifg=#242b38 guibg=#f0d197"
end

return M
