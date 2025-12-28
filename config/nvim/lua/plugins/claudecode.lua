return {
  {
    "coder/claudecode.nvim",
    enabled = false,
    dependencies = {
      "folke/snacks.nvim",
    },
    opts = {
      focus_after_send = true,
      terminal = {
        split_width_percentage = 0.5,
      },
      diff_opts = {
        auto_close_on_accept = true,
        open_in_current_tab = true,
        vertical_split = true,
        keep_terminal_open = true,
      },
    },
    keys = {
      { "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "[ClaudeCode] New" },
      { "<leader>ccc", "<cmd>ClaudeCode --continue<cr>", desc = "[ClaudeCode] Continue" },
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
