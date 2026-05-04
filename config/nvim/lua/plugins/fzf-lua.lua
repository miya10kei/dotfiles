return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    files = {
      cmd = "rg --files --hidden --glob '!**/.git/*' | sort",
    },
    winopts = {
      keymap = {
        builtin = {
          ["J"] = "down",
          ["K"] = "up",
        },
      },
      preview = {
        layout = "horizontal",
        horizontal = "down:50%",
      },
    },
  },
  keys = {
    {
      "<C-t>",
      function()
        require("fzf-lua").files()
      end,
      desc = "Find files",
    },
    {
      "<C-e>",
      function()
        require("fzf-lua").buffers()
      end,
      desc = "Find buffers",
    },
    {
      "<leader>dr",
      function()
        require("fzf-lua").registers()
      end,
      desc = "Find registers",
    },
    {
      "<leader>/",
      function()
        require("fzf-lua").live_grep()
      end,
      desc = "Live grep",
    },
  },
}
