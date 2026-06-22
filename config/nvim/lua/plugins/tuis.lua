-- TUIs in floating terminals (toggleterm). Binaries come from mise on PATH.
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

      local Terminal = require("toggleterm.terminal").Terminal
      local cache = {}
      local function tui(cmd)
        return function()
          cache[cmd] = cache[cmd]
            or Terminal:new({
              cmd = cmd,
              direction = "float",
              float_opts = { border = "curved" },
              hidden = true,
              on_open = function()
                vim.cmd("startinsert!")
              end,
            })
          cache[cmd]:toggle()
        end
      end

      local map = vim.keymap.set
      map("n", "<leader>lg", tui("lazygit"), { desc = "Lazygit" })
      map("n", "<leader>ld", tui("lazydocker"), { desc = "Lazydocker" })
      map("n", "<leader>lk", tui("k9s"), { desc = "k9s" })
      map("n", "<leader>ls", tui("lazysql"), { desc = "LazySQL" })
      map("n", "<leader>lj", tui("lazyjournal"), { desc = "lazyjournal" })
    end,
  },
}
