local mc = require "mc"
local cursor = require "mc.cursor"
local move = require "mc.move"

-- local stack = mc.stack

local fn = vim.fn
local cmd = vim.cmd
local api = vim.api
local map = vim.keymap

local augroup = api.nvim_create_augroup
local autocmd = api.nvim_create_autocmd
local del_autocmd = api.nvim_del_autocmd

local set_text = api.nvim_buf_set_text

local M = {}

M.actoins = {}

local feedkey = function(key, mode)
  key = api.nvim_replace_termcodes(key, true, false, true)
  api.nvim_feedkeys(key, mode, false)
end

M.set = function(bufnr, mode, key, actoin)
  local _actoin = function()
    actoin(key, mode)
  end

  M.actoins[mode] = M.actoins[mode] or {}
  M.actoins[mode][key] = _actoin

  map.set(mode, key, _actoin, { buffer = bufnr })
end

-- M.del = function(bufnr, mode)
--   if not bufnr or bufnr == 0 then
--     bufnr = fn.bufnr()
--   end
--
--   local actoins = M.actoins[mode]
--   if not actoins then return end
--
--   for lhs, rhs in pairs(actoins) do
--     map.del(mode, lhs, rhs, { buffer = bufnr })
--   end
-- end


local i, a, im = {}, {}, {}

local set_char = function(char, bufnr)
  local stack = mc.stack[bufnr]
  if not stack then return end

  for id, pos in pairs(stack) do
    local row = pos.row
    local col = pos.col
    api.nvim_buf_set_text(bufnr, row, col, row, col, { char })
    stack[id].col = col + 1
  end
end

local del_char = function(bufnr, row, col)
  local start_row = row
  local start_col = col
  local end_row = row
  local end_col = col

  if start_row == 0 and start_col ~= 0 then
    start_col = start_col - 1
  end

  if start_row ~= 0 then
    if start_col == 0 then
      start_row = start_row - 1
      start_col = fn.col({ start_row + 1, "$" }) - 1
    else
      start_col = start_col - 1
    end
  end

  if cursor.getid(start_row, start_col, bufnr) then return end

  api.nvim_buf_set_text(bufnr, start_row, start_col, end_row, end_col, { "" })
  return start_row, start_col, end_row, end_col
end

-- augroup("MCEnter", { clear = true })
-- augroup("MCLeave", { clear = true })
augroup("MCInsertMode", { clear = true })

M.enter = function(bufnr)
  map.set("n", "i", function()
    feedkey("i", "n")

    i[bufnr] = autocmd("InsertLeave", {
      once = true,
      buffer = bufnr,
      callback = function()
        move(4, bufnr)
      end,
    })
  end, { buffer = bufnr })

  map.set("n", "a", function()
    feedkey("a", "n")
    move(3, bufnr)

    a[bufnr] = autocmd("InsertLeave", {
      once = true,
      buffer = bufnr,
      callback = function()
        move(4, bufnr)
      end,
    })
  end, { buffer = bufnr })

  im[bufnr] = autocmd({ "InsertCharPre" }, {
    group = "MCInsertMode",
    buffer = bufnr,
    callback = function()
      local char = vim.v.char
      vim.schedule(function()
        set_char(char, bufnr)
      end)
    end,
  })

  map.set("i", "<BS>", function()
    local start_row, start_col = del_char(bufnr, fn.line(".") - 1, fn.col(".") - 1)
    if start_row and start_col then
      fn.cursor(start_row + 1, start_col + 1)
    end

    local stack = mc.stack[bufnr]
    if not stack then return end

    for id, pos in pairs(stack) do
      start_row, start_col = del_char(bufnr, pos.row, pos.col)
      if start_row and start_col then
        stack[id] = { row = start_row, col = start_col }
      end
    end
  end, { buffer = bufnr })

  map.set("i", "<CR>", function()
    local row = fn.line(".") - 1
    local col = fn.col(".") - 1

    api.nvim_buf_set_text(bufnr, row, col, row, col, { "", "" })

    if not mc.stack[bufnr] then
      return
    end

    for _, pos in pairs(mc.stack[bufnr]) do
      row = pos.row
      col = pos.col
      api.nvim_buf_set_text(bufnr, row, col, row, col, { "", "" })
    end
  end, { buffer = bufnr })

end

M.leave = function(bufnr)
  pcall(del_autocmd, i[bufnr])
  pcall(del_autocmd, a[bufnr])
  pcall(del_autocmd, im[bufnr])

  pcall(map.del, "i", "<BS>", { buffer = bufnr })
  pcall(map.del, "i", "<CR>", { buffer = bufnr })

  cursor.del_all(bufnr)
end

local DIR = {
  UP = 1,
  Down = 2,
  Right = 3,
  Left = 4
}

M.lock = function(bufnr)

  local up = function()
    fn.cursor(fn.line(".") - 1, fn.col("."))
    move(DIR.UP, bufnr)
  end

  local down = function()
    fn.cursor(fn.line(".") + 1, fn.col("."))
    move(DIR.Down, bufnr)
  end

  local right = function()
    fn.cursor(fn.line("."), fn.col(".") + 1)
    move(DIR.Right, bufnr)
  end

  local left = function()
    fn.cursor(fn.line("."), fn.col(".") - 1)
    move(DIR.Left, bufnr)
  end

  map.set("n", "k", up, { buffer = bufnr })
  map.set("n", "<Up>", up, { buffer = bufnr })
  map.set("n", "<c-p>", up, { buffer = bufnr })

  map.set("n", "j", down, { buffer = bufnr })
  map.set("n", "<Down>", down, { buffer = bufnr })
  map.set("n", "<c-j>", down, { buffer = bufnr })
  map.set("n", "<NL>", down, { buffer = bufnr })
  map.set("n", "<c-n>", down, { buffer = bufnr })

  map.set("n", "l", right, { buffer = bufnr })
  map.set("n", "<Right>", right, { buffer = bufnr })
  map.set("n", "<Space>", right, { buffer = bufnr })

  map.set("n", "h", left, { buffer = bufnr })
  map.set("n", "<Left>", left, { buffer = bufnr })
  map.set("n", "<c-h>", left, { buffer = bufnr })
  map.set("n", "<BS>", left, { buffer = bufnr })
end

M.unlock = function(bufnr)
  pcall(map.del, "n", "k", { buffer = bufnr })
  pcall(map.del, "n", "<Up>", { buffer = bufnr })
  pcall(map.del, "n", "<c-p>", { buffer = bufnr })

  pcall(map.del, "n", "j", { buffer = bufnr })
  pcall(map.del, "n", "<Down>", { buffer = bufnr })
  pcall(map.del, "n", "<c-j>", { buffer = bufnr })
  pcall(map.del, "n", "<NL>", { buffer = bufnr })
  pcall(map.del, "n", "<c-n>", { buffer = bufnr })

  pcall(map.del, "n", "l", { buffer = bufnr })
  pcall(map.del, "n", "<Right>", { buffer = bufnr })
  pcall(map.del, "n", "<Space>", { buffer = bufnr })

  pcall(map.del, "n", "h", { buffer = bufnr })
  pcall(map.del, "n", "<Left>", { buffer = bufnr })
  pcall(map.del, "n", "<c-h>", { buffer = bufnr })
  pcall(map.del, "n", "<BS>", { buffer = bufnr })
end

return M
