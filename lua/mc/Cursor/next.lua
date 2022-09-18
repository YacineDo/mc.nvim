local Cursor = require "mc.Cursor.Cursor"

function Cursor:next(count, id, bufnr)
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

  local next = vim.api.nvim_buf_get_extmarks(bufnr, self.ns,
    { cursor.row, cursor.col }, -1, {})

  count = count or 1
  if count < 0 or count >= #next then
    return nil
  end

  id = next[count + 1][1]
  return Cursor:get_by_id(id, bufnr)
end
