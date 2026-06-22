-- Format-on-save (conform.nvim; formatters come from mise on your PATH).
return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    keys = {
      {
        "<leader>cf",
        function() require("conform").format({ lsp_format = "fallback" }) end,
        desc = "Format",
      },
    },
    opts = {
      format_on_save = { timeout_ms = 1500, lsp_format = "fallback" },
      formatters_by_ft = {
        python = { "ruff_format" },
        go = { "goimports", "gofumpt" },
        yaml = { "prettier" },
        json = { "prettier" },
      },
    },
  },
}
