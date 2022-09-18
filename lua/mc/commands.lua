local Command = require "mc.Command"

local M = {}

M.h = Command:new("n", "h")
M.j = Command:new("n", "j")
M.k = Command:new("n", "k")
M.l = Command:new("n", "l")

M.i = Command:new("n", "i")
M.a = Command:new("n", "a")
M.I = Command:new("n", "I")
M.A = Command:new("n", "A")

M.w = Command:new("n", "w")
M.e = Command:new("n", "e")
M.b = Command:new("n", "b")







-- M.i:set(function(self, count)
--   local changes = {}
--   local detach, ignore = false, false
--
--   utils.feedkey(self.mode, self.key)
--
--   vim.api.nvim_buf_attach(0, false, {
--     on_bytes = function(...)
--       if detach then return true end
--       if ignore then return nil end
--
--       local _, _, _,
--       start_row, start_col, _,
--       old_end_row, old_end_col, _,
--       new_end_row, new_end_col, _ = ...
--
--       local end_row = start_row + new_end_row
--       local end_col = new_end_col
--       if start_row == end_row then
--         end_col = start_col + new_end_col
--       end
--
--       local text = vim.api.nvim_buf_get_text(
--         bufnr,
--         start_row, start_col,
--         end_row, end_col, {})
--
--       table.insert(changes, {
--         start_row = start_row,
--         start_col = start_col,
--         end_row   = old_end_row,
--         end_col   = old_end_col,
--         text      = text,
--       })
--
--     end,
--   })
--
--   vim.api.nvim_create_autocmd("InsertLeave", {
--     once     = true,
--     buffer   = self.bufnr,
--     callback = function()
--       detach = true
--       -- P "Detach..."
--       P(changes)
--     end,
--   })
--
-- end)




return M
