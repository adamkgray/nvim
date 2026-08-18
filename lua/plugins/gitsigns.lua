-- picks whichever of local main/master actually exists in this repo;
-- git rev-parse is synchronous so we know the answer before calling change_base
-- (change_base itself is async, so a pcall around it can't catch a bad ref)
local function resolve_base()
  for _, ref in ipairs({ "main", "master" }) do
    vim.fn.system({ "git", "rev-parse", "--verify", "--quiet", ref })
    if vim.v.shell_error == 0 then
      return ref
    end
  end
end

return {
  "lewis6991/gitsigns.nvim",
  opts = {},
  config = function(_, opts)
    local gs = require("gitsigns")
    gs.setup(opts)
    -- first buffer's attach is async (shells out to git) and can finish after
    -- setup() returns using a stale base; force a re-diff once it's settled
    vim.defer_fn(function()
      local base = resolve_base()
      if base then
        gs.change_base(base, true)
      end
    end, 200)
  end,
}
