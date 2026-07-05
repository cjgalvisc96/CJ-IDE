-- Search & REPLACE, VSCode-style (grug-far.nvim). Opens a panel:
--   <leader>r   replace in the CURRENT FILE   (<leader>r in visual = the selection)
--   <leader>R   replace across the whole PROJECT
-- It uses ripgrep (already on PATH via mise), so no extra dependency — and unlike
-- nvim-spectre it needs no plenary, keeping this config's deps lean.
--
-- Open a panel, then fill the fields (VSCode's Search / Replace / files-to-include
-- / files-to-exclude):
--   Search        the pattern (ripgrep regex by default)
--   Replace       the replacement (leave empty to just search)
--   Files Filter  INCLUDE globs, space/newline separated:  *.lua  src/**  *.md
--   Flags         extra ripgrep flags — this is where you EXCLUDE N dirs/regex:
--                   --glob=!**/node_modules/**   exclude a dir
--                   --glob=!**/.venv/**          …another (repeat per dir)
--                   -i                           case-insensitive
--                   -F                           treat Search as a literal, not regex
--
-- Replacing, inside the panel (buffer-local; <localleader> = Space here):
--   r                   replace ONLY the match under the cursor (one by one)
--   R                   replace ALL matches
--   <space>c / <leader>q   close the panel   (:q works too)
--   <space>Q            send matches to the quickfix list
-- Fill Search + Replace, then walk match to match pressing r, or R to do them
-- all at once.

-- grug-far's close is moved to <leader>q below; keep the old <Space>c closing
-- too by pointing it at the same action (resolved at keypress, so setup order
-- doesn't matter).
vim.api.nvim_create_autocmd("FileType", {
  pattern = "grug-far",
  callback = function(ev)
    vim.keymap.set(
      "n",
      "<localleader>c",
      "<localleader>q",
      { buffer = ev.buf, remap = true, desc = "grug-far: close" }
    )
  end,
})

return {
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    opts = {
      keymaps = {
        -- In-panel replace on r / R (per your request): r applies just the match
        -- under the cursor (one by one), R applies them all at once.
        syncLine = { n = "r" },
        syncLocations = { n = "R" },
        -- Close on <leader>q too — CJ-IDE's universal "close editor". grug-far's
        -- send-to-quickfix defaulted to <localleader>q (= <Space>q = <leader>q)
        -- and swallowed it, so move quickfix to <localleader>Q and put the real
        -- close (aborts the search, cleans up) on <localleader>q.
        close = { n = "<localleader>q" },
        qflist = { n = "<localleader>Q" },
      },
    },
    keys = {
      {
        "<leader>r",
        function()
          require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
        end,
        desc = "Replace in current file",
      },
      {
        "<leader>R",
        function()
          require("grug-far").open()
        end,
        desc = "Replace across project",
      },
      {
        "<leader>r",
        mode = "x",
        function()
          -- seed Search with the highlighted text (regex-escaped by grug-far)
          require("grug-far").with_visual_selection()
        end,
        desc = "Replace selection (project)",
      },
    },
  },
}
