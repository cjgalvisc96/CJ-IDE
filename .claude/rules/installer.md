# Installer, mise & cross-platform

## Toolchain via mise (not mason)
- LSP servers and formatters are installed **globally via mise** and resolved on `PATH`.
- The Neovim config assumes these binaries already exist — it never installs them itself.
- Never introduce `mason`, `mason-lspconfig`, or per-machine tool bootstrapping into the Lua config.

## Shell scripts
- `install.sh` — one-command install. Must work across Debian/Ubuntu, Fedora, Arch,
  RHEL/Rocky/Alma, openSUSE, and macOS. Detect the platform/package manager and degrade
  gracefully; never assume `apt`.
- `prune.sh` — uninstaller. **Every** artifact `install.sh` creates must be removable here.
  When you add install-time state, update prune.sh in the same change.
- `resync.sh` — re-sync config/tooling for an existing install.

## Rules for changing scripts
- Keep them POSIX-friendly where practical; they run on many distros and macOS (bash).
- Validate syntax: `bash -n install.sh prune.sh resync.sh`; run `shellcheck` if available.
- `*.sh` uses 2-space indent (see `.editorconfig`).
- Any user-visible change to what gets installed should be reflected in README.
