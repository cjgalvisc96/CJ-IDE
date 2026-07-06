-- Completion — blink.cmp is LazyVim's default engine; keep the CJ-IDE feel:
-- the stock "default" keymap preset (<C-y> accept, <C-n>/<C-p> select) and
-- signature help while typing arguments.
return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = { preset = "default" },
      signature = { enabled = true },
      completion = {
        -- No inline "typing suggestions": kill blink's ghost text (the greyed
        -- preview shown at the cursor as you type). The popup menu still works
        -- (and is toggled with <C-s>); this only removes the inline nag.
        ghost_text = { enabled = false },
      },
      -- Master switch for the completion menu, flipped by <C-s> (user.lua) which
      -- toggles the whole "plain file" mode (completion + diagnostics together).
      -- Default ON; blink reads this per keystroke, so the switch is instant
      -- across every buffer. (Inline ghost text stays off regardless — above.)
      enabled = function()
        return vim.g.blink_cmp_enabled ~= false
      end,
    },
  },
}
