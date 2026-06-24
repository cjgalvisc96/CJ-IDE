-- File explorer: nvim-tree as a side panel docked on the LEFT.
--
-- Swapped from neo-tree to shed two dependencies (plenary + nui): nvim-tree
-- gives the same docked-tree experience with just nvim-web-devicons. Use a Nerd
-- Font (https://www.nerdfonts.com) so the file icons + glyphs render.
return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeToggle", "NvimTreeFindFileToggle" },
    -- <leader>e toggles the tree and reveals the current file (like neo-tree's
    -- `toggle reveal`).
    keys = {
      { "<leader>e", "<cmd>NvimTreeFindFileToggle<cr>", desc = "Explorer (tree)" },
    },
    -- nvim-tree wants netrw disabled before it loads, and this must happen at
    -- startup (not on the lazy load), hence init rather than config.
    init = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    end,
    opts = {
      view = {
        side = "left", -- dock the tree on the left side
        width = 34,
      },
      renderer = {
        group_empty = true, -- collapse chains of empty folders
      },
      update_focused_file = {
        enable = true, -- track/reveal the file you're editing
      },
      filters = {
        dotfiles = false, -- show dotfiles
        git_ignored = true, -- hide gitignored files
      },
      -- filesystem_watchers are on by default, so the tree auto-refreshes on
      -- external changes (no extra config needed).
    },
  },
}
