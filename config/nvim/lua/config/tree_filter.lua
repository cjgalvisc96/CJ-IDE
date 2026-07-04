-- Type-aware, live filtering for the nvim-tree panel.
--
-- nvim-tree's built-in live filter matches EVERY node name, so filtering for a
-- file also matches folder names — you'd see a matched folder with all of its
-- (non-matching) files gone. This splits the filter by node TYPE while keeping
-- nvim-tree's native, incremental "filter as you type" overlay:
--   file        -> match FILES only; folders show only as the path to a hit
--   directory   -> match DIRECTORIES only; a matched folder shows its contents
--   both        -> match either (the built-in behaviour, used by `f`)
-- The query is a Vim regex on the node's name.
--
-- It works by swapping the live-filter instance's `apply_filter` for a
-- type-aware version. nvim-tree uses rxi/classic (plain tables, no __newindex
-- guard), so a per-instance method override is safe; the override also handles
-- an empty filter, so nvim-tree's own reload/expand calls keep working.

local M = {}

local function name_of(node)
  return vim.fn.fnamemodify(node.absolute_path or "", ":t")
end

local function children_of(node)
  -- group_empty collapses a/b/c into one node chained via group_next
  return node.group_next and { node.group_next } or node.nodes
end

-- Unhide a subtree — used when the filter is empty or invalid.
local function unhide(node)
  node.hidden = false
  if node.hidden_stats then
    node.hidden_stats.live_filter = 0
  end
  local nodes = children_of(node)
  if nodes then
    for _, child in ipairs(nodes) do
      unhide(child)
    end
  end
end

-- Recursively set node.hidden by TYPE. `under_match` = we're inside a directory
-- that already matched (directory mode), so keep everything below it.
local function mark(node, re, kind, under_match, DirectoryNode)
  local is_dir = node:as(DirectoryNode) ~= nil

  local self_match
  if kind == "dirsonly" then
    -- no regex: every directory shows, every file hides
    self_match = is_dir
  else
    local match_files = kind ~= "directory"
    local match_dirs = kind ~= "file"
    self_match = false
    if is_dir and match_dirs then
      self_match = re:match_str(name_of(node)) ~= nil
    elseif not is_dir and match_files then
      self_match = re:match_str(name_of(node)) ~= nil
    end
  end

  local child_under = under_match or (kind == "directory" and is_dir and self_match)

  local nodes = children_of(node)
  local hidden_children, visible_child = 0, false
  if nodes then
    for _, child in ipairs(nodes) do
      mark(child, re, kind, child_under, DirectoryNode)
      if child.hidden then
        hidden_children = hidden_children + 1
      else
        visible_child = true
      end
    end
  end

  if is_dir then
    node.hidden_stats = vim.tbl_deep_extend("force", node.hidden_stats or {}, { live_filter = hidden_children })
  end

  if under_match then
    node.hidden = false -- inside a matched directory: show it all
  elseif is_dir then
    node.hidden = not (self_match or visible_child) -- match, or leads to a hit
  else
    node.hidden = not self_match
  end
end

-- The replacement for LiveFilter:apply_filter — reads the type from self._cj_kind.
local function type_aware_apply(self, node_)
  local kind = self._cj_kind or "both"
  local DirectoryNode = require("nvim-tree.node.directory")

  -- dirsonly is a static toggle (no live filter text): hide files, show folders.
  -- Re-applied here on every reload/expand, so the view survives file changes.
  if kind == "dirsonly" then
    for _, n in ipairs(self.explorer.nodes or {}) do
      mark(n, nil, "dirsonly", false, DirectoryNode)
    end
    return
  end

  local filter = self.filter
  if not filter or filter == "" then
    unhide(node_ or self.explorer)
    return
  end
  local ok, re = pcall(vim.regex, filter)
  if not ok then
    unhide(node_ or self.explorer) -- invalid mid-typing: show all until valid
    return
  end
  -- Re-filter the whole tree so the "inside a matched dir" context is always
  -- correct, regardless of which subtree nvim-tree handed us.
  for _, n in ipairs(self.explorer.nodes or {}) do
    mark(n, re, kind, false, DirectoryNode)
  end
end

-- Toggle a type-scoped live filter in the current tree. Pressing the same kind
-- again clears it (like the built-in F); a different kind switches mode.
function M.toggle(kind)
  local explorer = require("nvim-tree.core").get_explorer()
  if not explorer then
    return
  end
  local lf = explorer.live_filter
  if lf.filter ~= nil and lf._cj_kind == kind then
    lf:clear_filter()
    return
  end
  lf._cj_kind = kind
  lf.apply_filter = type_aware_apply -- per-instance override (idempotent)
  lf:start_filtering()
end

-- Toggle a directories-only view: hide every file, show just the folder tree.
-- No input box and no filter line — it's a static view. Press again to restore.
function M.dirs_only()
  local explorer = require("nvim-tree.core").get_explorer()
  if not explorer then
    return
  end
  local lf = explorer.live_filter
  if lf._cj_kind == "dirsonly" then
    lf._cj_kind = nil
    unhide(explorer)
    explorer.renderer:draw()
    return
  end
  lf.filter = nil -- make sure no live-filter text lingers
  lf._cj_kind = "dirsonly"
  lf.apply_filter = type_aware_apply -- per-instance override (idempotent)
  lf:apply_filter()
  explorer.renderer:draw()
end

return M
