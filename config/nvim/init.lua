-- CJ-IDE — Neovim entry point (LazyVim-based).
--
-- The config is a thin CJ-IDE layer on top of LazyVim (https://lazyvim.org),
-- which owns the plumbing: plugin defaults, LSP wiring, treesitter, UI.
--
--   config/lazy      LazyVim bootstrap + the extras CJ-IDE enables
--   config/options   option overrides (LazyVim defaults otherwise)
--   config/keymaps   global maps; loads user.lua + help.lua, then prunes any
--                    LazyVim map that clashes with the single-key scheme
--   config/autocmds  filetype tweaks
--   config/user      the VSCode-style keybindings (edit THIS to change them)
--
-- LSP servers and formatters are installed globally via mise and found on your
-- PATH (see install.sh). mason stays disabled (lua/plugins/core.lua).

require("config.lazy")
