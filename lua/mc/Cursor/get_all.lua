local Cursor = require "mc.Cursor.Cursor"

function Cursor:get_all(bufnr)
  vim.validate {
    bufnr = { bufnr, { "nil", "number" } },
  }

  bufnr = bufnr or self.bufnr
  if not bufnr or bufnr == 0 then
    bufnr = vim.fn.bufnr()
  end

  return vim.api.nvim_buf_get_extmarks(bufnr, self.ns, 0, -1, {})
end
