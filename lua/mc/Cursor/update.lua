local Cursor = require "mc.Cursor.Cursor"
local utils = require "mc.Utils"

function Cursor:update(row, col, opts)
  local mode   = opts.mode
  local active = opts.active

  vim.validate {
    row    = { row, { "nil", "number" } },
    col    = { col, { "nil", "number" } },
    mode   = { mode, { "nil", "string" } },
    active = { active, { "nil", "number" } },
  }

  if not self.id then
    return nil
  end

  self.row    = row or self.row
  self.col    = col or self.col
  self.active = active or self.active

  vim.api.nvim_buf_call(self.bufnr, function()
    if self.row < 0 then
      self.row = 0
    end

    local row_len = utils.get_row_len()
    if self.row > row_len then
      self.row = row_len
    end

    if self.col < 0 then
      self.col = 0
    end

    local col_len = utils.get_col_len(self.row)
    if mode == "n" then
      col_len = col_len - 1
    end

    if self.col > col_len then
      self.col = col_len
    end
  end)

  Cursor.stack[self.bufnr][self.id] = {
    curswant = self.curswant,
    active   = self.active
  }

  vim.api.nvim_buf_del_extmark(self.bufnr, self.ns, self.id)
  return self:show()
end
