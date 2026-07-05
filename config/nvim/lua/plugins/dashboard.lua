-- Start screen — snacks.dashboard (LazyVim's default) with the CJ-IDE banner.
-- Shown on launch when no file is opened. Buttons mirror the real keymaps so
-- the dashboard teaches them.
return {
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = table.concat({
            [[ ██████╗     ██╗      ██╗██████╗ ███████╗]],
            [[██╔════╝     ██║      ██║██╔══██╗██╔════╝]],
            [[██║          ██║█████╗██║██║  ██║█████╗  ]],
            [[██║     ██   ██║╚════╝██║██║  ██║██╔══╝  ]],
            [[╚██████╗╚█████╔╝      ██║██████╔╝███████╗]],
            [[ ╚═════╝ ╚════╝       ╚═╝╚═════╝ ╚══════╝]],
            [[                                         ]],
            [[     a batteries-included Neovim IDE     ]],
          }, "\n"),
          keys = {
            { icon = " ", key = "p", desc = "Find File", action = ":FzfLua files" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":FzfLua oldfiles" },
            { icon = " ", key = "F", desc = "Find Text", action = ":FzfLua live_grep" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "e", desc = "File Explorer", action = ":NvimTreeFindFileToggle" },
            { icon = "󰋖 ", key = "?", desc = "Keybindings", action = ":CJHelp" },
            { icon = "󰒲 ", key = "u", desc = "Update Plugins", action = ":Lazy update" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
      },
    },
  },
}
