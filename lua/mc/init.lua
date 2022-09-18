local fn = vim.fn
local cmd = vim.cmd
local map = vim.keymap
local api = vim.api

local M = {}

M.ns = api.nvim_create_namespace('MC-Mode')
M.stack = {}

M.setup = function()
  -- require "mc.ucmd".init()
  require "mc.user_command".init()
  require "mc.highlight".create_highlight_groups()
end

return M
