-- File explorer (oil.nvim — edit your filesystem like a buffer).
return {
  {
    "stevearc/oil.nvim",
    lazy = false,
    opts = {},
    keys = {
      { "<leader>e", "<cmd>Oil<cr>", desc = "Explorer" },
    },
  },
}
