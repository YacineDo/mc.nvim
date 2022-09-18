local Cursor = require "mc.Cursor.Cursor"

function Cursor:show(id, bufnr)
  vim.validate {
    id    = { id, { "nil", "number" } },
    bufnr = { bufnr, { "nil", "number" } },
  }

  if id then
    self = self:get_by_id(id, bufnr)
    if not self then return nil end
  end

  local char = vim.api.nvim_buf_get_text(
    self.bufnr,
    self.row, self.col,
    self.row, self.col + 1, {})[1]
  char = char ~= "" and char or " "

  self.id = vim.api.nvim_buf_set_extmark(
    self.bufnr, self.ns,
    self.row, self.col, {
    id = self.id,
    virt_text = { { char, "MCCursor" } },
    virt_text_pos = "overlay",
  })

  return self
end
