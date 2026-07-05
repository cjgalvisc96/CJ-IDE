-- Global keymaps on top of LazyVim's (this file loads AFTER LazyVim's own
-- keymaps, so everything set here wins).
--
-- Order matters:
--   1. a few global maps
--   2. config.user — the VSCode-style scheme (single-key <leader> maps)
--   3. config.help — the `?` cheatsheet (last so nothing clobbers it)
--   4. prune every map that EXTENDS one of the single keys (<leader>ff,
--      <leader>qq, …): a longer mapping on the same prefix makes the single
--      key wait `timeoutlen` before firing, which kills the VSCode-style
--      snappiness. Pruning by prefix instead of by name keeps this robust
--      across LazyVim updates.

local map = vim.keymap.set

map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
map("n", "<leader>u", "<cmd>Lazy update<cr>", { desc = "Update plugins" })
map("t", "<C-x>", [[<C-\><C-n>]], { desc = "Terminal: normal mode" })

-- Free the `gr` prefix: Neovim ships global defaults on grn/gra/grr/gri/grt,
-- which would make the bare-`gr` references map wait (and shadow it). Rename /
-- code-action live on <leader>cr / <leader>ca instead.
for _, key in ipairs({ "grn", "gra", "grr", "gri", "grt" }) do
  pcall(vim.keymap.del, "n", key)
end

require("config.user")
require("config.help")

-- 4. prune prefix-clashing maps (see header). Every CJ-IDE single-key
-- <leader> binding is listed; any GLOBAL map that strictly extends one of
-- them (e.g. LazyVim's <leader>ff / <leader>qq / <leader>gg) is deleted.
local singles = {
  "q",
  "Q",
  "b",
  "f",
  "F",
  "g",
  "G",
  "p",
  "n",
  "s",
  "j",
  "k",
  "m",
  "t",
  "a",
  "x",
  "u",
  "w",
  "e",
  "r",
  "R",
}
local leader = vim.keycode("<leader>")
for _, mode in ipairs({ "n", "x", "v" }) do
  for _, m in ipairs(vim.api.nvim_get_keymap(mode)) do
    local raw = m.lhsraw or vim.keycode(m.lhs)
    for _, s in ipairs(singles) do
      local prefix = leader .. s
      if raw ~= prefix and raw:sub(1, #prefix) == prefix then
        pcall(vim.keymap.del, mode, m.lhs)
        break
      end
    end
  end
end
