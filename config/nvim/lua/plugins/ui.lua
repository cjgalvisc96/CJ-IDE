-- Theme, statusline and keymap hints.
return {
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("tokyonight-night")
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = { theme = "tokyonight", globalstatus = true },
      sections = {
        -- Show the file's ABSOLUTE PATH (path = 2) in the statusline, with the
        -- modified/readonly flags. Use path = 1 for relative, 4 for name-only.
        lualine_c = {
          { "filename", path = 2, symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" } },
        },
      },
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },
}
