local Cursor = require "mc.Cursor.Cursor"

function Cursor:hide(id, bufnr)
  vim.validate {
    id    = { id, { "nil", "number" } },
    bufnr = { bufnr, { "nil", "number" } },
  }

  if id then
    self = self:get_by_id(id, bufnr)
    if not self then return nil end
  end

  vim.api.nvim_buf_del_extmark(self.bufnr, self.ns, self.id)

  return self
end
