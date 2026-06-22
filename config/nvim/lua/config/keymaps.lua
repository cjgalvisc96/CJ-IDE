-- Global keymaps (plugin-specific maps live next to their plugin spec).

local map = vim.keymap.set

map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search" })
map("t", "<C-x>", [[<C-\><C-n>]], { desc = "Terminal: normal mode" })
