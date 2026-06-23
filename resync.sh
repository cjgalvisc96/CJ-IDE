#!/usr/bin/env bash
#
# resync.sh — push this repo's config/nvim into ~/.config/nvim, fast.
#
# For iterating on the Lua config: edit here → `./resync.sh` → restart nvim.
# Unlike install.sh (which SKIPS an existing ~/.config/nvim), this mirrors the
# repo over it — new files are copied, deleted files are removed. It does NOT
# touch mise tools or installed plugins; those live elsewhere and a plain
# `nvim` launch will install any new plugin via lazy.
#
# Usage:
#   ./resync.sh            mirror config/nvim -> ~/.config/nvim
#   ./resync.sh --backup   copy the current ~/.config/nvim aside first
#   ./resync.sh --help

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd -P)"
SRC="$SCRIPT_DIR/config/nvim"
DEST="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

# --- logging (same palette as install.sh) ---------------------------------- #
if [ -t 1 ]; then
  R=$'\033[0m'; B=$'\033[34m'; G=$'\033[32m'; Y=$'\033[33m'; E=$'\033[31m'
else R=""; B=""; G=""; Y=""; E=""; fi
info(){ printf "%s==>%s %s\n" "$B" "$R" "$*"; }
ok(){   printf "%s ✓ %s %s\n" "$G" "$R" "$*"; }
warn(){ printf "%s ! %s %s\n" "$Y" "$R" "$*"; }
err(){  printf "%s ✗ %s %s\n" "$E" "$R" "$*" >&2; }

usage() {
  cat <<'EOF'
resync.sh — push this repo's config/nvim into ~/.config/nvim, fast.

Edit the Lua config here, run ./resync.sh, restart nvim. Mirrors the repo over
~/.config/nvim (new files copied, deleted files removed). Does NOT touch mise
tools or installed plugins.

Usage:
  ./resync.sh            mirror config/nvim -> ~/.config/nvim
  ./resync.sh --backup   copy the current ~/.config/nvim aside first
  ./resync.sh --help
EOF
}

DO_BACKUP=0
for arg in "$@"; do
  case "$arg" in
    --backup)  DO_BACKUP=1 ;;
    -h|--help) usage; exit 0 ;;
    *) err "Unknown flag: $arg (try --help)"; exit 1 ;;
  esac
done

[ -d "$SRC" ] || { err "Source config not found: $SRC"; exit 1; }

if [ "$DO_BACKUP" -eq 1 ] && [ -d "$DEST" ]; then
  bak="$DEST.bak.$(date +%Y%m%d%H%M%S)"
  cp -R "$DEST" "$bak"; ok "Backed up old config -> $bak"
fi

info "Syncing  $SRC  ->  $DEST"
mkdir -p "$DEST"

# Keep a generated lua_ls workspace file (it isn't tracked in the repo).
if command -v rsync >/dev/null 2>&1; then
  rsync -a --delete --exclude '.luarc.json' "$SRC/" "$DEST/"
else
  # No rsync: clear DEST (except .luarc.json) and copy fresh. The config is
  # fully repo-managed, so wiping it is safe — plugins/undo live elsewhere.
  find "$DEST" -mindepth 1 -maxdepth 1 ! -name '.luarc.json' -exec rm -rf {} +
  cp -R "$SRC/." "$DEST/"
fi

ok "Config synced."
echo "  Restart nvim to apply (lazy installs any new plugin on launch)."
