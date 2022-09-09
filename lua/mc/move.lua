local mc = require "mc"
local cursor = require "mc.cursor"
local stack = mc.stack


local DIR = {
  UP = 1,
  Down = 2,
  Right = 3,
  Left = 4
}

local move = function(bufnr, id, dir)
  local c = cursor.getpos(id, bufnr)
  local row, col

  if c then
    row = c.row
    col = c.col
  end

  if dir == DIR.UP then row = row - 1 end
  if dir == DIR.Down then row = row + 1 end
  if dir == DIR.Right then col = col + 1 end
  if dir == DIR.Left then col = col - 1 end

  if row < 0 then row = 0 end

  local last_row = vim.fn.line("$") - 1
  if row > last_row then row = last_row end

  local tmp_col = col
  if col < 0 then col = 0 end

  local lastcol = #vim.fn.getline(row + 1) - 1
  if col > lastcol then col = lastcol end

  cursor.del_by_id(id, bufnr)
  cursor.set(bufnr, id, row, col)

  if dir == DIR.UP or
      dir == DIR.Down then
    stack[bufnr][id].col = tmp_col
  end
end

return function(dir, bufnr)
  if not stack[bufnr] then return end

  for id, _ in pairs(stack[bufnr]) do
    move(bufnr, id, dir)
  end
end
