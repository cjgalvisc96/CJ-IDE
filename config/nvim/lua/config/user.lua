-- Keybindings ported to match cjgalvisc's previous VSCode (VSCodeVim) setup as
-- closely as possible. Loaded by config/keymaps.lua AFTER LazyVim's own
-- keymaps, so everything here wins over the defaults.
--
-- HEADS UP: some of these intentionally shadow core Vim keys to preserve the
-- VSCode muscle memory:
--   f / fa -> toggle fold / toggle all folds (f is no longer find-char)
--   J / K  -> next / prev paragraph (instead of join-lines / LSP hover)
--   dw df … / yf yu … -> "change/yank word/line/block" style operators
-- Forking CJ-IDE and want stock Vim motions back? Delete the marked sections.

local map = vim.keymap.set

-- How long a multi-key sequence waits for the next key. Kept short so the
-- intentional prefix overlaps (f → fa/fu, gc → gcc) barely pause.
vim.o.timeoutlen = 400

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
-- Quit the whole IDE (warns if anything is unsaved; use :qa! to force).
map("n", "<leader>Q", "<cmd>qa<cr>", { desc = "Quit CJ-IDE" })
map("n", "<leader>b", "<cmd>FzfLua buffers<cr>", { desc = "Switch buffer" })
map("n", "<leader>f", "<cmd>FzfLua lgrep_curbuf<cr>", { desc = "Search in current file" })
map("n", "<leader>F", "<cmd>FzfLua live_grep<cr>", { desc = "Search in project" })
-- like <leader>f / <leader>F but seeded with the word under the cursor.
map("n", "<leader>g", function()
  require("fzf-lua").grep_curbuf({ search = vim.fn.expand("<cword>") })
end, { desc = "Search word under cursor (file)" })
map("n", "<leader>G", "<cmd>FzfLua grep_cword<cr>", { desc = "Search word under cursor (project)" })
-- visual mode: same two keys, but search the highlighted selection instead.
-- Yank the selection via the `v` register (restored after) to seed the curbuf grep.
local function visual_selection()
  local save, save_type = vim.fn.getreg("v"), vim.fn.getregtype("v")
  vim.cmd('noautocmd normal! "vy')
  local text = vim.fn.getreg("v")
  vim.fn.setreg("v", save, save_type)
  return (text:gsub("\n", " "))
end
map("x", "<leader>g", function()
  require("fzf-lua").grep_curbuf({ search = visual_selection() })
end, { desc = "Search selection (file)" })
map("x", "<leader>G", "<cmd>FzfLua grep_visual<cr>", { desc = "Search selection (project)" })

-- <leader>f / <leader>F in VISUAL mode search the highlighted characters — the
-- same file / project scope as their normal-mode search, seeded with the
-- selection instead of prompting. (Normal-mode f/F are unchanged.)
map("x", "<leader>f", function()
  require("fzf-lua").grep_curbuf({ search = visual_selection() })
end, { desc = "Search selection (file)" })
map("x", "<leader>F", "<cmd>FzfLua grep_visual<cr>", { desc = "Search selection (project)" })

-- ── JSON pretty / minify toggle on <C-j> (any buffer) ──────────────────────
-- First press pretty-prints; press again to minify. Uses python (always in the
-- toolset) so there's no extra dependency. The buffer content just has to be
-- valid JSON — the filetype/extension doesn't matter. Invalid JSON notifies and
-- the buffer is left untouched. Toggle state = whether the buffer is multi-line.
map("n", "<C-j>", function()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local input = table.concat(lines, "\n")
  local minify = #lines > 1 -- already pretty (multi-line) -> minify
  local cmd = minify
      and {
        "python",
        "-c",
        "import json,sys; json.dump(json.load(sys.stdin), sys.stdout, separators=(',',':'))",
      }
    or { "python", "-m", "json.tool", "--indent", "2" }
  local out = vim.fn.system(cmd, input)
  if vim.v.shell_error ~= 0 then
    vim.notify("Invalid JSON", vim.log.levels.ERROR)
    return
  end
  out = out:gsub("\n$", "")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(out, "\n"))
  vim.notify(minify and "JSON minified" or "JSON prettified")
end, { desc = "JSON pretty/minify toggle" })
-- Quick-open ANY file — including dotfiles and gitignored ones (matches the
-- tree, which shows them too), still skipping the .git/.jj folders themselves.
map("n", "<leader>p", function()
  require("fzf-lua").files({
    fd_opts = "--color=never --type f --type l --hidden --no-ignore --exclude .git --exclude .jj",
    rg_opts = '--color=never --files --hidden --no-ignore -g "!.git" -g "!.jj"',
  })
end, { desc = "Quick open file (incl. hidden & gitignored)" })
-- Explorer smart toggle (nvim-tree) — one key both leaves AND returns:
--   closed               -> open it and reveal the current file
--   open, cursor in file -> FOCUS the tree (jump to it)
--   open, cursor in tree -> close it
-- Lives HERE (not on the plugin spec) so it always wins <leader>e: LazyVim
-- force-enables a default explorer extra whose own <leader>e stub would
-- otherwise race with a spec-level one (see plugins/core.lua).
map("n", "<leader>e", function()
  local api = require("nvim-tree.api") -- lazy-loads nvim-tree on first use
  if not api.tree.is_visible() then
    api.tree.find_file({ open = true, focus = true })
  elseif vim.bo.filetype == "NvimTree" then
    api.tree.close()
  else
    api.tree.focus()
  end
end, { desc = "Explorer (toggle / focus)" })
map("n", "<leader>n", function()
  -- Prompt for a name (prefilled with the current file's folder), then open it.
  -- The file is written to disk on the first :w.
  local dir = vim.fn.expand("%:p:h")
  vim.ui.input({ prompt = "New file: ", default = dir .. "/", completion = "file" }, function(name)
    if name and name ~= "" then
      vim.cmd.edit(vim.fn.fnameescape(name))
    end
  end)
end, { desc = "New file (named)" })
-- VSCode-like tabs (one per open file; the bar comes from bufferline). Tab /
-- Shift-Tab cycle next / previous; close a tab with <leader>q (above). NOTE:
-- in a terminal Tab == <C-i>, so this overrides the jumplist-forward jump.
map("n", "<Tab>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next tab" })
map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous tab" })
-- Reorder tabs. bufferline has no click-and-drag, so shove the current tab
-- left / right with Alt-, / Alt-. instead (mouse still selects on left-click,
-- closes on right-click).
map("n", "<A-,>", "<cmd>BufferLineMovePrev<cr>", { desc = "Move tab left" })
map("n", "<A-.>", "<cmd>BufferLineMoveNext<cr>", { desc = "Move tab right" })
map("n", "<leader>s", "<cmd>vsplit<cr>", { desc = "Split editor (vertical)" })
-- Focus splits with the PLAIN arrow keys (normal mode only — in-file movement
-- is h/j/k/l, so the arrows are free). Left/Right walk the editor splits in
-- screen order and WRAP at the edges, so two keys always reach every split.
-- The nvim-tree panel and floating windows are skipped — the tree has its own
-- key (<leader>e). Up/Down focus the split above/below (horizontal splits).
-- Insert-mode arrows still move the cursor.
local function cycle_split(step)
  local wins = {}
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local is_float = vim.api.nvim_win_get_config(w).relative ~= ""
    if not is_float and vim.bo[vim.api.nvim_win_get_buf(w)].filetype ~= "NvimTree" then
      table.insert(wins, w)
    end
  end
  if #wins == 0 then
    return
  end
  -- left-to-right, then top-to-bottom (screen order)
  table.sort(wins, function(a, b)
    local pa, pb = vim.api.nvim_win_get_position(a), vim.api.nvim_win_get_position(b)
    if pa[2] ~= pb[2] then
      return pa[2] < pb[2]
    end
    return pa[1] < pb[1]
  end)
  local cur = vim.api.nvim_get_current_win()
  for i, w in ipairs(wins) do
    if w == cur then
      vim.api.nvim_set_current_win(wins[(i - 1 + step) % #wins + 1])
      return
    end
  end
  vim.api.nvim_set_current_win(wins[1]) -- cursor was in the tree/a float
end
map("n", "<Left>", function()
  cycle_split(-1)
end, { desc = "Focus previous split (wraps)" })
map("n", "<Right>", function()
  cycle_split(1)
end, { desc = "Focus next split (wraps)" })
map("n", "<Up>", "<C-w>k", { desc = "Focus split above" })
map("n", "<Down>", "<C-w>j", { desc = "Focus split below" })

-- comments (built-in gc; remap=true so the gcc/gc operator runs)
map("n", "<leader>m", "gcc", { remap = true, desc = "Comment line" })
map("x", "<leader>m", "gc", { remap = true, desc = "Comment" })

-- move lines up / down
map("n", "<leader>j", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("n", "<leader>k", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("x", "<leader>j", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("x", "<leader>k", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- glide through the file a few lines at a time: <C-h> down, <C-l> up. Uses
-- <C-e>/<C-y> (scroll the viewport, not jump the cursor) so it feels smooth,
-- not lurchy. h/l are free here — splits are focused with <leader> + arrows.
map("n", "<C-h>", "5<C-e>", { desc = "Scroll down" })
map("n", "<C-l>", "5<C-y>", { desc = "Scroll up" })

-- jump back to where you came from, e.g. after gd. (Forward-jump <C-i> is not
-- available — Tab is the next-tab key above, and Tab == <C-i> in a terminal.)
map("n", "gk", "<C-o>", { desc = "Jump back" })

-- ── terminal ──────────────────────────────────────────────────────────────
map("n", "<leader>t", "<cmd>ToggleTerm<cr>", { desc = "New terminal" })

-- ── core-motion overrides (match VSCode; remove to restore stock Vim) ──────

-- paragraph jumps on J / K
map("n", "J", "}", { desc = "Next paragraph" })
map("n", "K", "{", { desc = "Previous paragraph" })

-- folding, smart toggles:
--   f   toggle the fold under the cursor (recursively): folded -> unfold,
--       unfolded -> fold
--   fa  toggle ALL folds: any closed fold in the file -> open all, else close all
-- (`f` waits briefly for the `a` — that's the fa prefix; raise/lower with
-- timeoutlen above.) pcall hides the harmless "no fold here" error.
-- F / fu are free again (stock F = find char backwards).
map("n", "f", function()
  pcall(function()
    vim.cmd("normal! zA")
  end)
end, { desc = "Toggle fold (recursive)" })
map("n", "fa", function()
  local any_closed = false
  for l = 1, vim.fn.line("$") do
    if vim.fn.foldclosed(l) ~= -1 then
      any_closed = true
      break
    end
  end
  vim.cmd("normal! " .. (any_closed and "zR" or "zM"))
end, { desc = "Toggle all folds" })

-- copy / cut the whole file to the system clipboard. cc shadows change-line.
-- NOTE: <leader>x empties the buffer, and the autosave above will write that
-- empty file ~1s later — press u to undo (the content is still on the clipboard).
-- select the whole file (visual line mode, like VSCode Ctrl-A)
map("n", "<leader>a", "ggVG", { desc = "Select whole file" })
map("n", "cc", "<cmd>%yank +<cr>", { desc = "Copy whole file" })
map("n", "<leader>x", "<cmd>%delete +<cr>", { desc = "Cut whole file to clipboard" })

-- copy the current file's absolute path to the system clipboard
map("n", "<leader>cp", function()
  local path = vim.fn.expand("%:p")
  if path == "" then
    vim.notify("No file in this buffer", vim.log.levels.WARN)
    return
  end
  vim.fn.setreg("+", path)
  vim.notify("Copied path: " .. path)
end, { desc = "Copy file path" })

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
