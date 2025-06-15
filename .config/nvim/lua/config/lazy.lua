local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { import = "plugins" },
  {
    "vim-denops/denops.vim",
  },
  {
    "Shougo/ddu.vim",
    config = function()
      require("ddu")
    end,
    dependencies = {
      "Milly/ddu-filter-kensaku",
      "Shougo/ddu-column-filename",
      "Shougo/ddu-filter-matcher_substring",
      "Shougo/ddu-kind-file",
      "Shougo/ddu-kind-word",
      "Shougo/ddu-source-buffer",
      "Shougo/ddu-source-file",
      "Shougo/ddu-source-file_rec",
      "Shougo/ddu-source-register",
      "Shougo/ddu-ui-ff",
      "Shougo/ddu-ui-filer",
      "lambdalisue/kensaku.vim",
      "shun/ddu-source-rg",
      "ryota2357/ddu-column-icon_filename",
      "uga-rosa/ddu-source-lsp",
      "yuki-yano/ddu-filter-fzf",
    },
    lazy = false,
    keys = {
      {
        "<C-t>",
        "<ESC><CMD>Ddu ddu__filer<CR>",
        silent = true,
      },
      {
        "<LEADER>df",
        "<ESC><CMD>Ddu ddu__file_rec<CR>",
        silent = true,
      },
      {
        "<C-e>",
        "<ESC><CMD>Ddu ddu__buffer<CR>",
        silent = true,
      },
      {
        "<LEADER>dr",
        "<ESC><CMD>Ddu ddu__register<CR>",
        silent = true,
      },
      {
        "<LEADER>/",
        "<ESC><CMD>Ddu ddu__grep<CR>",
        silent = true,
      },
      {
        "gd",
        "<ESC><CMD>Ddu ddu__lsp_definition<CR>",
        silent = true,
      },
      {
        "gh",
        "<ESC><CMD>Ddu ddu__lsp_call_hierarchy<CR>",
        silent = true,
      },
      {
        "gr",
        "<ESC><CMD>Ddu ddu__lsp_references<CR>",
        silent = true,
      },
      {
        "gw",
        "<ESC><CMD>Ddu ddu__lsp_workspace<CR>",
        silent = true,
      },
    },
  },
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-treesitter.configs").setup({
        highlight = {
          enable = true,
        },
        tree_docs = {
          enable = false,
        },
      })
      require("nvim-ts-autotag").setup()
    end,
    dependencies = {
      "nvim-treesitter/nvim-tree-docs",
      "nvim-treesitter/nvim-treesitter-textobjects",
      "windwp/nvim-ts-autotag",
    },
  },
  {
    "glidenote/memolist.vim",
    config = function()
      vim.g.memolist_path = vim.fn.expand("~/Documents/memo")
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
      "mfussenegger/nvim-dap-python",
    },
    config = function()
      -- require("plugins.dap")
    end,
  },
  {
    "is0n/jaq-nvim",
    config = function()
      require("jaq")
    end,
    keys = { "<LEADER>r", ":<C-u>Jaq<CR>", silent = true },
  },
})
