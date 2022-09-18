local utils = require "mc.Utils"

local Cursor = {}
Cursor.ns = vim.api.nvim_create_namespace('Cursor')
Cursor.stack = {}
Cursor.__index = Cursor

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
    bufnr = vim.fn.bufnr()
  end

  if not active then
    active = true
  end

  local row_len = vim.api.nvim_buf_call(bufnr, utils.get_row_len)
  if row < 0 or row > row_len then
    error("Row Out of Range")
  end

  local col_len = vim.api.nvim_buf_call(bufnr, function()
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

  Cursor.stack[bufnr] = Cursor.stack[bufnr] or {}
  Cursor.stack[bufnr][cursor.id] = {
    curswant = curswant or col,
    active = active
  }

  return cursor
end

return Cursor
