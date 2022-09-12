local Cursor = require "mc.Cursor"

vim.schedule(function()

  Cursor:clear(0)

  local c1 = Cursor:new(0, 0)
  -- local c2 = Cursor:new(1, 0)

  -- c1:hide()
  -- c1:show()

  c1:move("right", 1)
      :move("up", 999)
      :move("down", 999)
      :move("left", 999)

  -- P(c2:all())

  -- P(Cursor:get_by_id(1, 0))
  -- P(Cursor:get_by_pos(0, 0, 0))

  -- local bufnr = 11
  -- Cursor:clear(11)
  --
  -- local c3 = Cursor:new(0, 0, nil, bufnr)
  -- local c4 = Cursor:new(0, 5, nil, bufnr)
  --
  -- P(c2:all(bufnr))
  -- P(Cursor:all(bufnr))

  Cursor:each(0, function(cursor, index)
    -- local id = cursor.id
    -- local row = cursor.row
    -- local col = cursor.col
    -- P(id, row, col, index)

    -- cursor:move("right", 4)
  end)

  -- c1:update(nil, 1)
  -- c2:update(2, nil)

end)



--
