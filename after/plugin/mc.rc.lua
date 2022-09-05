-- =====================
-- ===  MC KEYMAPS   ===
-- =====================

local map = vim.keymap

vim.schedule(function()
  -- MC.cursor.set(nil, nil, 1 - 1, 0)
  -- vim.cmd [[MCLockCursors]]
  map.set("n", ";", "<cmd>MCAddCursor<cr>", {})
  map.set("n", "<A-;>", "<cmd>MCRemoveCursor<cr>", {})
  map.set("n", "<Leader>ml", "<cmd>MCLockCursors<cr>", {})
end)
