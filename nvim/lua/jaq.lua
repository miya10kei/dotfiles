require("jaq-nvim").setup({
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
})

vim.keymap.set("n", "<LEADER>r", ":<C-u>Jaq<CR>", { silent = true })
