# Contributing to CJ-IDE

Thanks for your interest! This project aims to stay small, readable and easy to
fork. Contributions of all sizes are welcome.

## Ground rules

- Keep the Neovim config **plain and commented** — no premature abstractions.
- `config/nvim/` is the single source of truth. The installer copies it into
  `~/.config/nvim`, so put real changes there (not inline in `install.sh`).
- One concern per file under `config/nvim/lua/plugins/`.

## Before you open a PR

1. **Lint the installer:**

   ```bash
   shellcheck install.sh prune.sh
   bash -n install.sh prune.sh
   ```

   If you add a tool to `install.sh`, mirror it in `prune.sh`'s `CJ_TOOLS`
   list so uninstall stays complete.

2. **Try a real install** (a container or VM is ideal so you don't clobber your
   own config):

   ```bash
   ./install.sh --backup
   nvim   # then :checkhealth
   ```

3. If you touched Lua, make sure `nvim` starts cleanly and `:checkhealth`
   reports no new errors.

## Adding a plugin

Create `config/nvim/lua/plugins/<name>.lua` returning a lazy.nvim spec table.
It's auto-loaded via the `{ import = "plugins" }` rule — no extra wiring needed.

## Adding a tool (LSP, formatter, TUI)

Add a `mise_use "..."` line in the matching `install_*` function in
`install.sh`, then wire it into the relevant Lua plugin spec.

## Commit messages

Short, imperative subject lines (e.g. `add rust LSP support`). Reference issues
where relevant.
