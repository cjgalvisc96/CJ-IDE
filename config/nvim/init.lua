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
