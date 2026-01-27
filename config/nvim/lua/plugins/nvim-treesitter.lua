local parsers = {
  "bash",
  "c",
  "cpp",
  "css",
  "diff",
  "dockerfile",
  "gitcommit",
  "go",
  "gomod",
  "hcl",
  "html",
  "java",
  "javascript",
  "json",
  "lua",
  "make",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "regex",
  "ruby",
  "rust",
  "sql",
  "terraform",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
}

---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    keys = {
      { "<Leader>zo", "zo", desc = "Open fold" },
      { "<Leader>zc", "zc", desc = "Close fold" },
      { "<Leader>za", "za", desc = "Toggle fold" },
      { "<Leader>zO", "zO", desc = "Open all folds (recursive)" },
      { "<Leader>zC", "zC", desc = "Close all folds (recursive)" },
      { "<Leader>zR", "zR", desc = "Open all folds" },
      { "<Leader>zM", "zM", desc = "Close all folds" },
      { "<Leader>zj", "zj", desc = "Next fold" },
      { "<Leader>zk", "zk", desc = "Previous fold" },
    },
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.wo[0][0].foldmethod = "expr"
          vim.wo[0][0].foldlevel = 99
        end,
      })

      vim.api.nvim_create_user_command("TSInstallNeeded", function()
        require("nvim-treesitter").install(parsers):wait(300000)
      end, { desc = "Install all needed treesitter parsers" })
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    event = "VeryLazy",
    opts = {},
  },
}
