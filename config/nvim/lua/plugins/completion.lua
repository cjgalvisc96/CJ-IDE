-- Completion engine (blink.cmp) + JSON/YAML schema catalog.
return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = "InsertEnter",
    opts = {
      keymap = { preset = "default" },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      signature = { enabled = true },
    },
  },

  { "b0o/schemastore.nvim", lazy = true },
}
