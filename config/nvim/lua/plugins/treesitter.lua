-- Syntax-aware highlighting and indentation.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master", -- pin master: classic .configs API
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "python", "go", "gomod", "gosum", "yaml", "json", "jsonc", "lua",
          "bash", "markdown", "markdown_inline", "dockerfile", "vim", "vimdoc",
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
}
