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

  -- VSCode-like tabs: one tab per open file (buffer), across the top. Click a
  -- tab to switch, click its × to close. Navigation keymaps live in user.lua.
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        mode = "buffers", -- a tab per buffer (not Vim tab-pages)
        diagnostics = "nvim_lsp", -- error/warning dots on tabs, like VSCode
        separator_style = "thin",
        show_buffer_close_icons = true,
        show_close_icon = false,
        -- Keep the tab bar clear of the nvim-tree panel (tabs start to its right).
        offsets = {
          { filetype = "NvimTree", text = "Explorer", highlight = "Directory", separator = true },
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
