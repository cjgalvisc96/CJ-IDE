-- Project-wide search & REPLACE, VSCode-style (grug-far.nvim).
--
-- fzf-lua stays your fast search *picker* on <leader>f / <leader>F. This is the
-- heavier "find AND replace across files" panel:
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
-- Replacing (all buffer-local; <localleader> = Space here):
--   <space>r   replace ALL matches
--   <space>l   replace only the match on the CURRENT line  (one-by-one)
--   <space>s   sync your inline edits in the results back to the files
--   <space>c   close the panel
-- One-by-one, the VSCode way: just delete the result lines you DON'T want before
-- <space>r, or step line to line with <space>l.
return {
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    -- opts (even empty) makes lazy call grug-far's required setup() on load.
    opts = {},
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
