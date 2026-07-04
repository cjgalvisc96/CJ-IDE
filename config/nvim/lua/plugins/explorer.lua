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
        side = "right", -- dock the tree on the right side
        width = 34, -- initial width; drag the right border with the mouse to resize
        -- Don't snap the tree back to `width` after you drag its border or open
        -- files — a mouse-resized width sticks for the session.
        preserve_window_proportions = true,
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

        -- Type-scoped LIVE filtering (logic in config/tree_filter.lua). Filters
        -- the tree as you type a Vim regex on the name; <CR> keeps it, <Esc>
        -- closes the input. Press the SAME key again to clear (like F):
        --   <leader>f  match FILES only (folders show only as the path to a hit)
        --   <leader>d  match DIRECTORIES only (a matched folder shows its files)
        --   f          match either type (the built-in-style filter)
        local tree_filter = require("config.tree_filter")
        vim.keymap.set("n", "<leader>f", function()
          tree_filter.toggle("file")
        end, { buffer = bufnr, desc = "Explorer: live-search files (toggle)" })
        vim.keymap.set("n", "<leader>d", function()
          tree_filter.toggle("directory")
        end, { buffer = bufnr, desc = "Explorer: live-search directories (toggle)" })
        vim.keymap.set("n", "f", function()
          tree_filter.toggle("both")
        end, { buffer = bufnr, desc = "Explorer: live-filter any name (toggle)" })
      end,
    },
  },
}
