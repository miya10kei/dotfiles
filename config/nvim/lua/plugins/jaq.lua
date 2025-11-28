---@type LazySpec
return {
  {
    "is0n/jaq-nvim",
    keys = {
      { "<LEADER>j", "<cmd>Jaq<cr>", desc = "Run Jaq" },
    },
    config = function()
      require("jaq")
    end,
  },
}
