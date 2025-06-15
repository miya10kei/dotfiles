---@type LazySpec
return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    build = "make BUILD_FROM_SOURCE=true",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "zbirenbaum/copilot.lua",
      "ravitemer/mcphub.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      provider = "copilot",
      mode = "agentic",
      auto_suggestions_provider = "copilot",
      behavior = {
        auto_apply_diff_after_generation = false,
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_suggestions = false,
        minimize_diff = true,
        support_paste_from_clipboard = false,
        use_cwd_as_project_root = true,
      },
      hints = { enabled = false },
      windows = {
        position = "right",
        wrap = true,
        width = 45,
        sidebar_header = {
          enabled = true,
          align = "left",
          rounded = true,
        },
        ask = {
          start_insert = false,
        },
        edit = {
          border = "rounded",
          start_insert = true,
        },
      },
    },
  },
}
