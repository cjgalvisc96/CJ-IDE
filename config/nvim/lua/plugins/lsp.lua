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
          -- Navigation via fzf-lua pickers: a searchable floating list instead
          -- of dumping results into the quickfix window.
          --
          -- We deliberately do NOT map bare `gr`. Neovim 0.11+ ships default LSP
          -- maps on the `gr` prefix (grn rename, gra code action, gri impl), so
          -- a complete `gr` map would shadow all of them. Instead we override the
          -- prefix leaves we want with nicer pickers and leave the rest as-is.
          -- K (hover) and [d / ]d (diagnostics) are Neovim defaults already.
          m("gd", "<cmd>FzfLua lsp_definitions<cr>", "Definition")
          m("grr", "<cmd>FzfLua lsp_references<cr>", "References")
          m("gri", "<cmd>FzfLua lsp_implementations<cr>", "Implementation")
          m("gy", "<cmd>FzfLua lsp_typedefs<cr>", "Type definition")
          m("<leader>cr", vim.lsp.buf.rename, "Rename")
          m("<leader>ca", vim.lsp.buf.code_action, "Code action")
        end,
      })
    end,
  },
}
