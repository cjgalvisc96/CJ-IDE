#!/usr/bin/env bash
#
# install.sh — one-shot setup for CJ-IDE, a custom Neovim IDE.
#
# Uses mise (https://mise.jdx.dev) to install almost everything GLOBALLY:
#   Neovim, Node/Go/Python, ripgrep/fd/fzf, the TUIs (lazygit, lazydocker,
#   lazysql, lazyssh, k9s, lazyjournal, claws), and all LSP servers/formatters.
# Only build tools (git/curl/compiler) come from the OS package manager.
# Then it installs the Neovim config from this repo's config/nvim/ into
# ~/.config/nvim (cloning the repo first if you ran it via `curl | bash`).
#
# Works on: Debian/Ubuntu, Fedora, Arch, RHEL/Rocky/Alma, openSUSE, macOS.
#
# Idempotent: re-running skips what's already installed. After it finishes,
# restart your shell and run `nvim`.

set -euo pipefail

# --------------------------------------------------------------------------- #
REPO_URL="${CJ_IDE_REPO_URL:-https://github.com/cjgalvisc96/CJ-IDE.git}"
DO_BACKUP=0
DO_TUIS=1
LAZYSSH_GO_PKG="${LAZYSSH_GO_PKG:-github.com/Adembc/lazyssh@latest}"  # override if needed

usage() {
  cat <<'EOF'
install.sh — one-shot setup for CJ-IDE, a custom Neovim IDE.

Usage:
  ./install.sh            install everything + write config
  ./install.sh --backup   move an existing ~/.config/nvim aside first
  ./install.sh --no-tuis  skip the TUI tools
  ./install.sh --help

Environment overrides:
  CJ_IDE_REPO_URL   git URL to clone config from when run via curl | bash
  LAZYSSH_GO_PKG    Go module path for lazyssh
EOF
}

for arg in "$@"; do
  case "$arg" in
    --backup)  DO_BACKUP=1 ;;
    --no-tuis) DO_TUIS=0 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown flag: $arg (try --help)" >&2; exit 1 ;;
  esac
done

INSTALLED=(); FAILED=()

# Directory this script lives in (empty/unreliable when piped via curl | bash).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd -P)" || SCRIPT_DIR=""

# --- logging --------------------------------------------------------------- #
if [ -t 1 ]; then
  R=$'\033[0m'; B=$'\033[34m'; G=$'\033[32m'; Y=$'\033[33m'; E=$'\033[31m'; BD=$'\033[1m'
else R=""; B=""; G=""; Y=""; E=""; BD=""; fi
info(){ printf "%s==>%s %s\n" "$B" "$R" "$*"; }
ok(){   printf "%s ✓ %s %s\n" "$G" "$R" "$*"; }
warn(){ printf "%s ! %s %s\n" "$Y" "$R" "$*"; }
err(){  printf "%s ✗ %s %s\n" "$E" "$R" "$*" >&2; }
hr(){   printf "%s%s%s\n" "$BD" "------------------------------------------------------------" "$R"; }

# --- detect OS / package manager ------------------------------------------- #
OS="$(uname -s)"; PM=""; SUDO=""
if [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1; then SUDO="sudo"; fi

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
    mac)
      if ! xcode-select -p >/dev/null 2>&1; then
        xcode-select --install 2>/dev/null || true
        warn "Command Line Tools install was triggered in a separate window."
        warn "Finish that GUI install, then re-run this script if compilation fails."
      fi
      ;;
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
  if [ "$DO_TUIS" -eq 0 ]; then info "Skipping TUIs (--no-tuis)"; return; fi
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
  # The activation lines below are written verbatim to the rc file, so they
  # must stay single-quoted (shell expands them at shell startup, not now).
  # shellcheck disable=SC2016
  case "$shellname" in
    zsh)  rc="$HOME/.zshrc";  line='eval "$(mise activate zsh)"' ;;
    fish) rc="$HOME/.config/fish/config.fish"; line='mise activate fish | source' ;;
    *)    rc="$HOME/.bashrc"; line='eval "$(mise activate bash)"' ;;
  esac
  mkdir -p "$(dirname "$rc")"; touch "$rc"
  if ! grep -qF 'mise activate' "$rc"; then
    # shellcheck disable=SC2016
    printf '\n# Added by CJ-IDE install.sh\nexport PATH="$HOME/.local/bin:$PATH"\n%s\n' "$line" >> "$rc"
    ok "Enabled mise in $rc (restart your shell)"
  fi
}

# --- locate the config/nvim shipped with this repo ------------------------- #
CLONE_TMP=""
cleanup() { [ -n "$CLONE_TMP" ] && rm -rf "$CLONE_TMP"; }
trap cleanup EXIT

config_source() {
  # Echo a path to a config/nvim directory, cloning the repo if needed.
  if [ -n "$SCRIPT_DIR" ] && [ -d "$SCRIPT_DIR/config/nvim" ]; then
    printf '%s\n' "$SCRIPT_DIR/config/nvim"; return
  fi
  info "config/nvim not found locally — cloning $REPO_URL ..." >&2
  CLONE_TMP="$(mktemp -d)"
  if git clone --depth 1 "$REPO_URL" "$CLONE_TMP" >/dev/null 2>&1 \
     && [ -d "$CLONE_TMP/config/nvim" ]; then
    printf '%s\n' "$CLONE_TMP/config/nvim"; return
  fi
  err "Could not obtain config/nvim (clone failed or directory missing)."
  return 1
}

# --- install the Neovim config --------------------------------------------- #
write_config() {
  local cfg="$HOME/.config/nvim" src
  if ! src="$(config_source)"; then
    FAILED+=("nvim-config"); return
  fi

  if [ -d "$cfg" ] && [ -n "$(ls -A "$cfg" 2>/dev/null)" ]; then
    if [ "$DO_BACKUP" -eq 1 ]; then
      local dest; dest="$cfg.bak.$(date +%Y%m%d%H%M%S)"
      mv "$cfg" "$dest"; ok "Backed up old config -> $dest"
    else
      warn "Existing $cfg found — not overwriting (re-run with --backup to replace). Skipping config."
      return
    fi
  fi

  mkdir -p "$cfg"
  # Copy contents of config/nvim/ into ~/.config/nvim/ (note the trailing /.).
  cp -R "$src/." "$cfg/"
  ok "Installed config -> $cfg"
}

# --- run ------------------------------------------------------------------- #
main() {
  hr; info "CJ-IDE bootstrap (mise-powered)"; hr
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
