-- Markdown — render-markdown.nvim comes from LazyVim's lang.markdown extra
-- (see config/lazy.lua); CJ-IDE tweaks on top:
--
-- Rendering is ON automatically when you open a *.md file. Toggle it off/on
-- with <leader>md to drop back to the raw text (e.g. to copy exact markup).
return {
  -- The extra also ships markdown-preview.nvim (browser preview) bound to
  -- <leader>cp — that shadows CJ-IDE's "copy file path" in markdown buffers.
  -- Drop it: render-markdown below IS the CJ-IDE markdown preview.
  { "iamcco/markdown-preview.nvim", enabled = false },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      -- Render in normal mode; on the line you're editing the raw markup shows
      -- through, so inserting/selecting still sees the real characters.
      render_modes = { "n", "c" },
    },
    keys = {
      {
        "<leader>md",
        "<cmd>RenderMarkdown toggle<cr>",
        desc = "Markdown: toggle pretty view",
        ft = "markdown",
      },
    },
  },
}
