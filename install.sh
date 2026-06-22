#!/usr/bin/env bash
#
# install.sh — one-shot setup for a custom Neovim IDE.
#
# Uses mise (https://mise.jdx.dev) to install almost everything GLOBALLY:
#   Neovim, Node/Go/Python, ripgrep/fd/fzf, the TUIs (lazygit, lazydocker,
#   lazysql, lazyssh, k9s, lazyjournal, claws), and all LSP servers/formatters.
# Only build tools (git/curl/compiler) come from the OS package manager.
# Then it writes a ready-to-use ~/.config/nvim/init.lua.
#
# Works on: Debian/Ubuntu, Fedora, Arch, RHEL/Rocky/Alma, macOS.
#
# Usage:
#   ./install.sh            install everything + write config
#   ./install.sh --backup   move an existing ~/.config/nvim aside first
#   ./install.sh --no-tuis  skip the TUI tools
#   ./install.sh --help
#
# Idempotent: re-running skips what's already installed. After it finishes,
# restart your shell and run `nvim`.

set -euo pipefail

# --------------------------------------------------------------------------- #
DO_BACKUP=0
DO_TUIS=1
LAZYSSH_GO_PKG="${LAZYSSH_GO_PKG:-github.com/Adembc/lazyssh@latest}"  # override if needed

for arg in "$@"; do
  case "$arg" in
    --backup)  DO_BACKUP=1 ;;
    --no-tuis) DO_TUIS=0 ;;
    -h|--help) sed -n '2,28p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown flag: $arg (try --help)"; exit 1 ;;
  esac
done

INSTALLED=(); FAILED=()

# --- logging --------------------------------------------------------------- #
if [ -t 1 ]; then
  R=$'\033[0m'; B=$'\033[34m'; G=$'\033[32m'; Y=$'\033[33m'; E=$'\033[31m'; BD=$'\033[1m'
else R=""; B=""; G=""; Y=""; E=""; BD=""; fi
info(){ printf "%s==>%s %s\n" "$B" "$R" "$*"; }
ok(){   printf "%s ✓ %s %s\n" "$G" "$R" "$*"; }
warn(){ printf "%s ! %s %s\n" "$Y" "$R" "$*"; }
err(){  printf "%s ✗ %s %s\n" "$E" "$R" "$*"; }
hr(){   printf "%s%s%s\n" "$BD" "------------------------------------------------------------" "$R"; }

# --- detect OS / package manager ------------------------------------------- #
OS="$(uname -s)"; PM=""; SUDO=""
[ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1 && SUDO="sudo"

detect_pm() {
  if [ "$OS" = "Darwin" ]; then PM="mac"
  elif command -v apt-get >/dev/null 2>&1; then PM="apt"
  elif command -v dnf     >/dev/null 2>&1; then PM="dnf"
  elif command -v pacman  >/dev/null 2>&1; then PM="pacman"
  elif command -v zypper  >/dev/null 2>&1; then PM="zypper"
  else err "No supported package manager (apt/dnf/pacman/zypper) or macOS."; exit 1; fi
  info "OS=$OS  package-manager=$PM"
}

# --- minimal system build tools (compiler/git/curl) ------------------------ #
install_build_tools() {
  info "Installing minimal build tools (git, curl, compiler)..."
  case "$PM" in
    mac)    xcode-select --install 2>/dev/null || true ;;
    apt)    $SUDO apt-get update -y && $SUDO apt-get install -y git curl build-essential unzip ca-certificates ;;
    dnf)    $SUDO dnf install -y git curl gcc gcc-c++ make unzip ca-certificates ;;
    pacman) $SUDO pacman -Sy --needed --noconfirm git curl base-devel unzip ca-certificates ;;
    zypper) $SUDO zypper install -y git curl gcc gcc-c++ make unzip ca-certificates ;;
  esac
  ok "Build tools done"
}

# --- mise ------------------------------------------------------------------ #
MISE_BIN=""
install_mise() {
  if command -v mise >/dev/null 2>&1; then MISE_BIN="$(command -v mise)"
  elif [ -x "$HOME/.local/bin/mise" ]; then MISE_BIN="$HOME/.local/bin/mise"
  else
    info "Installing mise..."
    curl -fsSL https://mise.run | sh
    MISE_BIN="$HOME/.local/bin/mise"
  fi
  ok "mise: $("$MISE_BIN" --version 2>/dev/null || echo present)"
  # Make mise shims usable within this script run.
  export PATH="$HOME/.local/bin:$("$MISE_BIN" where ripgrep >/dev/null 2>&1; echo "$HOME/.local/share/mise/shims"):$PATH"
  export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH"
}

mise_use() {
  # mise_use <tool-spec>
  local spec="$1"
  info "  mise use -g $spec"
  if "$MISE_BIN" use -g "$spec" >/dev/null 2>&1; then INSTALLED+=("$spec"); ok "$spec"
  else FAILED+=("$spec"); warn "could not install: $spec"; fi
}

install_runtimes() {
  info "Installing runtimes via mise (node, go, python, neovim)..."
  mise_use "node@lts"
  mise_use "go@latest"
  mise_use "python@latest"
  mise_use "neovim@latest"
  "$MISE_BIN" reshim >/dev/null 2>&1 || true
}

install_cli_tools() {
  info "Installing CLI tools via mise (ripgrep, fd, fzf)..."
  mise_use "ripgrep@latest"
  mise_use "fd@latest"
  mise_use "fzf@latest"
}

install_lsp_and_formatters() {
  info "Installing LSP servers + formatters via mise..."
  # Static binaries / registry
  mise_use "ruff@latest"                 # python lint + format
  mise_use "lua-language-server@latest"
  # Go backend (needs go, installed above)
  mise_use "go:golang.org/x/tools/gopls@latest"
  mise_use "go:mvdan.cc/gofumpt@latest"
  mise_use "go:golang.org/x/tools/cmd/goimports@latest"
  # npm backend (needs node, installed above)
  mise_use "npm:basedpyright@latest"                 # python types -> basedpyright-langserver
  mise_use "npm:yaml-language-server@latest"
  mise_use "npm:vscode-langservers-extracted@latest" # provides vscode-json-language-server
  mise_use "npm:prettier@latest"                     # yaml/json formatting
  "$MISE_BIN" reshim >/dev/null 2>&1 || true
}

install_tuis() {
  [ "$DO_TUIS" -eq 0 ] && { info "Skipping TUIs (--no-tuis)"; return; }
  info "Installing TUIs via mise..."
  mise_use "lazygit@latest"
  mise_use "lazydocker@latest"
  mise_use "k9s@latest"
  mise_use "go:github.com/jorgerojas26/lazysql@latest"
  mise_use "go:github.com/Lifailon/lazyjournal@latest"
  mise_use "go:github.com/clawscli/claws/cmd/claws@latest"
  mise_use "go:${LAZYSSH_GO_PKG}"
  "$MISE_BIN" reshim >/dev/null 2>&1 || true
}

# --- shell rc: activate mise ----------------------------------------------- #
ensure_shell_rc() {
  local rc shellname line
  shellname="$(basename "${SHELL:-bash}")"
  case "$shellname" in
    zsh)  rc="$HOME/.zshrc";  line='eval "$(mise activate zsh)"' ;;
    fish) rc="$HOME/.config/fish/config.fish"; line='mise activate fish | source' ;;
    *)    rc="$HOME/.bashrc"; line='eval "$(mise activate bash)"' ;;
  esac
  mkdir -p "$(dirname "$rc")"; touch "$rc"
  grep -qF 'mise activate' "$rc" || {
    printf '\n# Added by Neovim IDE install.sh\nexport PATH="$HOME/.local/bin:$PATH"\n%s\n' "$line" >> "$rc"
    ok "Enabled mise in $rc (restart your shell)"
  }
}

# --- write the Neovim config ----------------------------------------------- #
write_config() {
  local cfg="$HOME/.config/nvim"
  if [ -d "$cfg" ] && [ -n "$(ls -A "$cfg" 2>/dev/null)" ]; then
    if [ "$DO_BACKUP" -eq 1 ]; then
      local dest="$cfg.bak.$(date +%Y%m%d%H%M%S)"; mv "$cfg" "$dest"; ok "Backed up old config -> $dest"
    else
      warn "Existing $cfg found — not overwriting (re-run with --backup to replace). Skipping config."
      return
    fi
  fi
  mkdir -p "$cfg"
  cat > "$cfg/init.lua" <<'LUA'
-- ~/.config/nvim/init.lua  — custom IDE (generated by install.sh)
-- LSP servers, formatters and TUIs are installed globally via mise and
-- found on your PATH. No mason needed.

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local o = vim.opt
o.number = true
o.relativenumber = true
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.smartindent = true
o.ignorecase = true
o.smartcase = true
o.splitright = true
o.splitbelow = true
o.undofile = true
o.signcolumn = "yes"
o.termguicolors = true
o.cursorline = true
o.scrolloff = 6
o.updatetime = 250
o.clipboard = "unnamedplus"
o.completeopt = "menu,menuone,noselect"

vim.diagnostic.config({
  severity_sort = true,
  virtual_text = { prefix = "●" },
  float = { border = "rounded", source = "if_many" },
})

-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- theme
  { "folke/tokyonight.nvim", priority = 1000,
    config = function() vim.cmd.colorscheme("tokyonight-night") end },

  -- statusline
  { "nvim-lualine/lualine.nvim", event = "VeryLazy",
    opts = { options = { theme = "tokyonight", globalstatus = true } } },

  -- keymap hints
  { "folke/which-key.nvim", event = "VeryLazy", opts = {} },

  -- treesitter (pin master: classic .configs API)
  { "nvim-treesitter/nvim-treesitter", branch = "master", build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "python", "go", "gomod", "gosum", "yaml", "json",
          "jsonc", "lua", "bash", "markdown", "markdown_inline", "dockerfile",
          "vim", "vimdoc" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end },

  -- fuzzy finder (fzf)
  { "ibhagwan/fzf-lua", cmd = "FzfLua", opts = {},
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<cr>",               desc = "Find files" },
      { "<leader>fg", "<cmd>FzfLua live_grep<cr>",           desc = "Live grep" },
      { "<leader>fb", "<cmd>FzfLua buffers<cr>",             desc = "Buffers" },
      { "<leader>fh", "<cmd>FzfLua helptags<cr>",            desc = "Help" },
      { "<leader>fr", "<cmd>FzfLua resume<cr>",              desc = "Resume" },
      { "<leader>fd", "<cmd>FzfLua diagnostics_document<cr>",desc = "Diagnostics" },
      { "<leader>fs", "<cmd>FzfLua lsp_document_symbols<cr>",desc = "Symbols" },
    } },

  -- file explorer
  { "stevearc/oil.nvim", lazy = false, opts = {},
    keys = { { "<leader>e", "<cmd>Oil<cr>", desc = "Explorer" } } },

  -- git
  { "lewis6991/gitsigns.nvim", event = { "BufReadPre", "BufNewFile" },
    opts = {
      on_attach = function(buf)
        local gs = require("gitsigns")
        local function m(l, r, d) vim.keymap.set("n", l, r, { buffer = buf, desc = d }) end
        m("]c", gs.next_hunk, "Next hunk")
        m("[c", gs.prev_hunk, "Prev hunk")
        m("<leader>gs", gs.stage_hunk, "Stage hunk")
        m("<leader>gr", gs.reset_hunk, "Reset hunk")
        m("<leader>gp", gs.preview_hunk, "Preview hunk")
        m("<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
      end,
    } },

  -- completion
  { "saghen/blink.cmp", version = "1.*", event = "InsertEnter",
    opts = {
      keymap = { preset = "default" },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      signature = { enabled = true },
    } },

  -- json/yaml schemas
  { "b0o/schemastore.nvim", lazy = true },

  -- LSP (native; binaries come from mise on your PATH)
  { "neovim/nvim-lspconfig", event = { "BufReadPre", "BufNewFile" },
    dependencies = { "saghen/blink.cmp", "b0o/schemastore.nvim" },
    config = function()
      vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

      vim.lsp.config("lua_ls", {
        settings = { Lua = { diagnostics = { globals = { "vim" } } } } })
      vim.lsp.config("basedpyright", {
        settings = { basedpyright = { analysis = { typeCheckingMode = "standard" } } } })
      vim.lsp.config("gopls", {
        settings = { gopls = { analyses = { unusedparams = true }, staticcheck = true,
          hints = { parameterNames = true, assignVariableTypes = true } } } })
      vim.lsp.config("yamlls", {
        settings = { yaml = { schemaStore = { enable = false, url = "" },
          schemas = require("schemastore").yaml.schemas() } } })
      vim.lsp.config("jsonls", {
        settings = { json = { schemas = require("schemastore").json.schemas(),
          validate = { enable = true } } } })

      vim.lsp.enable({ "lua_ls", "basedpyright", "ruff", "gopls", "yamlls", "jsonls" })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local b = ev.buf
          local function m(l, fn, d) vim.keymap.set("n", l, fn, { buffer = b, desc = d }) end
          m("gd", vim.lsp.buf.definition, "Definition")
          m("gr", vim.lsp.buf.references, "References")
          m("gi", vim.lsp.buf.implementation, "Implementation")
          m("K",  vim.lsp.buf.hover, "Hover")
          m("<leader>cr", vim.lsp.buf.rename, "Rename")
          m("<leader>ca", vim.lsp.buf.code_action, "Code action")
          m("[d", function() vim.diagnostic.jump({ count = -1 }) end, "Prev diagnostic")
          m("]d", function() vim.diagnostic.jump({ count = 1 })  end, "Next diagnostic")
        end,
      })
    end },

  -- formatting
  { "stevearc/conform.nvim", event = "BufWritePre",
    keys = { { "<leader>cf",
      function() require("conform").format({ lsp_format = "fallback" }) end, desc = "Format" } },
    opts = {
      format_on_save = { timeout_ms = 1500, lsp_format = "fallback" },
      formatters_by_ft = {
        python = { "ruff_format" },
        go = { "goimports", "gofumpt" },
        yaml = { "prettier" },
        json = { "prettier" },
      },
    } },

  -- TUIs in floating terminals
  { "akinsho/toggleterm.nvim", version = "*", event = "VeryLazy",
    config = function()
      require("toggleterm").setup({ open_mapping = [[<c-\>]], direction = "float",
        float_opts = { border = "curved" } })
      local Terminal = require("toggleterm.terminal").Terminal
      local cache = {}
      local function tui(cmd)
        return function()
          cache[cmd] = cache[cmd] or Terminal:new({ cmd = cmd, direction = "float",
            float_opts = { border = "curved" }, hidden = true,
            on_open = function() vim.cmd("startinsert!") end })
          cache[cmd]:toggle()
        end
      end
      local map = vim.keymap.set
      map("n", "<leader>Tg", tui("lazygit"),     { desc = "Lazygit" })
      map("n", "<leader>Td", tui("lazydocker"),  { desc = "Lazydocker" })
      map("n", "<leader>Tq", tui("lazysql"),     { desc = "LazySQL" })
      map("n", "<leader>Th", tui("lazyssh"),     { desc = "LazySSH" })
      map("n", "<leader>Tk", tui("k9s"),         { desc = "k9s" })
      map("n", "<leader>Tj", tui("lazyjournal"), { desc = "lazyjournal" })
      map("n", "<leader>Ta", tui("claws"),       { desc = "claws (AWS)" })
    end },
}, { change_detection = { notify = false } })

-- global niceties
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search" })
vim.keymap.set("t", "<C-x>", [[<C-\><C-n>]], { desc = "Terminal: normal mode" })

-- filetype indents
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "yaml", "json", "jsonc", "lua" },
  callback = function() vim.bo.shiftwidth = 2; vim.bo.tabstop = 2 end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go" },
  callback = function() vim.bo.expandtab = false end, -- Go uses tabs
})
LUA
  ok "Wrote $cfg/init.lua"
}

# --- run ------------------------------------------------------------------- #
main() {
  hr; info "Neovim IDE bootstrap (mise-powered)"; hr
  detect_pm
  install_build_tools
  install_mise
  install_runtimes
  install_cli_tools
  install_lsp_and_formatters
  install_tuis
  ensure_shell_rc
  write_config

  hr; info "Summary"; hr
  [ "${#INSTALLED[@]}" -gt 0 ] && ok "Installed: ${INSTALLED[*]}"
  [ "${#FAILED[@]}"    -gt 0 ] && err "Needs attention: ${FAILED[*]}"
  cat <<EOF

Done. Next:
  1) Restart your shell (or:  exec \$SHELL)  so mise + its tools are on PATH.
  2) Run:  nvim     — plugins install on first launch; wait for it to finish.
  3) Inside nvim:  :checkhealth   and open a .py/.go/.yaml/.json file to
     confirm the LSP attaches and formatting-on-save works.

Keys:  <leader> is Space.
  <leader>f*  find (files/grep/buffers/symbols/diagnostics)   <leader>e  explorer
  <leader>g*  git hunks/blame      <leader>c{a,r,f}  code action/rename/format
  <leader>T*  TUIs -> Tg lazygit  Td lazydocker  Tq lazysql  Th lazyssh
              Tk k9s  Tj lazyjournal  Ta claws

Notes:
  * Make sure KUBECONFIG / AWS creds / ~/.ssh are set in your shell so k9s,
    claws and lazyssh work.
  * lazyssh has several implementations; if it failed, set the module and rerun:
      LAZYSSH_GO_PKG=github.com/you/yourssh@latest ./install.sh --no-tuis
EOF
}

main "$@"