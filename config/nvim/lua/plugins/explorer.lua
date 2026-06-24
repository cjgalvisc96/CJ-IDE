-- File explorer: nvim-tree as a side panel docked on the LEFT.
--
-- Swapped from neo-tree to shed two dependencies (plenary + nui): nvim-tree
-- gives the same docked-tree experience with just nvim-web-devicons. Use a Nerd
-- Font (https://www.nerdfonts.com) so the file icons + glyphs render.
return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeToggle", "NvimTreeFindFileToggle", "NvimTreeFocus" },
    -- <leader>e is a smart toggle so one key both leaves AND returns to the tree:
    --   closed              -> open it and reveal the current file
    --   open, cursor in file -> FOCUS the tree (jump back to it)
    --   open, cursor in tree -> close it
    keys = {
      {
        "<leader>e",
        function()
          local api = require("nvim-tree.api")
          if not api.tree.is_visible() then
            api.tree.find_file({ open = true, focus = true })
          elseif vim.bo.filetype == "NvimTree" then
            api.tree.close()
          else
            api.tree.focus()
          end
        end,
        desc = "Explorer (toggle / focus)",
      },
    },
    -- nvim-tree wants netrw disabled before it loads, and this must happen at
    -- startup (not on the lazy load), hence init rather than config.
    init = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    end,
    opts = {
      view = {
        side = "left", -- dock the tree on the left side
        width = 34,
      },
      renderer = {
        group_empty = true, -- collapse chains of empty folders
      },
      update_focused_file = {
        enable = true, -- track/reveal the file you're editing
      },
      filters = {
        dotfiles = false, -- show dotfiles (.env, .github, …)
        git_ignored = false, -- show gitignored files too (toggle live with I)
      },
      -- filesystem_watchers are on by default, so the tree auto-refreshes on
      -- external changes (no extra config needed).
      on_attach = function(bufnr)
        local api = require("nvim-tree.api")
        api.config.mappings.default_on_attach(bufnr) -- keep all default keys
        -- Drop S (search_node): it walks the whole tree synchronously and
        -- freezes the UI on large/gitignored dirs (node_modules, .venv). Use
        -- <leader>p (fzf files) for fast project-wide search instead. The live
        -- filter `f` / clear `F` still work inside the tree.
        pcall(vim.keymap.del, "n", "S", { buffer = bufnr })
      end,
    },
  },
}
