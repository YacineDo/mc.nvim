local Cursor = require "mc.Cursor.Cursor"

function Cursor:each(bufnr, cb)
  vim.validate {
    bufnr = { bufnr, { "nil", "number" } },
    cb    = { cb, "function" },
  }

  local cs = Cursor:get_all(bufnr)
  for index, c in pairs(cs) do
    local id = c[1]
    local cursor = Cursor:get_by_id(id, bufnr)
    if cursor then
      cb(cursor, index)
    end
  end

  return self
end
