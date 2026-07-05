-- Completion — blink.cmp is LazyVim's default engine; keep the CJ-IDE feel:
-- the stock "default" keymap preset (<C-y> accept, <C-n>/<C-p> select) and
-- signature help while typing arguments.
return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = { preset = "default" },
      signature = { enabled = true },
    },
  },
}
