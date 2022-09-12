local utils = require "mc.Utils"

local fn = vim.fn
local api = vim.api

local Cursor = {}

Cursor.ns = api.nvim_create_namespace('Cursor')
Cursor.__index = Cursor

function Cursor:new(row, col, id, bufnr, active)
  if not bufnr or bufnr == 0 then
    bufnr = fn.bufnr()
  end

  if not active then
    active = true
  end

  vim.validate({
    row = { row, "number" },
    col = { col, "number" },
    id = { id, { "number", "nil" } },
    bufnr = { bufnr, "number" },
    active = { active, "boolean" },
  })

  local cursor = {
    bufnr = bufnr,
    row = row,
    col = col,
    id = id,
    active = active,
  }

  setmetatable(cursor, self)

  cursor:show()

  return cursor
end

function Cursor:del(id, bufnr)
  self.id = id or self.id
  if not self.id then return end

  self.bufnr = bufnr or self.bufnr
  if not self.bufnr or bufnr == 0 then
    self.bufnr = fn.bufnr()
  end

  api.nvim_buf_del_extmark(self.bufnr, self.ns, self.id)

  self.id = nil
  self.row = nil
  self.col = nil
end

function Cursor:show(id)
  self.id = id or self.id

  local char = api.nvim_buf_get_text(
    self.bufnr,
    self.row, self.col,
    self.row, self.col + 1, {})[1]

  if not char or char == "" then
    char = " "
  end

  self.id = api.nvim_buf_set_extmark(
    self.bufnr, self.ns,
    self.row, self.col, {
    id = self.id,
    virt_text = { { char, "MCCursor" } },
    virt_text_pos = "overlay",
  })

  return self
end

function Cursor:hide(id, bufnr)
  self.id = id or self.id
  self.bufnr = bufnr or self.bufnr

  api.nvim_buf_del_extmark(self.bufnr, self.ns, self.id)
end

function Cursor:get_by_id(id, bufnr)
  self.bufnr = bufnr or self.bufnr
  self.id = id or self.id

  if not self.bufnr or bufnr == 0 then
    self.bufnr = fn.bufnr()
  end

  local cursor = api.nvim_buf_get_extmark_by_id(self.bufnr, self.ns, self.id, {})
  if cursor then
    self.id = cursor[1]
    self.row = cursor[2]
    self.col = cursor[3]
  end

  return self
end

function Cursor:get_by_pos(row, col, bufnr)
  self.bufnr = bufnr or self.bufnr
  if not self.bufnr or bufnr == 0 then
    self.bufnr = fn.bufnr()
  end

  return api.nvim_buf_get_extmarks(self.bufnr, self.ns, row, col, {})
end

function Cursor:update(row, col, id, bufnr)
  self.id = id or self.id
  self.bufnr = bufnr or self.bufnr

  if not self.bufnr or bufnr == 0 then
    self.bufnr = fn.bufnr()
  end

  api.nvim_buf_del_extmark(self.bufnr, self.ns, self.id)

  self.row = row or self.row
  self.col = col or self.col

  return self:show()
end

function Cursor:move(dir, count, id, bufnr)
  self.id = id or self.id
  self.bufnr = bufnr or self.bufnr

  local col_copy = utils.copy(self.col)

  if dir == "up" then
    self.row = self.row - count
  end

  if dir == "down" then
    self.row = self.row + count
  end

  if dir == "right" then
    self.col = self.col + count
  end

  if dir == "left" then
    self.col = self.col - count
  end

  local row_len = fn.line "$" - 1
  self.row = self.row > row_len and row_len or self.row
  self.row = self.row < 0 and 0 or self.row

  local col_len = fn.col { self.row + 1, "$" } - 1
  self.col = self.col > col_len and col_len or self.col
  self.col = self.col < 0 and 0 or self.col

  self:update()

  if dir == "up" or dir == "down" then
    self.col = col_copy
  end

  return self
end

function Cursor:all(bufnr)
  self.bufnr = bufnr or self.bufnr
  if not self.bufnr or bufnr == 0 then
    self.bufnr = fn.bufnr()
  end

  return api.nvim_buf_get_extmarks(self.bufnr, self.ns, 0, -1, {})
end

function Cursor:each(bufnr, cb)
  local cursors = self:all(bufnr)

  for index, cursor in pairs(cursors) do
    self.id  = cursor[1]
    self.row = cursor[2]
    self.col = cursor[3]
    cb(self, index)
  end
end

function Cursor:clear(bufnr)
  self:each(bufnr, function(cursor)
    cursor:del()
  end)
end

return Cursor
