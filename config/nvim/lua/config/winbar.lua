-- Winbar: show the ABSOLUTE PATH of the focused file at the top of its window.
-- Only real file windows get the bar — neo-tree, terminals, the help float and
-- [No Name] buffers are left bare (no wasted row).
--
--   %F  full path to the file   ·   %m  modified flag ([+])

local group = vim.api.nvim_create_augroup("cj_winbar", { clear = true })

vim.api.nvim_create_autocmd({ "BufWinEnter", "BufEnter", "WinEnter", "TermOpen" }, {
  group = group,
  desc = "Absolute-path winbar on file windows",
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.bo[buf].buftype ~= "" or vim.api.nvim_buf_get_name(buf) == "" then
      vim.wo.winbar = nil -- special / unnamed buffer → fall back to no winbar
    else
      vim.wo.winbar = "  %F%=%m "
    end
  end,
})
