# CJ-IDE

A custom, batteries-included **Neovim IDE** that installs in one command and is
ready to use — no manual plugin wrangling, no `mason`, no per-machine setup.

> Works on Debian/Ubuntu, Fedora, Arch, RHEL/Rocky/Alma, openSUSE and macOS.

<img width="1914" height="1056" alt="CJ-IDE" src="https://github.com/user-attachments/assets/4078b69b-2502-4bfa-99df-28e032b4b50b" />


## Install

```bash
curl -fsSL https://raw.githubusercontent.com/cjgalvisc96/CJ-IDE/main/install.sh | bash
```

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/cjgalvisc96/CJ-IDE/main/prune.sh | bash
```

## What you get

**Languages out of the box:** Python, Go, YAML, JSON, Lua, Bash, Dockerfile,
Markdown.

**Plugins** (managed by [lazy.nvim](https://github.com/folke/lazy.nvim)):

- **alpha-nvim** — CJ-IDE start screen / homepage on launch
- **tokyonight** theme + **lualine** statusline (shows the file's absolute path) + **which-key** hints
- **nvim-treesitter** — syntax-aware highlighting & indentation
- **fzf-lua** — fuzzy finder (files, grep, symbols, diagnostics) + LSP nav
- **nvim-tree** — file tree as a side panel docked on the left
- **blink.cmp** — completion + signature help, fed by **schemastore** for JSON/YAML
- **nvim-lspconfig** — native LSP (`lua_ls`, `basedpyright`, `ruff`, `gopls`, `yamlls`, `jsonls`)
- **toggleterm** — floating terminal (`<C-\>`)

## Keybindings

Leader is **Space**. **Forgot a key? Press `?`** for the full cheatsheet

| Keys | Action |
|------|--------|
| `?` | Show the keybindings cheatsheet (`:CJHelp`) |
| `<leader>p` / `<leader>b` | Open file / switch buffer |
| `<leader>f` / `<leader>F` | Search current file / whole project |
| `<leader>e` | File tree (nvim-tree, left panel) |
| `gd` / `gr` | Definition / references |
| `gk` | Jump back (e.g. after `gd`) |
| `<leader>w` | Save |
| `<leader>u` | Update plugins (`:Lazy update`) |
| `<leader>Q` | Quit CJ-IDE |
| `<leader>n` / `<leader>s` | New file / split editor (vertical) |
| `<leader>←` / `<leader>→` | Focus split left / right |
| `<leader>t` | New terminal |
| `<leader>m` | Toggle comment (normal + visual) |
| `<leader>j` / `<leader>k` | Move line/selection down / up |
| `f` `F` `fa` `fu` | Fold / unfold (recursive / all) |
| `J` / `K` | Next / previous paragraph |

**Autosave:** files write themselves ~1s after you stop changing them (like
VSCode `files.autoSave: afterDelay`). Configured in `lua/config/user.lua`.

**File path:** the **lualine statusline** shows the focused file's **absolute
path** (with a `●` modified flag). Configured in `lua/plugins/ui.lua` — change
`path = 2` to `1` (relative) or `4` (name only).

**Homepage:** launching `nvim` with no file opens the CJ-IDE start screen
(alpha-nvim) with quick actions. See `lua/plugins/dashboard.lua`.

> Note: `?` is remapped from reverse-search to the cheatsheet (reverse search is
> still `/` then `N`). It lives in `lua/config/help.lua` — delete the map there to
> get stock `?` back.

## Project layout

```
install.sh                 one-shot installer (tools via mise + config)
resync.sh                  re-copy config/nvim -> ~/.config/nvim (iterate on the config)
prune.sh                   uninstaller (reverses install.sh)
config/
├── mise/tools.txt         the tool manifest — ONE list install.sh & prune.sh read
└── nvim/                  the Neovim config (installed to ~/.config/nvim)
    ├── init.lua           entry point
    ├── lazy-lock.json     pinned plugin versions (reproducible installs)
    └── lua/
        ├── config/        options, keymaps, autocmds, lazy bootstrap, user.lua,
        │                  help (`?` cheatsheet)
        └── plugins/       one file per concern (ui, lsp, dashboard, terminal, …)
```

`config/nvim/` is the single source of truth — the installer copies it into
`~/.config/nvim`. After editing it, run **`./resync.sh`** to push the changes into
`~/.config/nvim` (mirroring adds/deletes) and restart nvim — no need to re-run
`install.sh`/`prune.sh`. `config/mise/tools.txt` is the single source for which tools
get installed; both scripts read it, so they can't drift apart.

## Reproducibility

- **Tools** are pinned in `config/mise/tools.txt` (Neovim to a major.minor; bump
  deliberately). Edit a version there and re-run `./install.sh`.
- **Plugins** are pinned in `config/nvim/lazy-lock.json`. For an exact match to a
  tested set, run `:Lazy restore` inside Neovim.
- `./install.sh --check` verifies every expected tool resolves on your `PATH`.

## Requirements & notes

- The installer pulls minimal build tools (git, curl, a C compiler) from your OS
  package manager; everything else comes from mise.
- For file-tree icons to render, use a [Nerd Font](https://www.nerdfonts.com)
  in your terminal (otherwise nvim-tree's icons show as missing glyphs).

## Contributing

Issues and PRs welcome — see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE) © Cristian Galvis
