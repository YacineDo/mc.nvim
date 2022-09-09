local mc = require "mc"
local cursor = require "mc.cursor"
local move = require "mc.move"
local actions = require "mc.actions"

local fn = vim.fn
local cmd = vim.cmd
local api = vim.api
local map = vim.keymap

local ucmd = api.nvim_create_user_command
local del_ucmd = api.nvim_del_user_command

local M = {}

M.init = function()

  local mc_mode = {}

  mc_mode.enter = function()
    local bufnr = fn.bufnr()

    actions.enter(bufnr)

    ucmd("MCAddCursor", function()
      local row = fn.line('.') - 1
      local col = fn.col('.') - 1

      cursor.set(bufnr, nil, row, col)
    end, {})

    ucmd("MCRemoveCursor", function()
      local row = fn.line('.') - 1
      local col = fn.col('.') - 1

      cursor.del_by_pos(row, col, bufnr)
    end, {})

    local lock_cursors = {}

    lock_cursors.enter = function()
      actions.lock(bufnr)

      pcall(del_ucmd, "MCLockCursors")
      ucmd("MCUnlockCursors", lock_cursors.leave, {})
    end

    lock_cursors.leave = function()
      actions.unlock(bufnr)

      pcall(del_ucmd, "MCUnlockCursors")
      ucmd("MCLockCursors", lock_cursors.enter, {})
    end

    ucmd("MCLockCursors", lock_cursors.enter, {})

    pcall(del_ucmd, "MCEnter")
    ucmd("MCLeave", mc_mode.leave, {})
  end

  mc_mode.leave = function()
    local bufnr = fn.bufnr()
    actions.leave(bufnr)

    pcall(del_ucmd, "MCAddCursor")
    pcall(del_ucmd, "MCRemoveCursor")

    pcall(del_ucmd, "MCLockCursors")
    pcall(del_ucmd, "MCUnlockCursors")
    actions.unlock(bufnr)

    pcall(del_ucmd, "MCLeave")
    ucmd("MCEnter", mc_mode.enter, {})
  end

  ucmd("MCEnter", mc_mode.enter, {})
end

return M
