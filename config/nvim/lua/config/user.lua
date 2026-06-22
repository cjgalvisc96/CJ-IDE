-- Keybindings ported to match cjgalvisc's previous VSCode (VSCodeVim) setup as
-- closely as possible. Loaded last by init.lua so it wins over the defaults.
--
-- HEADS UP: some of these intentionally shadow core Vim keys to preserve the
-- VSCode muscle memory:
--   f / F  -> fold / unfold (instead of find-char)
--   J / K  -> next / prev paragraph (instead of join-lines / LSP hover)
--   dw df … / yf yu … -> "change/yank word/line/block" style operators
-- Forking CJ-IDE and want stock Vim motions back? Delete the marked sections.

local map = vim.keymap.set

vim.o.timeoutlen = 1000 -- vim.timeout: 1000 (waits this long on multi-key seqs)

-- Treesitter-based folding so the f/F fold maps below actually have folds.
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = ""
vim.opt.foldlevel = 99 -- open everything by default

-- ── files / search / buffers ──────────────────────────────────────────────
map("n", "<leader>q", "<cmd>bdelete<cr>", { desc = "Close editor" })
map("n", "<leader>b", "<cmd>FzfLua buffers<cr>", { desc = "Switch buffer" })
map("n", "<leader>a", "<cmd>FzfLua live_grep<cr>", { desc = "Find in files" })
map("n", "<leader>p", "<cmd>FzfLua files<cr>", { desc = "Quick open file" })
map("n", "<leader>n", "<cmd>enew<cr>", { desc = "New file" })
map("n", "<leader>l", "<C-w>l", { desc = "Focus split on the right" })
map("n", "<leader>h", "<C-w>h", { desc = "Focus split on the left" })
map("n", "<leader>s", "<cmd>vsplit<cr>", { desc = "Split editor (vertical)" })

-- comments (built-in gc; remap=true so the gcc/gc operator runs)
map("n", "<leader>m", "gcc", { remap = true, desc = "Comment line" })
map("x", "<leader>m", "gc", { remap = true, desc = "Comment" })

-- move lines up / down
map("n", "<leader>j", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("n", "<leader>k", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("x", "<leader>j", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("x", "<leader>k", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- ── terminal ──────────────────────────────────────────────────────────────
map("n", "<leader>t", "<cmd>ToggleTerm<cr>", { desc = "New terminal" })

-- ── core-motion overrides (match VSCode; remove to restore stock Vim) ──────

-- paragraph jumps on J / K
map("n", "J", "}", { desc = "Next paragraph" })
map("n", "K", "{", { desc = "Previous paragraph" })

-- folding on f / F (f, fa, fu coexist via timeoutlen). pcall hides "no fold".
local function fold(keys)
  return function()
    pcall(function()
      vim.cmd("normal! " .. keys)
    end)
  end
end
map("n", "f", fold("zC"), { desc = "Fold recursively" })
map("n", "F", fold("zO"), { desc = "Unfold recursively" })
map("n", "fa", fold("zM"), { desc = "Fold all" })
map("n", "fu", fold("zR"), { desc = "Unfold all" })

-- select to end of line
map("n", "vf", "v$", { desc = "Select to line end" })

-- copy the whole file to the system clipboard
map("n", "vv", "<cmd>%yank +<cr>", { desc = "Copy whole file" })

-- operator shortcuts: change/yank word/line/block in one step
map("n", "dw", "dwi", { desc = "Delete word -> insert" })
map("n", "du", "bdwa", { desc = "Delete word under cursor -> append" })
map("n", "db", "d0i", { desc = "Delete to line start -> insert" })
map("n", "df", "d$a", { desc = "Delete to line end -> append" })
map("n", "dp", "vibdi", { desc = "Delete inside () -> insert" })
map("n", "dq", "vi'di", { desc = "Delete inside '' -> insert" })
map("n", "dk", "vi{di", { desc = "Delete inside {} -> insert" })
map("n", "dc", "vi[di", { desc = "Delete inside [] -> insert" })
map("n", "yf", "y$", { desc = "Yank to line end" })
map("n", "yu", "byw", { desc = "Yank word under cursor" })
map("n", "yb", "y0", { desc = "Yank to line start" })
map("n", "yp", "viby", { desc = "Yank inside ()" })
map("n", "yq", "vi'y", { desc = "Yank inside ''" })
map("n", "yk", "vi{y", { desc = "Yank inside {}" })
map("n", "yc", "vi[y", { desc = "Yank inside []" })
