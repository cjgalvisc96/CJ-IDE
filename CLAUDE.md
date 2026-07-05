# CJ-IDE

A batteries-included **Neovim IDE** distributed as a Lua config plus shell
installer scripts. Installs in one command, no manual plugin wrangling, no
`mason`, no per-machine setup. Cross-platform: Debian/Ubuntu, Fedora, Arch,
RHEL/Rocky/Alma, openSUSE, macOS.

## What this repo is
- `config/nvim/` — the Neovim configuration (entry point `init.lua`, modules under `lua/`).
- `install.sh` / `prune.sh` / `resync.sh` — install, uninstall, and re-sync tooling.
- `config/mise/` — global toolchain (LSP servers, formatters) installed via **mise**.

## Non-negotiables
- **No `mason`.** LSP servers and formatters are installed globally via **mise** and
  found on `PATH` (see `install.sh`). Never add mason or per-machine tool installs.
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
