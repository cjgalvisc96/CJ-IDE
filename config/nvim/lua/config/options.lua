-- Editor options — CJ-IDE overrides on top of LazyVim's defaults.
-- (LazyVim already sets number/relativenumber, undofile, splits, clipboard,
-- ignorecase/smartcase, signcolumn, cursorline, termguicolors, …)

-- Format-on-save OFF: CJ-IDE autosaves ~1s after you stop typing (user.lua),
-- and autosave + autoformat together would reformat the buffer under your
-- cursor every pause. Format manually with <leader>cf, or set true to opt in.
vim.g.autoformat = false

-- LazyVim lang extras (see config/lazy.lua): python via basedpyright + ruff.
-- These must be set here — options load before the extras are resolved.
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.lazyvim_python_ruff = "ruff"

-- Picker: fzf-lua (the extra is imported in config/lazy.lua; this makes the
-- choice explicit so LazyVim never auto-picks another backend).
vim.g.lazyvim_picker = "fzf"

local o = vim.opt
o.shiftwidth = 4 -- LazyVim defaults to 2; CJ-IDE keeps 4 (yaml/json/lua → 2 via autocmds)
o.tabstop = 4
o.smartindent = true
o.scrolloff = 6
-- Mouse in all modes — lets you drag the vertical split separator to resize the
-- file-explorer tree (and any split) with the pointer.
o.mouse = "a"

-- Disable the remote-host providers we don't use. None of the bundled plugins
-- are legacy rpc plugins, so this just removes the optional :checkhealth
-- warnings (and shaves a little startup work).
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
