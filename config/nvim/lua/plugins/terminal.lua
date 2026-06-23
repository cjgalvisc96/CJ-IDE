-- Floating terminal (toggleterm). `<C-\>` toggles it; `<leader>t` opens a new one.
--
-- The lazygit / lazydocker / lazysql / k9s / lazyjournal launchers were removed
-- on purpose — run those tools straight from your shell, outside the IDE.
return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("toggleterm").setup({
        open_mapping = [[<c-\>]],
        direction = "float",
        float_opts = { border = "curved" },
      })
    end,
  },
}
