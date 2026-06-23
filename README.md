# CJ-IDE

A custom, batteries-included **Neovim IDE** that installs in one command and is
ready to use — no manual plugin wrangling, no `mason`, no per-machine setup.

Everything (Neovim itself, language runtimes, LSP servers and formatters) is
installed **globally via [mise](https://mise.jdx.dev)** and found on your
`PATH`. The Neovim config is plain, readable Lua you can fork and tweak. Free to
use for whatever you want — see [LICENSE](LICENSE).

> Works on Debian/Ubuntu, Fedora, Arch, RHEL/Rocky/Alma, openSUSE and macOS.

<!-- TODO: add a screenshot or asciinema GIF here — it sells the project. -->
<!-- ![CJ-IDE](docs/screenshot.png) -->

## Quick start

Clone and run (recommended — you can read the script first):

```bash
git clone https://github.com/cjgalvisc96/CJ-IDE.git
cd CJ-IDE
./install.sh
```

Or one-liner (downloads `install.sh`, which clones the repo for the config):

```bash
curl -fsSL https://raw.githubusercontent.com/cjgalvisc96/CJ-IDE/main/install.sh | bash
```

> **Heads up:** piping a script from the internet into `bash` runs it with your
> user's privileges. Prefer the clone-and-read method if you want to audit it
> first — it's short and commented.

Then:

1. Restart your shell (or `exec $SHELL`) so `mise` and its tools are on `PATH`.
2. Run `nvim`. Plugins install on first launch — let it finish.
3. Inside Neovim, run `:checkhealth` and open a `.py`/`.go`/`.yaml`/`.json`
   file to confirm the LSP attaches.

### Install options

| Flag | Effect |
|------|--------|
| `./install.sh` | Install everything and write the config |
| `./install.sh --backup` | Move an existing `~/.config/nvim` aside first |
| `./install.sh --check` | Verify the expected tools are on `PATH`, then exit |
| `./install.sh --help` | Show usage |

Environment override: `CJ_IDE_REPO_URL` (config source for `curl | bash`).

## Uninstall

`prune.sh` reverses what the installer did. By default it removes **only the
Neovim side** — the config, plugin/data/cache dirs, and the shell-rc block:

```bash
./prune.sh              # remove config + nvim data (asks first)
./prune.sh --dry-run    # show exactly what would be removed, change nothing
./prune.sh --backup     # move ~/.config/nvim aside instead of deleting it
```

The mise-managed tools are **kept by default** (other projects may use them).
To go further:

| Flag | Effect |
|------|--------|
| `--tools` | also `mise unuse -g` every tool CJ-IDE installed, then prune them |
| `--mise` | also uninstall mise entirely (implies `--tools`) — destructive |
| `--yes` | don't prompt for confirmation |

## What you get

**Languages out of the box:** Python, Go, YAML, JSON, Lua, Bash, Dockerfile,
Markdown.

**Plugins** (managed by [lazy.nvim](https://github.com/folke/lazy.nvim)):

- **alpha-nvim** — CJ-IDE start screen / homepage on launch
- **tokyonight** theme + **lualine** statusline (shows the file's absolute path) + **which-key** hints
- **nvim-treesitter** — syntax-aware highlighting & indentation
- **fzf-lua** — fuzzy finder (files, grep, symbols, diagnostics) + LSP nav
- **neo-tree** — file tree as a side panel docked on the left
- **blink.cmp** — completion + signature help, fed by **schemastore** for JSON/YAML
- **nvim-lspconfig** — native LSP (`lua_ls`, `basedpyright`, `ruff`, `gopls`, `yamlls`, `jsonls`)
- **toggleterm** — floating terminal (`<C-\>`)

> The lazygit/lazydocker/lazysql/k9s/lazyjournal launchers were removed — run
> those tools straight from your shell, outside the IDE.

## Keybindings

Leader is **Space**. **Forgot a key? Press `?`** for the full cheatsheet
(`:CJHelp`) — a floating panel listing every binding below.

| Keys | Action |
|------|--------|
| `?` | Show the keybindings cheatsheet (`:CJHelp`) |
| `<leader>p` / `<leader>b` | Open file / switch buffer |
| `<leader>f` / `<leader>F` | Search current file / whole project |
| `<leader>e` | File tree (neo-tree, left panel) |
| `gd` / `gr` | Definition / references |
| `gk` | Jump back (e.g. after `gd`) |
| `<leader>cd` | Line diagnostics (float) |
| `<leader>cr` / `ca` | Rename / code action |
| `[d` / `]d` | Prev / next diagnostic |
| `<leader>w` | Save |
| `<leader>u` | Update plugins (`:Lazy update`) |
| `<C-\>` | Toggle floating terminal |
| `<C-x>` (terminal) | Back to normal mode |

### VSCode-style keys

CJ-IDE ships a **VSCode/VSCodeVim-flavored** keymap in `lua/config/user.lua`
(loaded last, so it's the default). Highlights:

| Keys | Action |
|------|--------|
| `<leader>p` / `<leader>f` | Quick-open file / find in files |
| `<leader>b` | Switch buffer (fuzzy) |
| `<leader>q` / `<leader>x` | Close buffer / smart-close panel·split·buffer |
| `<leader>Q` | Quit CJ-IDE |
| `<leader>n` / `<leader>s` | New file / split editor (vertical) |
| `<leader>←` / `<leader>→` | Focus split left / right |
| `<leader>t` | New terminal |
| `<leader>m` | Toggle comment (normal + visual) |
| `<leader>j` / `<leader>k` | Move line/selection down / up |
| `f` `F` `fa` `fu` | Fold / unfold (recursive / all) |
| `J` / `K` | Next / previous paragraph |

> These intentionally remap some core Vim keys (`f`, `J`, `K`, `dw`/`df`/`yf`…)
> to match VSCode muscle memory. Edit `lua/config/user.lua` to change or remove
> any of them — it's the one file meant for personal taste.

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
  in your terminal (otherwise neo-tree's icons show as missing glyphs).

## Contributing

Issues and PRs welcome — see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE) © Cristian Galvis
