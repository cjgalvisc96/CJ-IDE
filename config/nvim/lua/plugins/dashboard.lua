-- Start screen / homepage (alpha-nvim) — replaces the stock Neovim intro with a
-- CJ-IDE banner + quick actions. Shown on launch when no file is opened.
return {
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        [[ ██████╗     ██╗      ██╗██████╗ ███████╗]],
        [[██╔════╝     ██║      ██║██╔══██╗██╔════╝]],
        [[██║          ██║█████╗██║██║  ██║█████╗  ]],
        [[██║     ██   ██║╚════╝██║██║  ██║██╔══╝  ]],
        [[╚██████╗╚█████╔╝      ██║██████╔╝███████╗]],
        [[ ╚═════╝ ╚════╝       ╚═╝╚═════╝ ╚══════╝]],
        [[                                         ]],
        [[      a batteries-included Neovim IDE     ]],
      }

      -- Buttons mirror the real keymaps so the dashboard teaches them.
      dashboard.section.buttons.val = {
        dashboard.button("p", "  Find file", "<cmd>FzfLua files<cr>"),
        dashboard.button("r", "  Recent files", "<cmd>FzfLua oldfiles<cr>"),
        dashboard.button("F", "  Find text", "<cmd>FzfLua live_grep<cr>"),
        dashboard.button("n", "  New file", "<cmd>ene | startinsert<cr>"),
        dashboard.button("e", "  File explorer", "<cmd>Neotree toggle reveal<cr>"),
        dashboard.button("?", "  Keybindings", "<cmd>CJHelp<cr>"),
        dashboard.button("u", "  Update plugins", "<cmd>Lazy update<cr>"),
        dashboard.button("q", "  Quit", "<cmd>qa<cr>"),
      }

      dashboard.section.footer.val = "leader = Space   •   press ? anytime for the cheatsheet"

      dashboard.section.header.opts.hl = "Keyword"
      dashboard.section.buttons.opts.hl_shortcut = "Include"
      dashboard.section.footer.opts.hl = "Comment"

      alpha.setup(dashboard.config)

      -- Don't show the dashboard's empty buffer in the bufferline/tab count, and
      -- hide the statusline while it's up for a cleaner look.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "alpha",
        callback = function()
          vim.opt_local.laststatus = 0
          vim.api.nvim_create_autocmd("BufUnload", {
            buffer = 0,
            callback = function()
              vim.opt.laststatus = 3
            end,
          })
        end,
      })
    end,
  },
}
