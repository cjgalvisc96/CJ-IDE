# Lua & lazy.nvim conventions

## Formatting (stylua.toml)
- `column_width = 100`, `indent_width = 2`, spaces (no tabs), Unix line endings.
- `quote_style = "AutoPreferDouble"` — prefer `"double"` quotes.
- `call_parentheses = "Always"` — always use parentheses on calls.
- Run `stylua --check config/nvim` before considering a change done; fix any diff.
- `.editorconfig` also applies: UTF-8, LF, final newline, trim trailing whitespace,
  2-space indent for `*.lua`/`*.sh`, tabs for `*.go` and `Makefile`.

## Plugin specs (lazy.nvim on a LazyVim base)
- Every file in `config/nvim/lua/plugins/` returns a table of specs, imported
  LAST in `config/lazy.lua` so they **override/merge into LazyVim's** specs.
- Most specs are thin overrides — plugin name + `opts` (deep-merged) and/or
  `keys`. Only plugins LazyVim doesn't ship (nvim-tree, toggleterm) carry a
  full spec with lazy-loading (`event`/`ft`/`keys`/`cmd`).
  ```lua
  -- Short comment: what this override changes and why.
  return {
    { "owner/repo", opts = { the_delta_only = true } },
  }
  ```
- To disable a LazyVim plugin: `{ "owner/repo", enabled = false }` (see
  `plugins/core.lua` for mason).
- `lazy-lock.json` pins plugin versions; regenerate with `:Lazy update`
  (checker is off — updates are deliberate), don't hand-edit.
- luarocks is disabled (`rocks = { enabled = false }`) — don't add plugins that need it.

## Modules
- `init.lua` only requires `config.lazy`. LazyVim itself loads `config.options`,
  `config.keymaps`, `config.autocmds` at the right times.
- `config/keymaps.lua` runs AFTER LazyVim's keymaps: it loads `config.user`
  (the VSCode-style scheme — preserve verbatim) then `config.help`, then
  prunes any global map extending a CJ-IDE single-key `<leader>` binding.
- Leader is Space. `config.user` is the intended edit point for keybindings.
- Options that gate extras (`vim.g.lazyvim_python_lsp`, `vim.g.lazyvim_picker`,
  `vim.g.autoformat`) must be set in `config/options.lua` — it loads before
  the plugin specs are resolved.
