---@type LazySpec
return {
  {
    "saghen/blink.cmp",
    dependencies = {
      "fang2hou/blink-copilot",
      "mikavilpas/blink-ripgrep.nvim",
      "moyiz/blink-emoji.nvim",
      "bydlw98/blink-cmp-env",
    },
    enabled = true,
    event = { "InsertEnter", "CmdLineEnter" },
    version = "*",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      completion = {
        accept = { auto_brackets = { enabled = false } },
        documentation = { auto_show = true },
        ghost_text = { enabled = true },
        list = { selection = { preselect = false, auto_insert = false } },
      },
      keymap = {
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<CR>"] = { "accept", "fallback" },

        ["<Tab>"] = { "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },

        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },

        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },

        ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
      },
      signature = { enabled = true },
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "copilot", "ripgrep", "emoji", "env" },
        providers = {
          copilot = {
            name = "copilot",
            module = "blink-copilot",
            score_offset = 100,
            async = true,
          },
          ripgrep = {
            name = "Ripgrep",
            module = "blink-ripgrep",
            ---@module "blink-ripgrep"
            ---@type blink-ripgrep.Options
            opts = {
              prefix_min_len = 3,
              context_size = 5,
              max_filesize = "1M",
              project_root_marker = { ".git", "package.json", "pyproject.toml" },
            },
          },
          emoji = {
            module = "blink-emoji",
            name = "Emoji",
          },
          env = {
            name = "Env",
            module = "blink-cmp-env",
            --- @type blink-cmp-env.Options
            opts = {
              show_braces = false,
              show_documentation_window = true,
            },
          },
        },
      },
    },
  },
}
