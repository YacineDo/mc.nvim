local mc       = require "mc"
local Cursor   = require "mc.Cursor"
local commands = require "mc.commands"
local Command  = require "mc.Command"

local api = vim.api

local ucmd = api.nvim_create_user_command
local del_ucmd = api.nvim_del_user_command

local M = {}

local DIR = { "left", "down", "up", "right" }

local getpos = function()
  local row = vim.fn.line "." - 1
  local col = vim.fn.col "." - 1
  return row, col
end

M._lock = function(bufnr)
  bufnr = bufnr or vim.fn.bufnr()

  for i, key in pairs({ "h", "j", "k", "l" }) do
    commands[key]:active(function()
      Cursor:each(bufnr, function(cursor)
        cursor:move(DIR[i], 1, "n")
      end)
    end)
  end

  pcall(del_ucmd, "MCLockCursors")
  ucmd("MCUnlockCursors", M._lock, {})
end

M._unlock = function(bufnr)
  bufnr = bufnr or vim.fn.bufnr()

  for _, key in pairs({ "h", "j", "k", "l" }) do
    pcall(vim.keymap.del, "n", key, { buffer = bufnr })
  end

  pcall(del_ucmd, "MCUnlockCursors")
  ucmd("MCLockCursors", M._unlock, {})
end

M.MCEnter = function()
  local bufnr = vim.fn.bufnr()

  ucmd("MCAddCursor", function()
    local row, col = getpos()
    Cursor:new(row, col, { bufnr = bufnr })
  end, {})

  ucmd("MCRemoveCursor", function()
    local row, col = getpos()
    local cursors = Cursor:get_by_pos(row, col, bufnr)
    for _, cursor in pairs(cursors) do
      Cursor:del(cursor[1], bufnr)
    end
  end, {})

  ucmd("MCLockCursors", M._lock, {})
  ucmd("MCLeave", M.MCLeave, {})

  pcall(del_ucmd, "MCEnter")
end

M.MCLeave = function()
  pcall(del_ucmd, "MCLeave")
  pcall(del_ucmd, "MCAddCursor")
  pcall(del_ucmd, "MCRemoveCursor")
  pcall(del_ucmd, "MCLockCursors")
  pcall(del_ucmd, "MCUnlockCursors")

  ucmd("MCEnter", M.MCEnter, {})
end


M.init = function()
  ucmd("MCEnter", M.MCEnter, {})
end

return M
