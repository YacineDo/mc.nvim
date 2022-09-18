local Cursor = require "mc.Cursor.Cursor"

function Cursor:clear(bufnr)
  self:each(bufnr, function(cursor)
    cursor:del()
  end)
end
