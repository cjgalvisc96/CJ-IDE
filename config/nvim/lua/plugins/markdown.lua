-- Pretty in-buffer rendering for Markdown files: styled headings, bullets,
-- code blocks, checkboxes and tables drawn right in the editor (no browser).
--
-- Rendering is ON automatically when you open a *.md file. Toggle it off/on
-- with <leader>md to drop back to the raw text (e.g. to copy exact markup).
--
-- Needs the `markdown` + `markdown_inline` treesitter parsers — both are
-- already in the parser list (see plugins/treesitter.lua).
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      -- Render in normal mode; on the line you're editing the raw markup shows
      -- through, so inserting/selecting still sees the real characters.
      render_modes = { "n", "c" },
    },
    keys = {
      { "<leader>md", "<cmd>RenderMarkdown toggle<cr>", desc = "Markdown: toggle pretty view", ft = "markdown" },
    },
  },
}
