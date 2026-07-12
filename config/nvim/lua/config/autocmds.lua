-- Filetype tweaks.

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "yaml", "json", "jsonc", "lua" },
  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go" },
  callback = function()
    vim.bo.expandtab = false -- Go uses tabs
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown" },
  callback = function()
    -- markview can't decorate tables in wrapped windows (it falls back to raw
    -- pipes for ALL of them) and its docs recommend nowrap. A long table row
    -- stays one aligned line you scroll into instead of folding into a mess.
    vim.wo.wrap = false
  end,
})
