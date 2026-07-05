# Workflow, agents & releases

## Agents (`.claude/agents/`)
- **lead** — entry point for multi-step work; plans, delegates, owns outcomes and release hygiene.
- **architect** — designs strategy and module structure; plans, doesn't write final code.
- **dev** — implements features and fixes in Lua and shell.
- **tester** — verifies changes (lint, headless load, script syntax) and reports faithfully.

Typical flow: lead → architect (plan) → dev (implement) → tester (verify) → lead (summarize).

## Verification before "done"
- `stylua --check config/nvim` — formatting clean (`mise x stylua@2.5 -- stylua …` if not on PATH).
- Boot test in an ISOLATED sandbox (never the real `~/.config/nvim`): copy
  `config/nvim` to a scratch dir, point `XDG_CONFIG_HOME/XDG_DATA_HOME/
  XDG_STATE_HOME/XDG_CACHE_HOME` at it, run `nvim --headless "+Lazy! sync" +qa`
  then a plain boot and grep for errors. Use the REAL nvim binary
  (`mise which nvim`), not the mise shim — shims break when XDG_CONFIG_HOME moves.
- Headless gotcha: lazy.nvim's `VeryLazy` fires from `UIEnter`, which never
  happens headless — LazyVim then skips loading keymaps. To test keymaps,
  `vim.api.nvim_exec_autocmds("UIEnter", { modeline = false })` first.
- `bash -n install.sh prune.sh resync.sh` — script syntax; `shellcheck` if installed.
- Report faithfully: show real command output; if a check was skipped (tool missing), say so.

## Releases
- Versions are tagged `v0.0.x` with matching commit messages (e.g. `v0.0.37`).
- **Do not commit, tag, or push unless the user explicitly asks.**
- When behavior changes (keybindings, plugins, install steps), keep README/CONTRIBUTING in sync.
