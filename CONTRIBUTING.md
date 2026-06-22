# Contributing to CJ-IDE

Thanks for your interest! This project aims to stay small, readable and easy to
fork. Contributions of all sizes are welcome.

## Ground rules

- Keep the Neovim config **plain and commented** — no premature abstractions.
- `config/nvim/` is the single source of truth. The installer copies it into
  `~/.config/nvim`, so put real changes there (not inline in `install.sh`).
- One concern per file under `config/nvim/lua/plugins/`.

## Before you open a PR

1. **Lint the shell scripts:**

   ```bash
   shellcheck install.sh prune.sh
   bash -n install.sh prune.sh
   ```

2. **Format/lint the Lua** (matches CI):

   ```bash
   stylua --check config/nvim
   luacheck config/nvim --globals vim --no-max-line-length
   ```

3. **Try a real install** (a container or VM is ideal so you don't clobber your
   own config):

   ```bash
   ./install.sh --backup
   ./install.sh --check   # verify tools resolved on PATH
   nvim                   # then :checkhealth
   ```

4. If you touched Lua, make sure `nvim` starts cleanly and `:checkhealth`
   reports no new errors.

## Adding a plugin

Create `config/nvim/lua/plugins/<name>.lua` returning a lazy.nvim spec table.
It's auto-loaded via the `{ import = "plugins" }` rule — no extra wiring needed.

## Adding a tool (LSP, formatter, TUI)

Add the mise spec to the matching section of `config/mise/tools.txt` (the single
manifest both `install.sh` and `prune.sh` read), then wire it into the relevant
Lua plugin spec. Add its binary name to the `EXPECTED_BINS` list in `install.sh`
so `--check` covers it.

## Commit messages

Short, imperative subject lines (e.g. `add rust LSP support`). Reference issues
where relevant.
