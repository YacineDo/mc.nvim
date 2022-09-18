local Cursor = require "mc.Cursor.Cursor"

function Cursor:get_by_id(id, bufnr)
  if not id then
    return nil
  end

  bufnr = bufnr or self.bufnr
  if not bufnr or bufnr == 0 then
    bufnr = vim.fn.bufnr()
  end

  vim.validate {
    id    = { id, "number" },
    bufnr = { bufnr, "number" },
  }


  local m = vim.api.nvim_buf_get_extmark_by_id(bufnr, self.ns, id, {})
  if not m then return nil end
  local row, col = unpack(m)

  if not Cursor.stack[bufnr] then
    return nil
  end
  local curswant = Cursor.stack[bufnr][id].curswant
  local active   = Cursor.stack[bufnr][id].active

  return Cursor:new(row, col, {
    id       = id,
    bufnr    = bufnr,
    curswant = curswant,
    active   = active,
  })
end
