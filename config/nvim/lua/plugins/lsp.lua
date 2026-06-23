-- LSP (native vim.lsp config; server binaries come from mise on your PATH).
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "saghen/blink.cmp", "b0o/schemastore.nvim" },
    config = function()
      vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

      vim.lsp.config("lua_ls", {
        settings = { Lua = { diagnostics = { globals = { "vim" } } } },
      })
      vim.lsp.config("basedpyright", {
        settings = { basedpyright = { analysis = { typeCheckingMode = "standard" } } },
      })
      vim.lsp.config("gopls", {
        settings = {
          gopls = {
            analyses = { unusedparams = true },
            staticcheck = true,
            hints = { parameterNames = true, assignVariableTypes = true },
          },
        },
      })
      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            schemaStore = { enable = false, url = "" },
            schemas = require("schemastore").yaml.schemas(),
          },
        },
      })
      vim.lsp.config("jsonls", {
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      })

      vim.lsp.enable({ "lua_ls", "basedpyright", "ruff", "gopls", "yamlls", "jsonls" })

      -- Free the `gr` prefix: Neovim 0.11+ ships default maps on grn/gra/grr/gri,
      -- which would make a bare `gr` wait (and shadow it). We use <leader>c* for
      -- rename/code-action, so drop those defaults and give a clean g-nav scheme.
      for _, key in ipairs({ "grn", "gra", "grr", "gri", "grt" }) do
        pcall(vim.keymap.del, "n", key)
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local b = ev.buf
          local function m(l, fn, d)
            vim.keymap.set("n", l, fn, { buffer = b, desc = d })
          end
          -- Navigation via fzf-lua pickers: a searchable floating list instead
          -- of dumping results into the quickfix window. Minimal g-key scheme:
          --   gd definition · gr references   (gk = jump back lives in user.lua)
          -- [d / ]d diagnostics are defaults.
          m("gd", "<cmd>FzfLua lsp_definitions<cr>", "Definition")
          m("gr", "<cmd>FzfLua lsp_references<cr>", "References")
          m("<leader>cr", vim.lsp.buf.rename, "Rename")
          m("<leader>ca", vim.lsp.buf.code_action, "Code action")
          m("<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
        end,
      })
    end,
  },
}
