-- local P = require "yacine.utils.P".P
--local highlight = require "mc.highlight"

local api = vim.api
local cns = api.nvim_create_namespace
local ucmd = api.nvim_create_user_command
local del_ucmd = api.nvim_del_user_command
local extmark = api.nvim_buf_set_extmark
local del_extmark = api.nvim_buf_del_extmark
local get_text = api.nvim_buf_get_text
local hl = api.nvim_set_hl

local fn = vim.fn
local bufnr = fn.bufnr
local sc = fn.cursor

local map = vim.keymap


-- =====================
-- === Multi Cursor  ===
-- =====================
local MC = {}
MC.ns = cns('MC-Mode')
MC.stack = {}

-- hl(0, "MCCursor", { fg = "#242b38", bg = "#ef5f6b", bold = true })

MC.cursor = {}

MC.cursor.set = function(buf, id, row, col)
  if not buf or buf == 0 then
    buf = bufnr()
  end

  if not MC.stack[buf] then
    MC.stack[buf] = {}
  end

  if MC.cursor.id(buf, row, col) then return end

  local chr = get_text(buf, row, col, row, col + 1, {})[1]
  if chr == "" then chr = " " end

  id = extmark(buf, MC.ns, row, col, {
    id = id,
    virt_text = { { chr, "MCCursor" } },
    virt_text_pos = "overlay",
  })

  MC.stack[buf][id] = { row = row, col = col }
end

MC.cursor.del = function(buf, id, row, col)
  if not MC.stack[buf] then return end

  id = id or MC.cursor.id(buf, row, col)
  if not id then return end

  del_extmark(buf, MC.ns, id)
  MC.stack[buf][id] = nil
end

MC.cursor.del_all = function(buf)
  if not buf or buf == 0 then
    buf = bufnr()
  end

  api.nvim_buf_clear_namespace(buf, MC.ns, 0, -1)
  MC.stack[buf] = nil
end

MC.cursor.id = function(buf, row, col)
  if not MC.stack[buf] then return end

  for id, pos in pairs(MC.stack[buf]) do
    if row == pos.row and col == pos.col then
      return id
    end
  end
end

MC.ref = function(buf)
  if not buf or buf == 0 then
    buf = bufnr()
  end

  local stack = api.nvim_buf_get_extmarks(buf, MC.ns, 0, -1, {})
  MC.cursor.del_all(buf)

  for _, m in pairs(stack) do
    local id = m[1]
    local row = m[2]
    local col = m[3]
    MC.cursor.set(buf, id, row, col)
  end
end


-- =====================
-- ===  Move Cursor  ===
-- =====================

MC.__DIR__ = {
  UP = 1,
  Down = 2,
  Right = 3,
  Left = 4
}

MC.cursor.move = function(buf, id, dir)
  if not MC.stack[buf] then return end
  if not MC.stack[buf][id] then return end

  local pos = MC.stack[buf][id]
  local row = pos.row
  local col = pos.col

  if dir == MC.__DIR__.UP then row = row - 1 end
  if dir == MC.__DIR__.Down then row = row + 1 end
  if dir == MC.__DIR__.Right then col = col + 1 end
  if dir == MC.__DIR__.Left then col = col - 1 end

  if row < 0 then row = 0 end
  local lastrow = vim.fn.line("$") - 1
  if row > lastrow then row = lastrow end

  local tmp_col = col
  if col < 0 then col = 0 end
  local lastcol = #vim.fn.getline(row + 1) - 1
  if col > lastcol then col = lastcol end

  MC.cursor.del(buf, id)
  MC.cursor.set(buf, id, row, col)

  if dir == MC.__DIR__.UP or
      dir == MC.__DIR__.Down then
    MC.stack[buf][id].col = tmp_col
  end

end

MC.cursor.move_all = function(buf, dir)
  if not MC.stack[buf] then return end

  for id, _ in pairs(MC.stack[buf]) do
    MC.cursor.move(buf, id, dir)
  end
end


-- =====================
-- === USER COMMANDS ===
-- =====================

MC.setup = function()
  ucmd("MCEnter", function()
    P "Enter MC"
  end, {})

  ucmd("MCLeave", function()
    P "Leave MC"
  end, {})

  ucmd("MCAddCursor", function()
    local buf = bufnr()
    local row = fn.line('.') - 1
    local col = fn.col('.') - 1
    P("Add: ", { buf, row, col })
    MC.cursor.set(buf, nil, row, col)
  end, {})

  ucmd("MCRemoveCursor", function()
    local buf = bufnr()
    local row = fn.line('.') - 1
    local col = fn.col('.') - 1
    P("Delete: ", { buf, row, col })
    MC.cursor.del(buf, MC.cursor.id(buf, row, col))
  end, {})

  ucmd("MCLockCursors", function()
    P("Lock Cursors")

    local buf = bufnr()

    map.set("n", "k", function()
      sc(fn.line(".") - 1, fn.col("."))
      MC.cursor.move_all(buf, MC.__DIR__.UP)
    end, { buffer = buf })

    map.set("n", "j", function()
      sc(fn.line(".") + 1, fn.col("."))
      MC.cursor.move_all(buf, MC.__DIR__.Down)
    end, { buffer = buf })

    map.set("n", "l", function()
      sc(fn.line("."), fn.col(".") + 1)
      MC.cursor.move_all(buf, MC.__DIR__.Right)
    end, { buffer = buf })

    map.set("n", "h", function()
      sc(fn.line("."), fn.col(".") - 1)
      MC.cursor.move_all(buf, MC.__DIR__.Left)
    end, { buffer = buf })
  end, {})

  ucmd("MCUnlockCursors", function()
    P "Unlock Cursors"

    local buf = bufnr()

    map.del("n", "k", { buffer = buf })
    map.del("n", "j", { buffer = buf })
    map.del("n", "h", { buffer = buf })
    map.del("n", "l", { buffer = buf })
  end, {})

  --highlight.create_highlight_groups()
end

return MC

-- End
