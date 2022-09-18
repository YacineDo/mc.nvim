local Cursor = require "mc.Cursor.Cursor"
local utils = require "mc.Utils"

function Cursor:get_by_pos(row, col, bufnr)
  vim.validate {
    row   = { row, { "nil", "number" } },
    col   = { col, { "nil", "number" } },
    bufnr = { bufnr, { "nil", "number" } },
  }

  bufnr = bufnr or self.bufnr
  if not bufnr or bufnr == 0 then
    bufnr = vim.fn.bufnr()
  end

  local row_len = vim.api.nvim_buf_call(bufnr, utils.get_row_len)
  if row < 0 or row > row_len then return nil end

  local col_len = vim.api.nvim_buf_call(bufnr, function()
    return utils.get_col_len(row)
  end)
  if col < 0 or col > col_len then return nil end

  return vim.api.nvim_buf_get_extmarks(bufnr, self.ns,
    { row, col }, { row, col }, {})
end
