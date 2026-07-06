#!/usr/bin/env bash
#
# prune.sh — completely remove CJ-IDE, reversing what install.sh did.
#
# By default this removes ONLY the Neovim side (safe, reversible-ish):
#   * ~/.config/nvim            (the CJ-IDE config)
#   * ~/.local/share/nvim       (plugins / lazy data)
#   * ~/.local/state/nvim       (undo, shada, swap)
#   * ~/.cache/nvim             (caches)
#   * the "Added by CJ-IDE" block in your shell rc
#
# Optional, heavier removals (mise is shared — other projects may rely on it):
#   --tools   also `mise unuse -g` every tool CJ-IDE installed, then prune them
#   --mise    also uninstall mise itself and its data (~/.local/share/mise, etc.)
#
# Usage:
#   ./prune.sh             remove the Neovim config + data (asks first)
#   ./prune.sh --backup    move ~/.config/nvim aside instead of deleting it
#   ./prune.sh --tools     also remove the mise-managed tools CJ-IDE installed
#   ./prune.sh --mise      also remove mise entirely (implies --tools)
#   ./prune.sh --dry-run   show what would happen, change nothing
#   ./prune.sh --yes       don't prompt for confirmation
#   ./prune.sh --help

set -euo pipefail

# --------------------------------------------------------------------------- #
DO_BACKUP=0
DO_TOOLS=0
DO_MISE=0
DRY_RUN=0
ASSUME_YES=0
REPO_URL="${CJ_IDE_REPO_URL:-https://github.com/cjgalvisc96/CJ-IDE.git}"

usage() {
  cat <<'EOF'
prune.sh — completely remove CJ-IDE, reversing what install.sh did.

Usage:
  ./prune.sh             remove the Neovim config + data (asks first)
  ./prune.sh --backup    move ~/.config/nvim aside instead of deleting it
  ./prune.sh --tools     also `mise unuse -g` the tools CJ-IDE installed
  ./prune.sh --mise      also uninstall mise entirely (implies --tools)
  ./prune.sh --dry-run   show what would happen, change nothing
  ./prune.sh --yes       don't prompt for confirmation
  ./prune.sh --help
EOF
}

for arg in "$@"; do
  case "$arg" in
    --backup)  DO_BACKUP=1 ;;
    --tools)   DO_TOOLS=1 ;;
    --mise)    DO_MISE=1; DO_TOOLS=1 ;;
    --dry-run) DRY_RUN=1 ;;
    --yes|-y)  ASSUME_YES=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown flag: $arg (try --help)" >&2; exit 1 ;;
  esac
done

# --- logging --------------------------------------------------------------- #
if [ -t 1 ]; then
  R=$'\033[0m'; B=$'\033[34m'; G=$'\033[32m'; Y=$'\033[33m'; E=$'\033[31m'; BD=$'\033[1m'
else R=""; B=""; G=""; Y=""; E=""; BD=""; fi
info(){ printf "%s==>%s %s\n" "$B" "$R" "$*"; }
ok(){   printf "%s ✓ %s %s\n" "$G" "$R" "$*"; }
warn(){ printf "%s ! %s %s\n" "$Y" "$R" "$*"; }
err(){  printf "%s ✗ %s %s\n" "$E" "$R" "$*" >&2; }
hr(){   printf "%s%s%s\n" "$BD" "------------------------------------------------------------" "$R"; }

# run <cmd...> — execute, or just print under --dry-run.
run() {
  if [ "$DRY_RUN" -eq 1 ]; then printf "%s[dry-run]%s %s\n" "$Y" "$R" "$*"; return 0; fi
  "$@"
}

confirm() {
  [ "$ASSUME_YES" -eq 1 ] && return 0
  [ "$DRY_RUN" -eq 1 ] && return 0
  local reply
  printf "%s%s%s [y/N] " "$BD" "$1" "$R"
  read -r reply || true
  case "$reply" in [yY]|[yY][eE][sS]) return 0 ;; *) return 1 ;; esac
}

# --- locate mise (may already be gone) ------------------------------------- #
MISE_BIN=""
find_mise() {
  if command -v mise >/dev/null 2>&1; then MISE_BIN="$(command -v mise)"
  elif [ -x "$HOME/.local/bin/mise" ]; then MISE_BIN="$HOME/.local/bin/mise"
  fi
}

# --- locate the tool manifest (the same one install.sh reads) -------------- #
# The list of tools lives ONLY in config/mise/tools.txt, so install and prune
# can never drift apart. Clone the repo if we were piped from the web.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd -P)" || SCRIPT_DIR=""
CLONE_TMP=""
cleanup_clone() { [ -n "$CLONE_TMP" ] && rm -rf "$CLONE_TMP"; return 0; }
trap cleanup_clone EXIT

manifest_path() {
  if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/config/mise/tools.txt" ]; then
    printf '%s\n' "$SCRIPT_DIR/config/mise/tools.txt"; return 0
  fi
  CLONE_TMP="$(mktemp -d)"
  if git clone --depth 1 "$REPO_URL" "$CLONE_TMP" >/dev/null 2>&1 \
     && [ -f "$CLONE_TMP/config/mise/tools.txt" ]; then
    printf '%s\n' "$CLONE_TMP/config/mise/tools.txt"; return 0
  fi
  return 1
}

# --- remove the Neovim config + runtime data ------------------------------- #
remove_nvim() {
  local cfg="$HOME/.config/nvim"
  if [ -d "$cfg" ]; then
    if [ "$DO_BACKUP" -eq 1 ]; then
      local dest; dest="$cfg.bak.$(date +%Y%m%d%H%M%S)"
      run mv "$cfg" "$dest" && ok "Backed up config -> $dest"
    else
      run rm -rf "$cfg" && ok "Removed $cfg"
    fi
  else
    info "No $cfg — nothing to remove"
  fi

  local d
  for d in "$HOME/.local/share/nvim" "$HOME/.local/state/nvim" "$HOME/.cache/nvim"; do
    if [ -d "$d" ]; then run rm -rf "$d" && ok "Removed $d"
    else info "No $d"; fi
  done
}

# --- strip the install.sh block from the shell rc -------------------------- #
remove_rc_block() {
  local rc shellname
  shellname="$(basename "${SHELL:-bash}")"
  case "$shellname" in
    zsh)  rc="$HOME/.zshrc" ;;
    fish) rc="$HOME/.config/fish/config.fish" ;;
    *)    rc="$HOME/.bashrc" ;;
  esac
  [ -f "$rc" ] || { info "No $rc"; return; }

  # Drop the flow-control line first (added independently of the mise block, so
  # it must be removed even when no mise block is present).
  if grep -qF 'CJ-IDE: free <C-s>' "$rc"; then
    if [ "$DRY_RUN" -eq 1 ]; then
      printf "%s[dry-run]%s strip flow-control line from %s\n" "$Y" "$R" "$rc"
    else
      local tmp_fc; tmp_fc="$(mktemp)"
      grep -vF 'CJ-IDE: free <C-s>' "$rc" > "$tmp_fc" && cat "$tmp_fc" > "$rc"
      rm -f "$tmp_fc"
      ok "Removed flow-control line from $rc"
    fi
  fi

  # Match the marker written by install.sh (current + legacy wording) and drop
  # the marker line plus the two lines it added (export PATH + mise activate).
  if ! grep -qE '# Added by (CJ-IDE|Neovim IDE) install\.sh' "$rc"; then
    info "No CJ-IDE block in $rc"
    return
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    printf "%s[dry-run]%s strip CJ-IDE block from %s\n" "$Y" "$R" "$rc"
    return
  fi

  local tmp; tmp="$(mktemp)"
  awk '
    /# Added by (CJ-IDE|Neovim IDE) install\.sh/ { skip = 3 }
    skip > 0 { skip--; next }
    { print }
  ' "$rc" > "$tmp"
  # Drop a trailing blank line left behind, then replace the file in place.
  cat "$tmp" > "$rc"
  rm -f "$tmp"
  ok "Removed CJ-IDE block from $rc (mise activation gone on next shell)"
}

# --- remove the mise-managed tools CJ-IDE installed ------------------------ #
remove_tools() {
  find_mise
  if [ -z "$MISE_BIN" ]; then warn "mise not found — skipping --tools"; return; fi
  local manifest
  if ! manifest="$(manifest_path)"; then
    err "Could not read tool manifest (config/mise/tools.txt) — skipping --tools"
    return
  fi
  info "Unregistering CJ-IDE tools from mise global config..."
  local spec name
  while IFS= read -r spec; do
    name="${spec%@*}" # strip @version: `mise unuse` matches on the tool name
    if run "$MISE_BIN" unuse -g "$name" >/dev/null 2>&1; then ok "unuse $name"
    else warn "could not unuse $name (maybe already gone)"; fi
  done < <(grep -vE '^[[:space:]]*(#|$)' "$manifest")
  info "Pruning unused tool versions..."
  run "$MISE_BIN" prune -y >/dev/null 2>&1 || warn "mise prune reported an issue"
  ok "Tools removed"
}

# --- remove mise itself ---------------------------------------------------- #
remove_mise() {
  find_mise
  info "Removing mise itself and its data..."
  local p
  for p in "$HOME/.local/bin/mise" \
           "$HOME/.local/share/mise" \
           "$HOME/.local/state/mise" \
           "$HOME/.config/mise" \
           "$HOME/.cache/mise"; do
    if [ -e "$p" ]; then run rm -rf "$p" && ok "Removed $p"; fi
  done
  warn "If mise was on your PATH via the rc block, it's gone after restarting your shell."
}

# --- run ------------------------------------------------------------------- #
main() {
  hr; info "CJ-IDE prune"; [ "$DRY_RUN" -eq 1 ] && warn "DRY RUN — nothing will change"; hr

  info "Will remove the Neovim config + data."
  [ "$DO_TOOLS" -eq 1 ] && warn "Will also remove the mise-managed tools CJ-IDE installed (shared with other projects)."
  [ "$DO_MISE"  -eq 1 ] && err  "Will also remove mise ENTIRELY — anything else using mise breaks."

  if ! confirm "Proceed?"; then warn "Aborted."; exit 0; fi

  remove_nvim
  remove_rc_block
  [ "$DO_TOOLS" -eq 1 ] && remove_tools
  [ "$DO_MISE"  -eq 1 ] && remove_mise

  hr; info "Summary"; hr
  ok "CJ-IDE removed."
  cat <<EOF

Notes:
  * Restart your shell so PATH/mise changes take effect:  exec \$SHELL
  * Kept by default (use the flags to remove): mise and its tools.
  * Backed-up configs (if you used --backup) live next to ~/.config/nvim.
EOF
}

main "$@"
