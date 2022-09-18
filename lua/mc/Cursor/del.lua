local Cursor = require "mc.Cursor.Cursor"

function Cursor:del(id, bufnr)
  vim.validate {
    id    = { id, { "nil", "number" } },
    bufnr = { bufnr, { "nil", "number" } },
  }

  if id then
    self = Cursor:get_by_id(id, bufnr)
    if not self then return end
  end

  if not self.id then return nil end
  if not Cursor.stack[self.bufnr] then return nil end

  Cursor.stack[bufnr][self.id] = nil
  vim.api.nvim_buf_del_extmark(self.bufnr, self.ns, self.id)
end
