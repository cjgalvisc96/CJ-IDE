-- Format-on-save (conform.nvim; formatters come from mise on your PATH).
-- Toggle autoformat with :FormatToggle (global) or :FormatToggle! (current buffer).
return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ lsp_format = "fallback" })
        end,
        desc = "Format",
      },
    },
    config = function()
      require("conform").setup({
        format_on_save = function(bufnr)
          -- Respect the toggle flags (buffer-local wins over global).
          if vim.b[bufnr].disable_autoformat or vim.g.disable_autoformat then
            return
          end
          return { timeout_ms = 1500, lsp_format = "fallback" }
        end,
        formatters_by_ft = {
          python = { "ruff_format" },
          go = { "goimports", "gofumpt" },
          yaml = { "prettier" },
          json = { "prettier" },
        },
      })

      vim.api.nvim_create_user_command("FormatToggle", function(args)
        if args.bang then
          vim.b.disable_autoformat = not vim.b.disable_autoformat
          vim.notify("Autoformat (buffer) " .. (vim.b.disable_autoformat and "OFF" or "ON"))
        else
          vim.g.disable_autoformat = not vim.g.disable_autoformat
          vim.notify("Autoformat (global) " .. (vim.g.disable_autoformat and "OFF" or "ON"))
        end
      end, { bang = true, desc = "Toggle format-on-save (! = current buffer)" })
    end,
  },
}
