-- Statusline + tabs — CJ-IDE flavor on top of LazyVim's lualine/bufferline.
-- (Theme = tokyonight-night, set on the LazyVim spec in config/lazy.lua;
-- which-key comes configured by LazyVim.)
return {
  -- Inline IMAGE rendering (snacks.image): opening a .png/.jpg/.gif/.webp/…
  -- shows the actual image, and markdown files render their images inline.
  -- Needs a terminal that speaks the kitty graphics protocol (kitty, ghostty,
  -- wezterm) — elsewhere it silently stays plain text. ImageMagick (installed
  -- by install.sh) handles format conversion.
  {
    "folke/snacks.nvim",
    opts = {
      image = { enabled = true },
    },
  },

  -- Show the file's ABSOLUTE PATH (path = 2) in the statusline, with the
  -- modified/readonly flags. Use path = 1 for relative, 4 for name-only.
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.sections.lualine_c = {
        "diagnostics",
        {
          "filename",
          path = 2,
          symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" },
        },
      }
    end,
  },

  -- VSCode-like tabs: one tab per open file (buffer), across the top. Click a
  -- tab to switch, click its × to close. Navigation keymaps live in user.lua
  -- (<Tab> / <S-Tab> cycle, <A-,> / <A-.> reorder).
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        separator_style = "thin",
        show_buffer_close_icons = true,
        show_close_icon = false,
        -- Keep the tab bar clear of the nvim-tree panel.
        offsets = {
          { filetype = "NvimTree", text = "Explorer", highlight = "Directory", separator = true },
        },
      },
    },
  },
}
