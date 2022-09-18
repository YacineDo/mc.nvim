package.loaded["mc.Cursor"] = nil

local Cursor = require "mc.Cursor"

vim.schedule(function()
  vim.api.nvim_buf_clear_namespace(0, Cursor.ns, 0, -1)

  local c1 = Cursor:new(0, 0)
  local c2 = Cursor:new(1, 0)
  local c3 = Cursor:new(2, 0)
  local c4 = Cursor:new(3, 0)

  -- c1:hide()
  -- c1:show()

  -- P(Cursor:all())

  -- P(c2:prev())
  -- P(c2:next())

  -- local p = Cursor:prev(c2.id)
  -- local n = Cursor:next(c2.id)
  -- P {
  --   { p.id, p.row, p.col },
  --   { c2.id, c2.row, c2.col },
  --   { n.id, n.row, n.col },
  -- }


  -- c1:move("right", 1)
  --     :move("left", 999)
  --     :move("up", 999)
  --     :move("down", 999)
  --
  -- Cursor:move("right", 1, c1.id)
  --     :move("left", 999)
  --     :move("up", 999)
  --     :move("down", 999)


  -- P(Cursor:get_by_id(1, 0))
  -- P(Cursor:get_by_pos(0, 0, 0))

  -- local bufnr = 11
  -- Cursor:clear(11)
  --
  -- local c4 = Cursor:new(0, 0, nil, bufnr)
  -- local c5 = Cursor:new(0, 5, nil, bufnr)
  --
  -- P(c2:all(bufnr))
  -- P(Cursor:all(bufnr))

  -- P(Cursor:all())

  Cursor:each(0, function(cursor, index)
    -- local id = cursor.id
    -- local row = cursor.row
    -- local col = cursor.col
    -- P(id, row, col, index)

    cursor:move("right", 4)
    --     :move("down", 10)
    --     :move("left", 1)
    --     :move("down", 4)
    --     :move("right", 10)
  end)
  Cursor:each(0, function(cursor)
    cursor:move("down", 2)
  end)
  -- P(Cursor:all())

  -- c1:update(nil, 1)
  -- c2:update(2, nil)

  -- c2:del(2, nil)

end)



--
