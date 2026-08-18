return {
  "lewis6991/gitsigns.nvim",
  opts = {
    base = "main",
  },
  config = function(_, opts)
    local gs = require("gitsigns")
    gs.setup(opts)
    -- first buffer's attach is async (shells out to git) and can finish after
    -- setup() returns using a stale base; force a re-diff once it's settled
    vim.defer_fn(function()
      if not pcall(gs.change_base, "main", true) then
        pcall(gs.change_base, "master", true)
      end
    end, 200)
  end,
}
