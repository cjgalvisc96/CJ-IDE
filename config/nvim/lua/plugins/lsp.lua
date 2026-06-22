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

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local b = ev.buf
          local function m(l, fn, d)
            vim.keymap.set("n", l, fn, { buffer = b, desc = d })
          end
          m("gd", vim.lsp.buf.definition, "Definition")
          m("gr", vim.lsp.buf.references, "References")
          m("gi", vim.lsp.buf.implementation, "Implementation")
          m("K", vim.lsp.buf.hover, "Hover")
          m("<leader>cr", vim.lsp.buf.rename, "Rename")
          m("<leader>ca", vim.lsp.buf.code_action, "Code action")
          m("[d", function() vim.diagnostic.jump({ count = -1 }) end, "Prev diagnostic")
          m("]d", function() vim.diagnostic.jump({ count = 1 }) end, "Next diagnostic")
        end,
      })
    end,
  },
}
