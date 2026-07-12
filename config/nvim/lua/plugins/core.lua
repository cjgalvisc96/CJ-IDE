-- CJ-IDE overrides of LazyVim's core behavior.
return {
  -- NO mason: every LSP/formatter binary comes from mise on your PATH (see
  -- install.sh + config/mise/tools.txt). Servers set mason = false in lsp.lua.
  { "mason-org/mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },
  -- Same reason for the debugger: dap.core ships mason-nvim-dap to fetch
  -- adapters, but debugpy comes from mise (pipx:debugpy → `debugpy-adapter` on
  -- PATH). Disabling it also makes dap.core's `LazyVim.has(...)` guard skip the
  -- mason-nvim-dap setup that would otherwise error with mason gone.
  { "jay-babu/mason-nvim-dap.nvim", enabled = false },

  -- NO neo-tree: selected as LazyVim's "explorer" (vim.g.lazyvim_explorer in
  -- config/options.lua) purely so LazyVim doesn't force-enable snacks_explorer
  -- (whose <leader>e would race with nvim-tree's). The plugin itself is off —
  -- CJ-IDE's explorer is nvim-tree (plugins/explorer.lua).
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },

  -- Keep stock f/F/t/T char motions in visual/operator mode: CJ-IDE remaps
  -- normal-mode f/F to fold/unfold (user.lua), and flash's labeled char jumps
  -- would fight that muscle memory. flash's s/S jump/treesitter stay.
  { "folke/flash.nvim", opts = { modes = { char = { enabled = false } } } },

  -- gitsigns: keep the sign column + hunk highlights, drop its buffer-local
  -- <leader>gh* maps — they'd put a timeout wait on CJ-IDE's single-key
  -- <leader>g search in every git-tracked buffer.
  { "lewis6991/gitsigns.nvim", opts = { on_attach = function() end } },

  -- Prune LazyVim plugins CJ-IDE can't reach: their only entry points are
  -- <leader> prefix maps that keymaps.lua deletes (see its header), so they
  -- would ship as dead weight.
  -- Sessions: <leader>q* maps pruned and the CJ-IDE dashboard has no
  -- "restore session" button, so a saved session could never be loaded.
  { "folke/persistence.nvim", enabled = false },
  -- Diagnostics/symbols panels: <leader>x* maps pruned; fzf-lua, lualine and
  -- todo-comments guard their trouble integrations with LazyVim.has().
  { "folke/trouble.nvim", enabled = false },
  -- Second colorscheme LazyVim ships; CJ-IDE is tokyonight-night.
  { "catppuccin/nvim", enabled = false },
  -- Auto-closes HTML/JSX tags — CJ-IDE ships no web languages.
  { "windwp/nvim-ts-autotag", enabled = false },
}
