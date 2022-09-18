local Cursor = require "mc.Cursor.Cursor"

function Cursor:move(dir, count, mode)
  vim.validate {
    dir   = { dir, "string" },
    count = { count, "number" },
  }

  if dir == "right" then
    self.col = self.col + count
  end

  if dir == "left" then
    self.col = self.col - count
  end

  if dir == "up" then
    self.row = self.row - count
  end

  if dir == "down" then
    self.row = self.row + count
  end

  if dir == "right" or dir == "left" then
    self.curswant = self.col
  end

  if dir == "up" or dir == "down" then
    self.col = self.curswant
  end

  return self:update(self.row, self.col, { mode = mode })
end
