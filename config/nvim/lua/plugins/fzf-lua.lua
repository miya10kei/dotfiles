return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    winopts = {
      keymap = {
        builtin = {
          ["<C-j>"] = "down",
          ["<C-k>"] = "up",
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
      function() require("fzf-lua").files() end,
      desc = "Find files",
    },
    {
      "<C-e>",
      function() require("fzf-lua").buffers() end,
      desc = "Find buffers",
    },
    {
      "<leader>dr",
      function() require("fzf-lua").registers() end,
      desc = "Find registers",
    },
    {
      "<leader>/",
      function() require("fzf-lua").live_grep() end,
      desc = "Live grep",
    },
    {
      "gd",
      function() require("fzf-lua").lsp_definitions() end,
      desc = "LSP definitions",
    },
    {
      "gh",
      function() require("fzf-lua").lsp_incoming_calls() end,
      desc = "LSP incoming calls",
    },
    {
      "gr",
      function() require("fzf-lua").lsp_references() end,
      desc = "LSP references",
    },
    {
      "gw",
      function() require("fzf-lua").lsp_workspace_symbols() end,
      desc = "LSP workspace symbols",
    },
  },
}
