-- CJ-IDE overrides of LazyVim's core behavior.
return {
  -- NO mason: every LSP/formatter binary comes from mise on your PATH (see
  -- install.sh + config/mise/tools.txt). Servers set mason = false in lsp.lua.
  { "mason-org/mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },

  -- Keep stock f/F/t/T char motions in visual/operator mode: CJ-IDE remaps
  -- normal-mode f/F to fold/unfold (user.lua), and flash's labeled char jumps
  -- would fight that muscle memory. flash's s/S jump/treesitter stay.
  { "folke/flash.nvim", opts = { modes = { char = { enabled = false } } } },

  -- gitsigns: keep the sign column + hunk highlights, drop its buffer-local
  -- <leader>gh* maps — they'd put a timeout wait on CJ-IDE's single-key
  -- <leader>g search in every git-tracked buffer.
  { "lewis6991/gitsigns.nvim", opts = { on_attach = function() end } },
}
