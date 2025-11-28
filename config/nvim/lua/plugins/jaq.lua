---@type LazySpec
return {
  {
    "is0n/jaq-nvim",
    keys = {
      { "<LEADER>j", "<cmd>Jaq<cr>", desc = "Run Jaq" },
      { "<LEADER>r", "<cmd>Jaq<cr>", desc = "Run Jaq" },
    },
    opts = {
      cmds = {
        internal = {
          lua = "luafile %",
          vim = "source %",
        },
        external = {
          go = "go run %",
          python = "python %",
          sh = "sh %",
          rust = "cargo run %",
        },
      },
      ui = {
        float = {
          border = "rounded",
        },
      },
    },
  },
}
