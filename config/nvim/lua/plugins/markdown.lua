-- Markdown — CJ-IDE renders markdown in-buffer with markview.nvim
-- (Obsidian-style: heading pills, callouts, fancy tables). Rendering is ON
-- automatically when you open a *.md file (this IS the CJ-IDE markdown
-- preview). Toggle it off/on with <leader>md to drop back to the raw text;
-- insert mode always shows the raw markup for editing.
return {
  -- LazyVim's lang.markdown extra ships two renderers CJ-IDE doesn't use:
  -- markdown-preview.nvim (browser preview whose <leader>cp shadows CJ-IDE's
  -- "copy file path") and render-markdown.nvim (replaced by markview below).
  { "iamcco/markdown-preview.nvim", enabled = false },
  { "MeanderingProgrammer/render-markdown.nvim", enabled = false },

  -- The extra also lints markdown with markdownlint-cli2, which CJ-IDE does
  -- not install (no mason) — every open/save popped an ENOENT error. Drop it.
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      if opts.linters_by_ft then
        opts.linters_by_ft.markdown = nil
      end
    end,
  },

  {
    "OXY2DEV/markview.nvim",
    -- markview manages its own lazy-loading; loading it lazily is unsupported.
    lazy = false,
    opts = {
      preview = { icon_provider = "mini" },
    },
    keys = {
      {
        "<leader>md",
        "<cmd>Markview Toggle<cr>",
        desc = "Markdown: toggle pretty view",
        ft = "markdown",
      },
    },
  },
}
