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
Cursor.stack = {}
Cursor.__index = Cursor

local _stack = {}

function Cursor:new(row, col, opt)
  opt = opt or {}

  local id       = opt.id
  local bufnr    = opt.bufnr
  local curswant = opt.curswant
  local active   = opt.active

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
    id       = id,
    bufnr    = bufnr,
    row      = row,
    col      = col,
    curswant = curswant or col,
    active   = active,
  }

  setmetatable(cursor, self)

  cursor:show()

  _stack[bufnr] = _stack[bufnr] or {}
  _stack[bufnr][cursor.id] = {
    curswant = col,
    active = active
  }

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

  local row      = pos[1]
  local col      = pos[2]
  local curswant = _stack[bufnr][id].curswant
  local active   = _stack[bufnr][id].active

  return Cursor:new(row, col, {
    id       = id,
    bufnr    = bufnr,
    curswant = curswant,
    active   = active,
  })
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

function Cursor:update(row, col, id, bufnr, active)
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

  self.row    = row or self.row
  self.col    = col or self.col
  self.active = active or self.active

  -- P(":update()", self.col, _stack[self.bufnr])

  local row_len = buf_call(self.bufnr, utils.get_row_len)
  if self.row < 0 then self.row = 0 end
  if self.row > row_len then self.row = row_len end

  local col_len = buf_call(self.bufnr, function()
    return utils.get_col_len(self.row)
  end)
  if self.col < 0 then self.col = 0 end
  if self.col > col_len then self.col = col_len end

  -- _stack[self.bufnr] = _stack[self.bufnr] or {}
  _stack[self.bufnr][self.id] = {
    curswant = self.curswant,
    active   = self.active
  }

  return self:show()
end

function Cursor:move(dir, count, id, bufnr)
  if id then
    self = Cursor:get_by_id(id, bufnr)
    if not self then return end
  end

  self.col = utils.copy(self.curswant)

  if dir == "k" or dir == "up" then
    self.row = self.row - count
    self.col = self.curswant
  end

  if dir == "j" or dir == "down" then
    self.row = self.row + count
    self.col = self.curswant
  end

  if dir == "l" or dir == "right" then
    self.col = self.col + count
  end

  if dir == "h" or dir == "left" then
    self.col = self.col - count
  end

  if dir == "h" or dir == "l" or dir == "right" or dir == "left" then

    local col_len = buf_call(self.bufnr, function()
      return utils.get_col_len(self.row)
    end)

    if self.col < 0 then
      self.col = 0
    end

    if self.col > col_len then
      self.col = col_len
    end

    self.curswant = self.col
  end

  P(":move()", self.row, self.col, self.curswant)

  return self:update()
end

function Cursor:all(bufnr)
  vim.validate {
    bufnr = { bufnr, { "nil", "number" } },
  }

  bufnr = bufnr or self.bufnr
  if not bufnr or bufnr == 0 then
    bufnr = fn.bufnr()
  end

  local extmarks = get_extmarks(bufnr, self.ns, 0, -1, {})

  return extmarks
end

function Cursor:each(bufnr, cb)
  vim.validate {
    bufnr = { bufnr, { "nil", "number" } },
    cb    = { cb, "function" },
  }

  local cs = Cursor:all(bufnr)
  for index, c in pairs(cs) do
    local id = c[1]
    local cursor = Cursor:get_by_id(id, bufnr)
    if cursor then
      cb(cursor, index)
    end
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
