# Lua & lazy.nvim conventions

## Formatting (stylua.toml)
- `column_width = 100`, `indent_width = 2`, spaces (no tabs), Unix line endings.
- `quote_style = "AutoPreferDouble"` — prefer `"double"` quotes.
- `call_parentheses = "Always"` — always use parentheses on calls.
- Run `stylua --check config/nvim` before considering a change done; fix any diff.
- `.editorconfig` also applies: UTF-8, LF, final newline, trim trailing whitespace,
  2-space indent for `*.lua`/`*.sh`, tabs for `*.go` and `Makefile`.

## Plugin specs (lazy.nvim)
- Every file in `config/nvim/lua/plugins/` returns a table of specs; lazy loads them
  all via `{ import = "plugins" }` in `config/lazy.lua`.
- Follow the existing spec shape:
  ```lua
  -- Short comment: what this plugin does + key bindings.
  return {
    {
      "owner/repo",
      version = "*",          -- or a pinned tag; keep lazy-lock.json in sync
      event = "VeryLazy",     -- prefer lazy-loading (event/ft/keys/cmd)
      config = function()
        require("plugin").setup({ ... })
      end,
    },
  }
  ```
- Lazy-load wherever possible (`event`, `ft`, `keys`, `cmd`) — startup time matters.
- `lazy-lock.json` pins plugin versions; update it deliberately, don't hand-edit noise.
- luarocks is disabled (`rocks = { enabled = false }`) — don't add plugins that need it.

## Modules
- Editor config lives in `config/nvim/lua/config/` (options, keymaps, autocmds, lazy, help, user).
- `init.lua` loads: options → keymaps → autocmds → lazy → `config.user` (pcall) → `config.help` (last).
- User-facing keymaps mimic a VSCode/VSCodeVim workflow; leader is Space. `config.user` is
  the intended edit point for keybindings and is loaded before `config.help` on purpose.
