# CJ-IDE

A batteries-included **Neovim IDE** distributed as a Lua config plus shell
installer scripts. Installs in one command, no manual plugin wrangling, no
`mason`, no per-machine setup. Cross-platform: Debian/Ubuntu, Fedora, Arch,
RHEL/Rocky/Alma, openSUSE, macOS.

**Since v0.0.38 the config is a thin layer on top of [LazyVim](https://lazyvim.org)**
(migrated 2026-07-05). LazyVim owns plugin defaults/LSP wiring/treesitter/UI;
CJ-IDE keeps its VSCode-style keymaps (`lua/config/user.lua`), nvim-tree,
toggleterm, the mise toolchain (no mason) and the `?` cheatsheet.

## What this repo is
- `config/nvim/` — the Neovim configuration: LazyVim bootstrap + extras in
  `lua/config/lazy.lua`, CJ-IDE overrides in `lua/plugins/`.
- `install.sh` / `prune.sh` / `resync.sh` — install, uninstall, and re-sync tooling.
- `config/mise/` — global toolchain (LSP servers, formatters) installed via **mise**.

## Non-negotiables
- **No `mason`.** LSP servers and formatters are installed globally via **mise** and
  found on `PATH` (see `install.sh`). mason plugins are disabled in
  `lua/plugins/core.lua`; every server sets `mason = false` in `lua/plugins/lsp.lua`.
- **User keymaps are law.** `lua/config/user.lua` is preserved verbatim;
  `lua/config/keymaps.lua` prunes any LazyVim map that extends a CJ-IDE
  single-key `<leader>` binding (prefix maps cause a `timeoutlen` pause).
  Never reintroduce maps on those prefixes.
- **One-command, cross-platform.** Any installer change must degrade gracefully across
  every supported distro and macOS.
- **Reversible.** Anything `install.sh` creates, `prune.sh` must be able to remove.
- **Batteries-included but minimal.** Every added plugin/dependency must earn its place;
  prefer native Neovim/LSP features first.

## Detailed rules
- Lua & lazy.nvim conventions → @.claude/rules/lua-style.md
- Repository structure → @.claude/rules/structure.md
- Installer / mise / cross-platform → @.claude/rules/installer.md
- Workflow, agents & releases → @.claude/rules/workflow.md

## Quick reference
- Format check: `stylua --check config/nvim`
- Config loads headless: `nvim --headless "+lua vim.cmd('quitall')"`
- Script syntax: `bash -n install.sh prune.sh resync.sh`
- Do **not** commit, tag, or push unless explicitly asked. Releases are tagged `v0.0.x`.
