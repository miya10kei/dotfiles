return {
  {
    "coder/claudecode.nvim",
    enabled = true,
    lazy = false,
    dependencies = {
      "folke/snacks.nvim",
    },
    opts = {
      terminal = {
        split_width_percentage = 0.4,
      },
      diff_opts = {
        auto_close_on_accept = false,
        open_in_current_tab = false,
        vertical_split = false,
      },
    },
    keys = {
      { "<leader>cn", "<cmd>ClaudeCode<cr>", desc = "New Claude" },
      { "<leader>cc", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>cr", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<leader>cf", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<leader>ca", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
      { "<leader>cs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
      {
        "<leader>cs",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil" },
      },
      { "<leader>cy", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>cn", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    },
  },
}
