# Repository structure

```
CJ-IDE/
├── config/
│   ├── nvim/
│   │   ├── init.lua            # entry point: sets leader, loads modules
│   │   ├── lazy-lock.json      # pinned plugin versions
│   │   └── lua/
│   │       ├── config/         # editor config modules
│   │       │   ├── options.lua     editor options + diagnostics
│   │       │   ├── keymaps.lua      global keymaps
│   │       │   ├── autocmds.lua     filetype tweaks
│   │       │   ├── lazy.lua         lazy.nvim bootstrap (imports plugins/)
│   │       │   ├── user.lua         VSCode-style keybindings (intended edit point)
│   │       │   ├── help.lua         `?` / :CJHelp cheatsheet (loaded last)
│   │       │   └── tree_filter.lua  nvim-tree filtering
│   │       └── plugins/        # one file per plugin area, each returns lazy specs
│   │           ├── ui.lua, dashboard.lua, finder.lua, explorer.lua,
│   │           ├── lsp.lua, completion.lua, treesitter.lua, terminal.lua,
│   │           └── replace.lua, markdown.lua
│   └── mise/                   # global toolchain (LSP servers, formatters)
├── install.sh                 # one-command installer
├── prune.sh                   # uninstaller (must reverse install.sh)
├── resync.sh                  # re-sync config/tooling
├── stylua.toml, .editorconfig # formatting
└── README.md, CONTRIBUTING.md
```

## LSP servers in use
`lua_ls`, `basedpyright`, `ruff`, `gopls`, `yamlls`, `jsonls` — installed via mise,
not mason. Keep this list aligned unless there's a strong reason to expand it.

## Languages supported out of the box
Python, Go, YAML, JSON, Lua, Bash, Dockerfile, Markdown.
