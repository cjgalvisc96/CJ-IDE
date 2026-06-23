-- File explorer: neo-tree as a side panel docked on the LEFT.
--
-- neo-tree uses nvim-web-devicons for file icons + tree glyphs, so a Nerd Font
-- (https://www.nerdfonts.com) in your terminal makes it look right.
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys = {
      { "<leader>e", "<cmd>Neotree toggle reveal<cr>", desc = "Explorer (tree)" },
    },
    opts = {
      close_if_last_window = true,
      sort_case_insensitive = true,
      window = {
        position = "left", -- dock the tree on the left side
        width = 34,
      },
      filesystem = {
        follow_current_file = { enabled = true }, -- track the file you're editing
        use_libuv_file_watcher = true, -- auto-refresh on external changes
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = true,
        },
      },
    },
  },
}
