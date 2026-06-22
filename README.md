# CJ-IDE

A custom, batteries-included **Neovim IDE** that installs in one command and is
ready to use — no manual plugin wrangling, no `mason`, no per-machine setup.

Everything (Neovim itself, language runtimes, LSP servers, formatters and a set
of handy TUIs) is installed **globally via [mise](https://mise.jdx.dev)** and
found on your `PATH`. The Neovim config is plain, readable Lua you can fork and
tweak. Free to use for whatever you want — see [LICENSE](LICENSE).

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
   file to confirm the LSP attaches and format-on-save works.

### Install options

| Flag | Effect |
|------|--------|
| `./install.sh` | Install everything and write the config |
| `./install.sh --backup` | Move an existing `~/.config/nvim` aside first |
| `./install.sh --no-tuis` | Skip the TUI tools |
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

- **tokyonight** theme + **lualine** statusline + **which-key** hints
- **nvim-treesitter** — syntax-aware highlighting & indentation
- **fzf-lua** — fuzzy finder (files, grep, symbols, diagnostics)
- **neo-tree** — file tree as a side panel docked on the right
- **gitsigns** — hunk signs, staging, blame
- **blink.cmp** — completion + signature help, fed by **schemastore** for JSON/YAML
- **nvim-lspconfig** — native LSP (`lua_ls`, `basedpyright`, `ruff`, `gopls`, `yamlls`, `jsonls`)
- **conform.nvim** — format-on-save (`ruff`, `gofumpt`/`goimports`, `prettier`)
- **toggleterm** — TUIs in floating terminals

**TUIs** (mapped under `<leader>T`): lazygit, lazydocker, lazysql, k9s,
lazyjournal.

## Keybindings

Leader is **Space**.

| Keys | Action |
|------|--------|
| `<leader>ff` / `fg` / `fb` | Find files / live grep / buffers |
| `<leader>fs` / `fd` / `fh` / `fr` | Symbols / diagnostics / help / resume |
| `<leader>e` | File tree (neo-tree, right panel) |
| `gd` / `gr` / `gi` / `K` | Definition / references / implementation / hover |
| `<leader>cr` / `ca` / `cf` | Rename / code action / format |
| `[d` / `]d` | Prev / next diagnostic |
| `]c` / `[c` | Next / prev git hunk |
| `<leader>gs` / `gr` / `gp` / `gb` | Stage / reset / preview hunk, blame line |
| `<leader>w` | Save |
| `<C-\>` | Toggle floating terminal |
| `<leader>Tg Td Tq Tk Tj` | lazygit, lazydocker, lazysql, k9s, lazyjournal |
| `<C-x>` (terminal) | Back to normal mode |

## Project layout

```
install.sh                 one-shot installer (tools via mise + config)
prune.sh                   uninstaller (reverses install.sh)
config/nvim/               the Neovim config (installed to ~/.config/nvim)
├── init.lua               entry point
└── lua/
    ├── config/            options, keymaps, autocmds, lazy bootstrap
    └── plugins/           one file per concern (ui, lsp, git, tuis, …)
```

The repo's `config/nvim/` is the single source of truth — the installer copies
it into `~/.config/nvim`. Edit there and re-run with `--backup` to update.

## Requirements & notes

- The installer pulls minimal build tools (git, curl, a C compiler) from your OS
  package manager; everything else comes from mise.
- Make sure `KUBECONFIG` is set so k9s works.
- For file-tree icons to render, use a [Nerd Font](https://www.nerdfonts.com)
  in your terminal (otherwise neo-tree's icons show as missing glyphs).

## Contributing

Issues and PRs welcome — see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE) © Cristian Galvis
