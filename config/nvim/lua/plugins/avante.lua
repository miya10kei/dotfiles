---@type LazySpec
return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    build = "make",
    -- build = "make BUILD_FROM_SOURCE=true",
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
      system_prompt = function()
        local hub = require("mcphub").get_hub_instance()
        return hub and hub:get_active_servers_prompt() or ""
      end,
      -- Using function prevents requiring mcphub before it's loaded
      custom_tools = function()
        return {
          require("mcphub.extensions.avante").mcp_tool(),
        }
      end,
      disabled_tools = {
        "list_files",
        "search_files",
        "read_file",
        "create_file",
        "rename_file",
        "delete_file",
        "create_dir",
        "rename_dir",
        "delete_dir",
        "bash",
      },
    },
  },
}
