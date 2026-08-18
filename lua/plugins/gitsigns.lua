return {
  "lewis6991/gitsigns.nvim",
  opts = {},
  config = function(_, opts)
    local gs = require("gitsigns")
    gs.setup(opts)
    vim.defer_fn(function()
      if not pcall(gs.change_base, "main", true) then
        pcall(gs.change_base, "master", true)
      end
    end, 500)
  end,
}
