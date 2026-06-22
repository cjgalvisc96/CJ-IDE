-- Fuzzy finder (fzf-lua).
return {
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    opts = {},
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>FzfLua helptags<cr>", desc = "Help" },
      { "<leader>fr", "<cmd>FzfLua resume<cr>", desc = "Resume" },
      { "<leader>fd", "<cmd>FzfLua diagnostics_document<cr>", desc = "Diagnostics" },
      { "<leader>fs", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Symbols" },
    },
  },
}
