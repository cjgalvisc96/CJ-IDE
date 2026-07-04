-- A read-only preview pane for the file under the cursor in nvim-tree.
--
-- Shows the file's contents (syntax-highlighted) in a floating window over the
-- editor area, updating as you move through the tree and closing when you leave
-- it. The preview uses a SCRATCH buffer, so unlike nvim-tree's built-in preview
-- it never adds entries to the buffer/tab (bufferline) list.
--
-- Wired from plugins/explorer.lua's on_attach (CursorMoved -> update, BufLeave
-- -> close). Binary and unreadable files are skipped; big files are capped.

local M = {}

local MAX_LINES = 500
local pwin, pbuf
local timer = (vim.uv or vim.loop).new_timer()

function M.close()
  timer:stop()
  if pwin and vim.api.nvim_win_is_valid(pwin) then
    pcall(vim.api.nvim_win_close, pwin, true)
  end
  pwin = nil
end

local function is_binary(lines)
  for i = 1, math.min(#lines, 50) do
    if lines[i]:find("\0") then
      return true
    end
  end
  return false
end

local function render(file)
  local ok, lines = pcall(vim.fn.readfile, file, "", MAX_LINES)
  if not ok or is_binary(lines) then
    M.close()
    return
  end

  if not pbuf or not vim.api.nvim_buf_is_valid(pbuf) then
    pbuf = vim.api.nvim_create_buf(false, true)
    vim.bo[pbuf].bufhidden = "wipe"
  end
  vim.bo[pbuf].modifiable = true
  vim.api.nvim_buf_set_lines(pbuf, 0, -1, false, lines)
  vim.bo[pbuf].modifiable = false
  local ft = vim.filetype.match({ filename = file }) or ""
  if vim.bo[pbuf].filetype ~= ft then
    vim.bo[pbuf].filetype = ft -- drives treesitter/syntax highlighting
  end

  -- Put the float in the editor area, on whichever side of the tree has room
  -- (works whether the tree is docked left or right).
  local ti = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
  local left = ti.wincol - 1
  local right = vim.o.columns - (ti.wincol - 1 + ti.width)
  local width, col
  if left >= right then
    width, col = left - 2, 0
  else
    width, col = right - 2, ti.wincol - 1 + ti.width
  end
  if width < 20 then
    M.close()
    return
  end

  local cfg = {
    relative = "editor",
    row = 0,
    col = col,
    width = width,
    height = vim.o.lines - 3,
    style = "minimal",
    border = "rounded",
    focusable = false,
    title = " " .. vim.fn.fnamemodify(file, ":t") .. " ",
    title_pos = "center",
  }
  if pwin and vim.api.nvim_win_is_valid(pwin) then
    vim.api.nvim_win_set_config(pwin, cfg)
    vim.api.nvim_win_set_buf(pwin, pbuf)
  else
    cfg.noautocmd = true
    pwin = vim.api.nvim_open_win(pbuf, false, cfg)
    vim.wo[pwin].wrap = false
  end
  pcall(vim.api.nvim_win_set_cursor, pwin, { 1, 0 })
end

-- CursorMoved in the tree -> preview the file under the cursor (debounced).
function M.update()
  local explorer = require("nvim-tree.core").get_explorer()
  if not explorer then
    return
  end
  local node = explorer:get_node_at_cursor()
  local DirectoryNode = require("nvim-tree.node.directory")
  if not node or node:as(DirectoryNode) or not node.absolute_path then
    M.close() -- a directory or nothing under the cursor: nothing to preview
    return
  end
  local file = node.absolute_path
  if vim.fn.filereadable(file) == 0 then
    M.close()
    return
  end
  timer:stop()
  timer:start(
    60,
    0,
    vim.schedule_wrap(function()
      if vim.bo.filetype == "NvimTree" then -- still in the tree
        render(file)
      end
    end)
  )
end

return M
