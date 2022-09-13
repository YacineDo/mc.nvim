local utils = require "mc.Utils"

local fn = vim.fn
local api = vim.api

local namespace         = api.nvim_create_namespace
local set_extmark       = api.nvim_buf_set_extmark
local del_extmark       = api.nvim_buf_del_extmark
local get_extmark_by_id = api.nvim_buf_get_extmark_by_id
local get_extmarks      = api.nvim_buf_get_extmarks
local get_text          = api.nvim_buf_get_text
local buf_call          = api.nvim_buf_call

local Cursor = {}

Cursor.ns = namespace('Cursor')
Cursor.__index = Cursor

local _stack = {}

function Cursor:new(row, col, opt)
  local id     = opt.id
  local bufnr  = opt.bufnr
  local active = opt.active

  vim.validate {
    id = { id, { "nil", "number" } },
    row = { row, "number" },
    col = { col, "number" },
    bufnr = { bufnr, { "nil", "number" } },
    active = { active, { "nil", "boolean" } },
  }

  if not bufnr or bufnr == 0 then
    bufnr = fn.bufnr()
  end

  if not active then
    active = true
  end

  local row_len = buf_call(bufnr, utils.get_row_len)
  if row < 0 or row > row_len then
    error("Row Out of Range")
  end

  local col_len = buf_call(bufnr, function()
    return utils.get_col_len(row)
  end)

  if col < 0 or col > col_len then
    error("Column Out of Range")
  end

  local cursor = {
    bufnr = bufnr,
    row = row,
    col = col,
    id = id,
    active = active,
  }

  setmetatable(cursor, self)

  cursor:show()

  _stack[bufnr] = _stack[bufnr] or {}
  _stack[bufnr][cursor.id] = { active = active }

  return cursor
end

function Cursor:show(id, bufnr)
  vim.validate {
    id    = { id, { "nil", "number" } },
    bufnr = { bufnr, { "nil", "number" } },
  }

  if id then
    self = self:get_by_id(id, bufnr)
    if not self then return nil end
  end

  local char = get_text(
    self.bufnr,
    self.row, self.col,
    self.row, self.col + 1, {})[1]
  char = char ~= "" and char or " "

  self.id = set_extmark(
    self.bufnr, self.ns,
    self.row, self.col, {
    id = self.id,
    virt_text = { { char, "MCCursor" } },
    virt_text_pos = "overlay",
  })

  return self
end

function Cursor:hide(id, bufnr)
  vim.validate {
    id    = { id, { "nil", "number" } },
    bufnr = { bufnr, { "nil", "number" } },
  }

  if id then
    self = self:get_by_id(id, bufnr)
    if not self then return nil end
  end

  del_extmark(self.bufnr, self.ns, self.id)

  return self
end

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

  local next = get_extmarks(bufnr, self.ns,
    { cursor.row, cursor.col }, -1, {})

  count = count or 1
  if count < 0 or count >= #next then
    return nil
  end

  id = next[count + 1][1]
  return Cursor:get_by_id(id, bufnr)
end

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

  local prev = get_extmarks(cursor.bufnr, self.ns,
    0, { cursor.row, cursor.col }, {})

  count = count or 1
  if count < 0 or count >= #prev then
    return nil
  end

  id = prev[#prev - count][1]
  return Cursor:get_by_id(id, bufnr)
end

function Cursor:get_by_id(id, bufnr)
  vim.validate {
    id    = { id, { "number" } },
    bufnr = { bufnr, { "nil", "number" } },
  }

  bufnr = bufnr or self.bufnr
  if not bufnr or bufnr == 0 then
    bufnr = fn.bufnr()
  end

  local pos = get_extmark_by_id(bufnr, self.ns, id, {})
  if not pos then return nil end

  local active
  if _stack[bufnr] and _stack[bufnr][id] then
    active = _stack[bufnr][id].active
  end

  return Cursor:new(pos[1], pos[2], id, bufnr, active)
end

function Cursor:get_by_pos(row, col, bufnr)
  vim.validate {
    row   = { row, { "nil", "number" } },
    col   = { col, { "nil", "number" } },
    bufnr = { bufnr, { "nil", "number" } },
  }

  bufnr = bufnr or self.bufnr
  if not bufnr or bufnr == 0 then
    bufnr = fn.bufnr()
  end

  local row_len = buf_call(bufnr, utils.get_row_len)
  if row < 0 or row > row_len then return nil end

  local col_len = buf_call(bufnr, function()
    return utils.get_col_len(row)
  end)
  if col < 0 or col > col_len then return nil end

  return get_extmarks(bufnr, self.ns, { row, col }, { row, col }, {})
end

function Cursor:update(row, col, id, bufnr)
  vim.validate {
    row   = { row, { "nil", "number" } },
    col   = { col, { "nil", "number" } },
    id    = { id, { "nil", "number" } },
    bufnr = { bufnr, { "nil", "number" } },
  }

  if id then
    self = Cursor:get_by_id(id, bufnr)
    if not self then return nil end
  end

  del_extmark(self.bufnr, self.ns, self.id)

  self.row = row or self.row
  self.col = col or self.col

  local row_len = buf_call(self.bufnr, utils.get_row_len)
  if self.row < 0 then self.row = 0 end
  if self.row > row_len then self.row = row_len end

  local col_len = buf_call(self.bufnr, function()
    return utils.get_col_len(self.row)
  end)
  if self.col < 0 then self.col = 0 end
  if self.col > col_len then self.col = col_len end

  return self:show()
end

function Cursor:move(dir, count, id, bufnr)
  if id then
    self = Cursor:get_by_id(id, bufnr)
    if not self then return end
  end

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
  vim.validate {
    bufnr = { bufnr, { "nil", "number" } },
  }

  bufnr = bufnr or self.bufnr
  if not bufnr or bufnr == 0 then
    bufnr = fn.bufnr()
  end
  return get_extmarks(bufnr, self.ns, 0, -1, {})
end

function Cursor:each(bufnr, cb)
  vim.validate {
    bufnr = { bufnr, { "nil", "number" } },
    cb    = { cb, { "function" } },
  }

  local cursors = Cursor:all(bufnr)
  for index, cursor in pairs(cursors) do
    cb(Cursor:get_by_id(cursor[1], bufnr), index)
  end

  return self
end

function Cursor:del(id, bufnr)
  vim.validate {
    id    = { id, { "nil", "number" } },
    bufnr = { bufnr, { "nil", "number" } },
  }

  if id then
    self = Cursor:get_by_id(id, bufnr)
    if not self then return end
  end

  if not self.id then return nil end
  _stack[bufnr][self.id] = nil
  del_extmark(self.bufnr, self.ns, self.id)
end

function Cursor:clear(bufnr)
  self:each(bufnr, function(cursor)
    cursor:del()
  end)
end

return Cursor
