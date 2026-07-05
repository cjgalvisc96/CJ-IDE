# Workflow, agents & releases

## Agents (`.claude/agents/`)
- **lead** — entry point for multi-step work; plans, delegates, owns outcomes and release hygiene.
- **architect** — designs strategy and module structure; plans, doesn't write final code.
- **dev** — implements features and fixes in Lua and shell.
- **tester** — verifies changes (lint, headless load, script syntax) and reports faithfully.

Typical flow: lead → architect (plan) → dev (implement) → tester (verify) → lead (summarize).

## Verification before "done"
- `stylua --check config/nvim` — formatting clean.
- `nvim --headless "+lua vim.cmd('quitall')"` — config loads without errors (if nvim available).
- `bash -n install.sh prune.sh resync.sh` — script syntax; `shellcheck` if installed.
- Report faithfully: show real command output; if a check was skipped (tool missing), say so.

## Releases
- Versions are tagged `v0.0.x` with matching commit messages (e.g. `v0.0.37`).
- **Do not commit, tag, or push unless the user explicitly asks.**
- When behavior changes (keybindings, plugins, install steps), keep README/CONTRIBUTING in sync.
