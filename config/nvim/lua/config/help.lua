-- CJ-IDE cheatsheet — a floating window listing every keybinding.
-- Open it with `?` (normal mode) or `:CJHelp`.
--
-- HEADS UP: `?` normally starts a reverse search. CJ-IDE repurposes it for this
-- cheatsheet (same VSCode-flavored spirit as user.lua). Reverse search is still
-- there via `/` then `N`. To restore stock `?`, delete the keymap at the bottom.

local M = {}

-- { "Section title", { { "keys", "action" }, ... } }
local SECTIONS = {
  {
    "Files · Buffers · Search",
    {
      { "<leader>p", "Quick-open file — incl. hidden & gitignored" },
      { "<leader>b", "Switch buffer (fuzzy)" },
      { "<leader>f", "Search in current file (visual: selection)" },
      { "<leader>F", "Search in project — live grep (visual: selection)" },
      { "<leader>g", "Search word/selection (file)" },
      { "<leader>G", "Search word/selection (project)" },
      { "<leader>r / <leader>R", "Replace panel — current file / project" },
      { "<leader>r (visual)", "Replace panel seeded with the selection" },
      { "  r / R (in panel)", "Replace this match (one by one) / all" },
      { "  incl=Files Filter", "exclude/regex=Flags (--glob=!**/dir/**)" },
      { "  <space>c / <leader>q", "Close the replace panel (:q works too)" },
      { "<leader>e", "Explorer — open / focus / close tree (left)" },
      { "<leader>f (in tree)", "Live-search FILES; press again to clear" },
      { "<leader>d (in tree)", "Live-search DIRECTORIES; press again to clear" },
      { "<leader>p (in tree)", "Directories-only view (hide files); toggle" },
      { "f / F (in tree)", "Live-filter any name (toggle) / clear" },
      { "arrows (in tree)", "↑↓ move · → expand/open · ← collapse" },
      { "<leader>n", "New file (named)" },
      { "<leader>s", "Split editor (vertical)" },
      { "<Left> / <Right>", "Prev / next split (wraps; skips tree)" },
      { "<Up> / <Down>", "Focus split above / below" },
      { "<leader>q", "Close editor (buffer)" },
      { "<leader>Q", "Quit CJ-IDE" },
    },
  },
  {
    "Tabs (open files)",
    {
      { "<Tab> / <S-Tab>", "Next / previous tab" },
      { "<A-,> / <A-.>", "Move current tab left / right" },
      { "<leader>s", "Split editor (vertical)" },
      { "<leader>q", "Close current tab" },
    },
  },
  {
    "Code · LSP",
    {
      { "gd / gr", "Definition / references" },
      { "gh", "Hover docs (K is paragraph-jump)" },
      { "gk", "Jump back" },
      { "<leader>cr / <leader>ca", "Rename / code action" },
      { "<leader>cd", "Line diagnostics (float)" },
      { "[d / ]d", "Prev / next diagnostic" },
      { "<leader>cp", "Copy file's absolute path" },
    },
  },
  {
    "Debug (Python · DAP)",
    {
      { "<C-p> / F5", "Run / continue — start debugging" },
      { "<C-b> / F9", "Toggle breakpoint on this line" },
      { "<C-S-b> / <leader>dx", "Clear ALL breakpoints" },
      { "<C-d> / F10", "Step over" },
      { "<C-f> / S-F11", "Step out" },
      { "F11 / <leader>di", "Step into" },
      { "<C-S-p> / S-F5", "Terminate (stop) the session" },
      { "<leader>dl", "Run last / restart" },
      { "<leader>du / <leader>de", "Toggle debugger UI / eval (normal + visual)" },
      { "<leader>dPt / <leader>dPc", "Debug test method / class (Python)" },
    },
  },
  {
    "Edit · Motion",
    {
      { "<leader>w", "Save" },
      { "<leader>m", "Toggle comment (normal + visual)" },
      { "<leader>j / <leader>k", "Move line/selection down / up" },
      { "J / K", "Next / previous paragraph" },
      { "<C-h> / <C-l>", "Scroll down / up" },
      { "f", "Toggle fold under cursor (recursive)" },
      { "fa", "Toggle ALL folds (open all ⇄ close all)" },
      { "<leader>a", "Select whole file" },
      { "cc / <leader>x", "Copy / cut whole file to clipboard" },
      { "<C-j>", "JSON pretty / minify toggle (any file)" },
      { "<C-s>", "Plain-file toggle — strip completion + diagnostics (all)" },
      { "<leader>md", "Markdown pretty view toggle (*.md)" },
      { "dw du db df", "Delete word/… → insert / append" },
      { "dp dq dk dc", "Delete inside ()  ''  {}  []" },
      { "yf yu yb", "Yank to end / word / to start" },
      { "yp yq yk yc", "Yank inside ()  ''  {}  []" },
    },
  },
  {
    "Terminal",
    {
      { "<C-\\>", "Toggle floating terminal" },
      { "<leader>t", "New terminal" },
      { "<C-x>", "Terminal → normal mode" },
    },
  },
  {
    "Help · Misc",
    {
      { "?  /  :CJHelp", "Show this cheatsheet" },
      { "<Esc>", "Clear search highlight" },
      { "<leader>u", "Update plugins (:Lazy update)" },
      { ":checkhealth", "Diagnose the setup" },
      { ":Lazy", "Plugin manager" },
    },
  },
}

-- Render the sections into aligned text lines.
local function build_lines()
  local key_w = 0
  for _, sec in ipairs(SECTIONS) do
    for _, row in ipairs(sec[2]) do
      key_w = math.max(key_w, #row[1])
    end
  end

  local lines = { "", "  CJ-IDE — keybindings   (leader = Space)", "" }
  for _, sec in ipairs(SECTIONS) do
    table.insert(lines, "  " .. sec[1])
    for _, row in ipairs(sec[2]) do
      table.insert(lines, string.format("    %-" .. key_w .. "s   %s", row[1], row[2]))
    end
    table.insert(lines, "")
  end
  table.insert(lines, "  q / <Esc> / ? / <leader>q to close")
  return lines
end

function M.open()
  local lines = build_lines()

  local width = 0
  for _, l in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(l))
  end
  width = math.min(width + 2, vim.o.columns - 4)
  local height = math.min(#lines, vim.o.lines - 4)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "cjhelp"

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2 - 1),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " CJ-IDE help ",
    title_pos = "center",
  })
  vim.wo[win].cursorline = true
  vim.wo[win].wrap = false

  -- q / <Esc> / ? / <leader>q all close the cheatsheet (buffer-local, so `?`
  -- toggles and <leader>q behaves like CJ-IDE's universal "close editor").
  for _, key in ipairs({ "q", "<Esc>", "?", "<leader>q" }) do
    vim.keymap.set("n", key, function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end, { buffer = buf, nowait = true, silent = true })
  end
end

vim.api.nvim_create_user_command("CJHelp", M.open, { desc = "CJ-IDE cheatsheet" })
vim.keymap.set("n", "?", M.open, { desc = "CJ-IDE cheatsheet" })

return M
