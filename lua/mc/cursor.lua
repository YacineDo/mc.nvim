local mc = require "mc"
local stack = mc.stack

local fn = vim.fn
local cmd = vim.cmd
local api = vim.api

local M = {}

M.set = function(bufnr, id, row, col)
  if not bufnr or bufnr == 0 then
    bufnr = fn.bufnr()
  end

  if M.getid(row, col, bufnr) then return end

  if not stack[bufnr] then
    stack[bufnr] = {}
  end

  local char = api.nvim_buf_get_text(bufnr, row, col, row, col + 1, {})[1]
  if char == "" then char = " " end

  id = api.nvim_buf_set_extmark(bufnr, mc.ns, row, col, {
    id = id,
    virt_text = { { char, "MCCursor" } },
    virt_text_pos = "overlay",
  })

  stack[bufnr][id] = { row = row, col = col }
end

local del_cursor = function(id, bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = fn.bufnr()
  end

  if not stack[bufnr] then return end

  api.nvim_buf_del_extmark(bufnr, mc.ns, id)
  stack[bufnr][id] = nil
end

M.del_by_id = function(id, bufnr)
  if not id then return end
  del_cursor(id, bufnr)
end

M.del_by_pos = function(row, col, bufnr)
  local id = M.getid(row, col)
  if not id then return end
  id = id[1]
  del_cursor(id, bufnr)
end

M.del_all = function(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = fn.bufnr()
  end
  api.nvim_buf_clear_namespace(bufnr, mc.ns, 0, -1)
  stack[bufnr] = nil
end

M.getid = function(row, col, bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = fn.bufnr()
  end

  if type(row) ~= "number" or type(col) ~= "number" then
    return
  end

  local pos = { row, col }
  return api.nvim_buf_get_extmarks(bufnr, mc.ns, pos, pos, {})[1]
end

M.getpos = function(id, bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = fn.bufnr()
  end

  if not stack[bufnr] then return end

  if type(id) ~= "number" then
    return
  end

  return stack[bufnr][id]
end

return M
