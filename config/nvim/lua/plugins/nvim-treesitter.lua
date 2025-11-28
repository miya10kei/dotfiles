---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "VeryLazy" },
    build = ":TSUpdate",
    main = "nvim-treesitter.configs",
    dependencies = {
      "nvim-treesitter/nvim-tree-docs",
    },
    opts = {
      auto_install = false,
      ensure_installed = {
        -- Primary languages
        "lua",
        "python",
        "go",
        "gomod",
        "rust",
        "typescript",
        "javascript",
        "tsx",
        "java",
        "c",
        "cpp",
        "ruby",
        "bash",
        -- Web/Markup
        "html",
        "css",
        "json",
        "yaml",
        "toml",
        "markdown",
        "markdown_inline",
        -- Config/Infra
        "dockerfile",
        "terraform",
        "hcl",
        "sql",
        "make",
        -- Required
        "vim",
        "vimdoc",
        "regex",
        "query",
        -- Git
        "gitcommit",
        "diff",
      },
      highlight = { enable = true },
      indent = { enable = true },
      tree_docs = { enable = true, },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<M-j>",
          node_incremental = "<M-j>",
          scope_incremental = false,
          node_decremental = "<M-k>",
        },
      },
    },
  },
  {
    "windwp/nvim-ts-autotag",
    event = { "VeryLazy" },
    opts = {},
  },
}
