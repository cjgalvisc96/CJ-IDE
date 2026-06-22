-- Fuzzy finder (fzf-lua).
-- The pickers are driven from user.lua (<leader>p files, <leader>b buffers,
-- <leader>f grep). Loads on demand via its :FzfLua command — no <leader>f*
-- keymaps here, so <leader>f stays instant (no prefix-timeout).
return {
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    opts = {},
  },
}
