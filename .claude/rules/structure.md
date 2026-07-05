# Repository structure

Since v0.0.38 the Neovim config is **LazyVim-based**: LazyVim provides the
plugin baseline; everything under `lua/plugins/` is a CJ-IDE *override* merged
on top of LazyVim's specs (lazy.nvim deep-merges `opts`).

```
CJ-IDE/
├── config/
│   ├── nvim/
│   │   ├── init.lua            # entry point: require("config.lazy")
│   │   ├── lazy-lock.json      # pinned plugin versions (regenerate via :Lazy update)
│   │   └── lua/
│   │       ├── config/
│   │       │   ├── lazy.lua         LazyVim bootstrap + extras (fzf, lang.*)
│   │       │   ├── options.lua      overrides on LazyVim defaults; autoformat OFF;
│   │       │   │                    lazyvim_python_lsp/ruff + lazyvim_picker globals
│   │       │   ├── keymaps.lua      global maps → loads user.lua + help.lua →
│   │       │   │                    PRUNES LazyVim maps extending CJ single keys
│   │       │   ├── autocmds.lua     filetype tweaks
│   │       │   ├── user.lua         VSCode-style keybindings (preserve verbatim)
│   │       │   ├── help.lua         `?` / :CJHelp cheatsheet
│   │       │   └── tree_filter.lua  nvim-tree live filtering
│   │       └── plugins/        # CJ-IDE overrides of LazyVim
│   │           ├── core.lua         mason OFF ×2, flash char mode off,
│   │           │                    gitsigns buffer maps off
│   │           ├── lsp.lua          servers w/ mason=false; K freed, gh=hover
│   │           ├── ui.lua           lualine abs path, bufferline offsets
│   │           ├── dashboard.lua    snacks.dashboard w/ CJ-IDE banner
│   │           ├── explorer.lua     nvim-tree (kept over LazyVim's explorer)
│   │           ├── terminal.lua     toggleterm (<C-\>)
│   │           ├── replace.lua      grug-far keymaps (<leader>r / <leader>R)
│   │           ├── completion.lua   blink.cmp "default" keymap preset
│   │           └── markdown.lua     render-markdown tweaks (<leader>md)
│   └── mise/tools.txt          # SINGLE SOURCE for tools (runtimes/cli/lsp sections)
├── install.sh                 # one-command installer (mise + copies config/nvim)
├── prune.sh                   # uninstaller (must reverse install.sh)
├── resync.sh                  # mirror config/nvim -> ~/.config/nvim
├── stylua.toml, .editorconfig # formatting
└── README.md, CONTRIBUTING.md
```

## LazyVim extras enabled (config/lazy.lua)
`editor.fzf`, `lang.python` (basedpyright + ruff), `lang.go`, `lang.json`,
`lang.yaml`, `lang.docker`, `lang.markdown`.

## LSP servers in use
`lua_ls`, `basedpyright`, `ruff`, `gopls`, `yamlls`, `jsonls` — installed via
mise, **never mason**; every server sets `mason = false` in `lua/plugins/lsp.lua`.

## Languages supported out of the box
Python, Go, YAML, JSON, Lua, Bash, Dockerfile, Markdown.
