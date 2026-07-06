#!/usr/bin/env bash
#
# install.sh — one-shot setup for CJ-IDE, a custom Neovim IDE.
#
# Uses mise (https://mise.jdx.dev) to install almost everything GLOBALLY:
#   Neovim, Node/Go/Python, ripgrep/fd/fzf, and all LSP servers.
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
DO_CHECK=0

usage() {
  cat <<'EOF'
install.sh — one-shot setup for CJ-IDE, a custom Neovim IDE.

Usage:
  ./install.sh            install everything + write config
  ./install.sh --backup   move an existing ~/.config/nvim aside first
  ./install.sh --check    verify the expected tools are on PATH, then exit
  ./install.sh --help

Environment overrides:
  CJ_IDE_REPO_URL   git URL to clone config from when run via curl | bash
EOF
}

for arg in "$@"; do
  case "$arg" in
    --backup)  DO_BACKUP=1 ;;
    --check)   DO_CHECK=1 ;;
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

# --- clipboard tool (so `clipboard=unnamedplus` actually works) ------------ #
install_clipboard() {
  # macOS ships pbcopy/pbpaste; nothing to do.
  [ "$PM" = "mac" ] && return 0
  info "Installing clipboard tool (wl-clipboard for Wayland, xclip for X11)..."
  case "$PM" in
    apt)    $SUDO apt-get install -y wl-clipboard xclip || true ;;
    dnf)    $SUDO dnf install -y wl-clipboard xclip || true ;;
    pacman) $SUDO pacman -S --needed --noconfirm wl-clipboard xclip || true ;;
    zypper) $SUDO zypper install -y wl-clipboard xclip || true ;;
  esac
  ok "Clipboard tool done"
}

# --- ImageMagick (snacks.image renders images inline; magick converts) ------ #
install_imagemagick() {
  if command -v magick >/dev/null 2>&1 || command -v convert >/dev/null 2>&1; then
    ok "ImageMagick present"; return 0
  fi
  info "Installing ImageMagick (inline image rendering in Neovim)..."
  case "$PM" in
    mac)
      if command -v brew >/dev/null 2>&1; then brew install imagemagick || true
      else warn "No Homebrew — install ImageMagick manually for image rendering."; fi
      ;;
    apt)    $SUDO apt-get install -y imagemagick || true ;;
    dnf)    $SUDO dnf install -y ImageMagick || true ;;
    pacman) $SUDO pacman -S --needed --noconfirm imagemagick || true ;;
    zypper) $SUDO zypper install -y ImageMagick || true ;;
  esac
  ok "ImageMagick done"
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

# Print the tool specs listed under "# [<section>]" in the manifest, skipping
# blanks/comments. (index() keeps the bracketed header a literal, not a regex.)
specs_in_section() {
  # specs_in_section <manifest-file> <section>
  awk -v sec="[$2]" '
    /^[[:space:]]*#[[:space:]]*\[/ { inseg = (index($0, sec) > 0); next }
    inseg && NF && $0 !~ /^[[:space:]]*#/ { print }
  ' "$1"
}

install_section() {
  # install_section <section> <human label>
  local section="$1" label="$2" spec
  info "Installing $label via mise..."
  while IFS= read -r spec; do
    [ -n "$spec" ] && mise_use "$spec"
  done < <(specs_in_section "$TOOLS_FILE" "$section")
  "$MISE_BIN" reshim >/dev/null 2>&1 || true
}

install_tools() {
  # Runtimes first so the go:/npm: backends below can build against them.
  install_section runtimes "runtimes (node, go, python, neovim)"
  install_section cli      "CLI tools (ripgrep, fd, fzf, tree-sitter)"
  install_section lsp      "LSP servers"
  install_section dap      "debug adapters (debugpy for Python)"
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
  # Free <C-s>/<C-q> for Neovim: terminals swallow them as legacy flow control
  # (XOFF/XON), so CJ-IDE's <C-s> "plain file" toggle never reaches nvim.
  # Disable it for interactive shells. Skip fish (different syntax; it manages
  # flow control itself). Marked so prune.sh can remove exactly this line.
  if [ "$shellname" != "fish" ] && ! grep -qF 'CJ-IDE: free <C-s>' "$rc"; then
    printf '[ -t 0 ] && stty -ixon 2>/dev/null  # CJ-IDE: free <C-s>/<C-q> for Neovim\n' >> "$rc"
    ok "Disabled terminal flow control in $rc (frees <C-s>)"
  fi
}

# --- locate this repo's files (clone if run via curl | bash) --------------- #
CLONE_TMP=""
ROOT=""        # repo root once resolved
TOOLS_FILE=""  # $ROOT/config/mise/tools.txt
cleanup() { [ -n "$CLONE_TMP" ] && rm -rf "$CLONE_TMP"; return 0; }
trap cleanup EXIT

resolve_repo_root() {
  # Set ROOT to a directory containing config/nvim + config/mise, cloning if
  # the script was piped from the web and the files aren't on disk.
  if [ -n "$SCRIPT_DIR" ] && [ -d "$SCRIPT_DIR/config/nvim" ]; then
    ROOT="$SCRIPT_DIR"
  else
    info "Repo files not found locally — cloning $REPO_URL ..."
    CLONE_TMP="$(mktemp -d)"
    if git clone --depth 1 "$REPO_URL" "$CLONE_TMP" >/dev/null 2>&1 \
       && [ -d "$CLONE_TMP/config/nvim" ]; then
      ROOT="$CLONE_TMP"
    else
      err "Could not obtain repo files (clone failed or directory missing)."
      exit 1
    fi
  fi
  TOOLS_FILE="$ROOT/config/mise/tools.txt"
  [ -f "$TOOLS_FILE" ] || { err "Missing tool manifest: $TOOLS_FILE"; exit 1; }
}

# --- install the Neovim config --------------------------------------------- #
write_config() {
  local cfg="$HOME/.config/nvim" src="$ROOT/config/nvim"

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

# --- doctor: verify the expected tools resolve on PATH --------------------- #
# Binary names (not mise specs) — several differ from their package name.
EXPECTED_BINS=(
  nvim node go python rg fd fzf tree-sitter
  ruff lua-language-server gopls gofumpt goimports
  basedpyright-langserver yaml-language-server vscode-json-language-server prettier
  debugpy-adapter
)
doctor() {
  export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH"
  info "Checking expected tools on PATH..."
  local missing=0 b
  for b in "${EXPECTED_BINS[@]}"; do
    if command -v "$b" >/dev/null 2>&1; then ok "$b"
    else warn "missing: $b"; missing=$((missing + 1)); fi
  done
  if [ "$missing" -eq 0 ]; then ok "All expected tools found."
  else warn "$missing tool(s) missing — re-run ./install.sh, or check mise."; fi
  return 0
}

# --- run ------------------------------------------------------------------- #
main() {
  if [ "$DO_CHECK" -eq 1 ]; then
    hr; info "CJ-IDE doctor"; hr
    doctor
    exit 0
  fi

  hr; info "CJ-IDE bootstrap (mise-powered)"; hr
  detect_pm
  resolve_repo_root
  install_build_tools
  install_clipboard
  install_imagemagick
  install_mise
  install_tools
  ensure_shell_rc
  write_config
  doctor

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
  <leader>p  open file    <leader>F  search project    <leader>e  explorer
  Press  ?  (or :CJHelp) inside nvim for the full cheatsheet.
EOF
}

main "$@"
