-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("i", "kj", "<Esc>", { desc = "Exit insert mode" })

vim.keymap.set("n", "<CR>", function()
  vim.cmd("normal! o")
  -- Clear the line (in case autoindent or comment continuation added anything)
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, row - 1, row, false, { "" })
  -- Go back to normal mode and move cursor to column 0
  vim.api.nvim_win_set_cursor(0, { row, 0 })
  vim.cmd("stopinsert")
end, { desc = "Insert blank line below" })

vim.keymap.set("n", "<leader>pwd", ':let @+ = expand("%:p")<CR>', { desc = "Copy file path" })
