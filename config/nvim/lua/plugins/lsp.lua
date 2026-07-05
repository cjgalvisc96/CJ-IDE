-- LSP — server binaries come from mise on your PATH (mason is disabled in
-- core.lua, so every server sets mason = false). The LazyVim lang extras
-- (python/go/json/yaml, see config/lazy.lua) provide the base per-language
-- wiring — including schemastore for json/yaml; this file only pins the
-- CJ-IDE specifics on top.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Keymap tweaks for every server:
        --   K  -> freed for paragraph-jump (user.lua); hover docs live on gh.
        -- gd / gr already open fzf-lua pickers (LazyVim + the fzf extra), and
        -- <leader>cr / <leader>ca / <leader>cd match the old CJ-IDE maps.
        ["*"] = {
          keys = {
            { "K", false },
            {
              "gh",
              function()
                vim.lsp.buf.hover()
              end,
              desc = "Hover docs",
            },
          },
        },
        lua_ls = { mason = false },
        basedpyright = {
          mason = false,
          settings = { basedpyright = { analysis = { typeCheckingMode = "standard" } } },
        },
        ruff = { mason = false },
        gopls = {
          mason = false,
          settings = {
            gopls = {
              analyses = { unusedparams = true },
              staticcheck = true,
              hints = { parameterNames = true, assignVariableTypes = true },
            },
          },
        },
        yamlls = { mason = false },
        jsonls = { mason = false },
      },
    },
  },
}
