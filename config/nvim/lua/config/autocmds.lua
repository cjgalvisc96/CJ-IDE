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
