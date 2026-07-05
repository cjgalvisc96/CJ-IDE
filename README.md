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

**Base: [LazyVim](https://lazyvim.org)** — CJ-IDE is a thin layer on top of the
LazyVim distribution, which owns the plumbing (plugin defaults, LSP wiring,
treesitter, UI polish). CJ-IDE keeps its own keymaps, look and toolchain:

- **LazyVim core** — tokyonight theme, **lualine** statusline (shows the file's
  absolute path), **bufferline** tabs, **which-key** hints, **blink.cmp**
  completion + signature help, treesitter (`main` branch), gitsigns, flash,
  trouble, noice, snacks (dashboard shows the CJ-IDE banner)
- **fzf-lua** — fuzzy finder (files, grep, symbols, diagnostics) + LSP nav
  (LazyVim `editor.fzf` extra)
- **Language extras** — python (basedpyright + ruff), go, json/yaml (with
  schemastore), docker, markdown (render-markdown pretty view)
- **nvim-tree** — file tree side panel (kept over LazyVim's default explorer)
- **toggleterm** — floating terminal (`<C-\>`)
- **No mason** — LSP servers & formatters come from mise on your `PATH`
  (`config/mise/tools.txt`), same as always
- Format-on-save is **off** (CJ-IDE autosaves instead); format manually with
  `<leader>cf`

## Keybindings

Leader is **Space**. **Forgot a key? Press `?`** for the full cheatsheet

| Keys | Action |
|------|--------|
| `?` | Show the keybindings cheatsheet (`:CJHelp`) |
| `<leader>p` / `<leader>b` | Open file / switch buffer |
| `<leader>f` / `<leader>F` | Search current file / whole project |
| `<leader>e` | File tree (nvim-tree, left panel) |
| `gd` / `gr` | Definition / references |
| `gh` | Hover docs (`K` is paragraph-jump) |
| `gk` | Jump back (e.g. after `gd`) |
| `<leader>w` | Save |
| `<leader>u` | Update plugins (`:Lazy update`) |
| `<leader>Q` | Quit CJ-IDE |
| `<leader>n` / `<leader>s` | New file / split editor (vertical) |
| `<leader>←` / `<leader>→` | Prev / next split (wraps around; skips the tree) |
| `<leader>↑` / `<leader>↓` | Focus split above / below |
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
(snacks.dashboard) with quick actions. See `lua/plugins/dashboard.lua`.

**Keymap policy:** `lua/config/keymaps.lua` deletes any LazyVim map that
*extends* a CJ-IDE single-key binding (`<leader>ff`, `<leader>qq`, …) — a longer
map on the same prefix would make the single key pause for `timeoutlen`.
LazyVim maps on free prefixes (`<leader>c…` code actions, `<leader>l` Lazy,
`s` flash jump) are kept as bonuses.

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
        ├── config/        lazy bootstrap (LazyVim + extras), options, keymaps,
        │                  autocmds, user.lua (the VSCode-style keys),
        │                  help (`?` cheatsheet)
        └── plugins/       CJ-IDE overrides of LazyVim (core, lsp, ui,
                           dashboard, explorer, terminal, replace, …)
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
