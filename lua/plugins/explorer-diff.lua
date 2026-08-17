-- Colors filenames in the snacks explorer that differ from origin/HEAD (committed
-- or not) using a new highlight group, layered on top of the existing uncommitted
-- git-status coloring (that mechanism is untouched). Wraps the public finder
-- functions rather than snacks' internal git-status merge logic, and uses the
-- existing per-item `filename_hl` override point (snacks/picker/format.lua).
local M = {}

local HL = "SnacksExplorerDiffHead"
local BASE = "origin/HEAD"

local function set_hl()
  vim.api.nvim_set_hl(0, HL, { default = true, link = "String" })
end

-- root -> { files = set of changed absolute paths, dirs = set of their ancestor dirs }
M.cache = {}

function M.refresh(root, on_done)
  vim.system(
    { "git", "diff", "--name-only", "--merge-base", BASE },
    { cwd = root, text = true },
    vim.schedule_wrap(function(out)
      local files, dirs = {}, {}
      if out.code == 0 then
        for _, rel in ipairs(vim.split(out.stdout or "", "\n", { trimempty = true })) do
          local abs = root .. "/" .. rel
          files[abs] = true
          local dir = vim.fn.fnamemodify(abs, ":h")
          while dir and #dir >= #root and dir ~= "/" do
            dirs[dir] = true
            if dir == root then
              break
            end
            dir = vim.fn.fnamemodify(dir, ":h")
          end
        end
      end
      M.cache[root] = { files = files, dirs = dirs }
      if on_done then
        on_done()
      end
    end)
  )
end

function M.refresh_open_explorers()
  for _, p in ipairs(Snacks.picker.get({ source = "explorer" })) do
    p:find()
  end
end

function M.patch()
  local explorer = require("snacks.picker.source.explorer")
  for _, name in ipairs({ "explorer", "search" }) do
    local orig = explorer[name]
    explorer[name] = function(opts, ctx)
      local finder = orig(opts, ctx)
      local root = ctx:git_root() or vim.fn.getcwd()
      if not M.cache[root] then
        M.refresh(root, M.refresh_open_explorers)
      end
      local cached = M.cache[root]
      return function(cb)
        return finder(function(item)
          if cached and item.file and (cached.files[item.file] or cached.dirs[item.file]) then
            item.filename_hl = HL
          end
          return cb(item)
        end)
      end
    end
  end
end

return {
  "folke/snacks.nvim",
  init = function()
    set_hl()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = set_hl })
    M.patch()
  end,
  keys = {
    {
      "<leader>ue",
      function()
        for root in pairs(M.cache) do
          M.refresh(root, M.refresh_open_explorers)
        end
      end,
      desc = "Refresh explorer diff vs origin/HEAD",
    },
  },
}
