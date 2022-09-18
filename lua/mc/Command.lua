local utils = require "mc.Utils"

local Command = {}
Command.__index = Command

function Command:new(mode, key, bufnr)
  vim.validate {
    mode  = { mode, "string" },
    key   = { key, "string" },
    bufnr = { bufnr, { "nil", "number" } },
  }

  if not bufnr or bufnr == 0 then
    bufnr = vim.fn.bufnr()
  end

  local command = {
    mode  = mode,
    key   = key,
    bufnr = bufnr,
  }

  setmetatable(command, self)

  return command
end

function Command:active(cb)
  vim.keymap.set(self.mode, self.key, function()
    local count = vim.b.count
    self.clean = cb(self, count, self.mode, self.key)
  end, { buffer = self.bufnr })
end

function Command:inactive()
  pcall(self.clean)
  pcall(vim.keymap.del, self.mode, self.key, { buffer = self.bufnr })
end

return Command
