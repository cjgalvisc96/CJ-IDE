-- Syntax-aware highlighting and indentation.
--
-- Uses the `main` branch (the rewrite). The old `master` branch is frozen and
-- does NOT work on Neovim 0.12+. The main branch compiles parsers locally, so
-- the tree-sitter CLI + a C compiler must be on PATH (install.sh handles both).
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      -- jsonc is intentionally absent: it has no parser of its own and maps to
      -- the json parser automatically (vim.treesitter.language.get_lang).
      local langs = {
        "python", "go", "gomod", "gosum", "yaml", "json", "lua",
        "bash", "markdown", "markdown_inline", "dockerfile", "vim", "vimdoc",
      }
      -- Installs missing parsers in the background (no-op once present).
      require("nvim-treesitter").install(langs)

      -- Start highlighting + TS indentation per buffer. Guarded with pcall so a
      -- not-yet-installed parser silently skips instead of crashing the buffer
      -- (parsers install async on first run; they attach on the next launch).
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          local buf = ev.buf
          local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
          if not lang then return end
          if pcall(vim.treesitter.start, buf, lang) then
            vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
