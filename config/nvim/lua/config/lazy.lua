-- Bootstrap lazy.nvim, then load LazyVim + the CJ-IDE extras and overrides.

-- Leader must exist before lazy.setup so plugin `keys` stubs resolve <leader>.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- LazyVim core, with the CJ-IDE colorscheme (LazyVim defaults to "moon").
    { "LazyVim/LazyVim", import = "lazyvim.plugins", opts = { colorscheme = "tokyonight-night" } },
    -- Picker: fzf-lua (the pickers user.lua drives: files, grep, buffers, LSP).
    { import = "lazyvim.plugins.extras.editor.fzf" },
    -- Languages CJ-IDE ships out of the box. Each extra wires treesitter
    -- parsers + LSP + formatting for its language (binaries come from mise).
    { import = "lazyvim.plugins.extras.lang.python" },
    { import = "lazyvim.plugins.extras.lang.go" },
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.yaml" },
    { import = "lazyvim.plugins.extras.lang.docker" },
    { import = "lazyvim.plugins.extras.lang.markdown" },
    -- CJ-IDE's own specs/overrides — imported LAST so they win over LazyVim.
    { import = "plugins" },
  },
  defaults = { lazy = false, version = false },
  install = { colorscheme = { "tokyonight" } },
  -- Stability: no background update checker — update deliberately with
  -- <leader>u (:Lazy update) and commit the refreshed lazy-lock.json.
  checker = { enabled = false },
  change_detection = { notify = false },
  -- None of our plugins need luarocks; disabling it removes the hererocks
  -- install error/warnings from :checkhealth.
  rocks = { enabled = false },
  performance = {
    rtp = {
      disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" },
    },
  },
})
