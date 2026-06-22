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

-- Autosave, like VSCode "files.autoSave": "afterDelay" with a 1000ms delay:
-- write the file ~1s after you stop changing it (debounced; insert mode too).
do
  local delay = 1000
  local timer = (vim.uv or vim.loop).new_timer()
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "InsertLeave" }, {
    desc = "Autosave after delay",
    callback = function(ev)
      local buf = ev.buf
      timer:stop()
      timer:start(
        delay,
        0,
        vim.schedule_wrap(function()
          if not vim.api.nvim_buf_is_valid(buf) then
            return
          end
          local bo = vim.bo[buf]
          -- only real, writable, on-disk files (skip terminals/trees/unnamed)
          if
            bo.modified
            and bo.modifiable
            and not bo.readonly
            and bo.buftype == ""
            and vim.api.nvim_buf_get_name(buf) ~= ""
          then
            vim.api.nvim_buf_call(buf, function()
              vim.cmd("silent! write")
            end)
          end
        end)
      )
    end,
  })
end

-- ── files / search / buffers ──────────────────────────────────────────────
map("n", "<leader>q", "<cmd>bdelete<cr>", { desc = "Close editor" })
-- Smart close: a floating panel (lazygit/lazydocker/…), the tree, a split, or
-- finally the buffer — whichever you're focused on.
map("n", "<leader>x", function()
  local win = vim.api.nvim_get_current_win()
  if vim.api.nvim_win_get_config(win).relative ~= "" then
    vim.api.nvim_win_close(win, true) -- floating TUI panel
  elseif vim.bo.filetype == "neo-tree" then
    vim.cmd("Neotree close")
  elseif #vim.api.nvim_tabpage_list_wins(0) > 1 then
    vim.cmd("close") -- a split
  else
    vim.cmd("bdelete") -- last window: drop the buffer
  end
end, { desc = "Close panel / split / buffer" })
-- Quit the whole IDE (warns if anything is unsaved; use :qa! to force).
map("n", "<leader>Q", "<cmd>qa<cr>", { desc = "Quit CJ-IDE" })
map("n", "<leader>b", "<cmd>FzfLua buffers<cr>", { desc = "Switch buffer" })
map("n", "<leader>f", "<cmd>FzfLua lgrep_curbuf<cr>", { desc = "Search in current file" })
map("n", "<leader>F", "<cmd>FzfLua live_grep<cr>", { desc = "Search in project" })
map("n", "<leader>p", "<cmd>FzfLua files<cr>", { desc = "Quick open file" })
map("n", "<C-n>", function()
  -- Prompt for a name (prefilled with the current file's folder), then open it.
  -- The file is written to disk on the first :w.
  local dir = vim.fn.expand("%:p:h")
  vim.ui.input({ prompt = "New file: ", default = dir .. "/", completion = "file" }, function(name)
    if name and name ~= "" then
      vim.cmd.edit(vim.fn.fnameescape(name))
    end
  end)
end, { desc = "New file (named)" })
map("n", "<C-s>", "<cmd>vsplit<cr>", { desc = "Split editor (vertical)" })
map("n", "<C-h>", "<C-w>h", { desc = "Focus split on the left" })
map("n", "<C-l>", "<C-w>l", { desc = "Focus split on the right" })

-- comments (built-in gc; remap=true so the gcc/gc operator runs)
map("n", "<leader>m", "gcc", { remap = true, desc = "Comment line" })
map("x", "<leader>m", "gc", { remap = true, desc = "Comment" })

-- move lines up / down
map("n", "<leader>j", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("n", "<leader>k", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("x", "<leader>j", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("x", "<leader>k", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- jump back to where you came from, e.g. after gd (forward is still <C-i>/Tab)
map("n", "gb", "<C-o>", { desc = "Jump back" })

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
