local Cursor = require "mc.Cursor.Cursor"

function Cursor:prev(count, id, bufnr)
  vim.validate {
    id    = { id, { "nil", "number" } },
    bufnr = { bufnr, { "nil", "number" } },
    count = { count, { "nil", "number" } },
  }

  id = id or self.id
  if not id then return nil end

  bufnr = bufnr or self.bufnr

  local cursor = Cursor:get_by_id(id, bufnr)
  if not cursor then return nil end

  local prev = vim.api.nvim_buf_get_extmarks(cursor.bufnr, self.ns,
    0, { cursor.row, cursor.col }, {})

  count = count or 1
  if count < 0 or count >= #prev then
    return nil
  end

  id = prev[#prev - count][1]
  return Cursor:get_by_id(id, bufnr)
end
