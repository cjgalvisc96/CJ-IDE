-- Editor options + diagnostics.

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
