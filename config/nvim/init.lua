-- CJ-IDE — Neovim entry point
-- LSP servers, formatters and TUIs are installed globally via mise and found
-- on your PATH (see install.sh). No mason needed.
--
-- Config is split into modules under lua/:
--   config/options   editor options + diagnostics
--   config/keymaps   global keymaps
--   config/autocmds  filetype tweaks
--   config/lazy      plugin manager bootstrap (loads everything in lua/plugins)

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")

-- Keybindings tuned to match a VSCode/VSCodeVim workflow. Loaded last so it
-- overrides the defaults above. Edit lua/config/user.lua to change them.
pcall(require, "config.user")

-- Loaded after user.lua so they can't be clobbered:
--   winbar  absolute-path bar on each file window
--   help    `?` / :CJHelp cheatsheet of every binding
require("config.winbar")
require("config.help")
