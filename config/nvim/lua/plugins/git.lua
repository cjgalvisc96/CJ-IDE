-- Git hunk signs, staging and blame (gitsigns).
return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      on_attach = function(buf)
        local gs = require("gitsigns")
        local function m(l, r, d)
          vim.keymap.set("n", l, r, { buffer = buf, desc = d })
        end
        m("]c", gs.next_hunk, "Next hunk")
        m("[c", gs.prev_hunk, "Prev hunk")
        m("<leader>gs", gs.stage_hunk, "Stage hunk")
        m("<leader>gr", gs.reset_hunk, "Reset hunk")
        m("<leader>gp", gs.preview_hunk, "Preview hunk")
        m("<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
      end,
    },
  },
}
