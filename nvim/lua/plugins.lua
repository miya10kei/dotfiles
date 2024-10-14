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
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("ibl").setup()
    end,
  },
  {
    "morhetz/gruvbox",
    config = function()
      vim.g.gruvbox_contrast_dark = "hard"
      vim.cmd([[colorscheme gruvbox]])
    end,
  },
  {
    "vim-denops/denops.vim",
  },
  {
    "Shougo/ddc.vim",
    config = function()
      require("ddc")
      require("vsnip")
    end,
    dependencies = {
      "Shougo/ddc-matcher_head",
      "Shougo/ddc-sorter_rank",
      "Shougo/ddc-source-around",
      "Shougo/ddc-source-lsp",
      "Shougo/ddc-ui-native",
      "hrsh7th/vim-vsnip",
      --"hrsh7th/vim-vsnip-integ",
      "uga-rosa/ddc-source-lsp-setup",
      "uga-rosa/ddc-source-vsnip",
    },
    lazy = true,
    keys = {
      {
        "<TAB>",
        function()
          if vim.fn.pumvisible() > 0 then
            return "<C-n>"
          else
            local line = vim.api.nvim_get_current_line()
            local col = vim.fn.col(".")
            if col <= 1 or line:sub(col - 2):match("%s") then
              return "<C-t>"
            else
              return vim.fn["ddc#map#manual_complete"]()
            end
          end
        end,
        mode = "i",
        expr = true,
        silent = true,
      },
      {
        "<S-TAB>",
        function()
          return vim.fn.pumvisible() > 0 and "<C-p>" or "<C-h>"
        end,
        mode = "i",
        expr = true,
        silent = true,
      },
    },
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
    "neovim/nvim-lspconfig",
    config = function()
      require("lsp")
    end,
    dependencies = {
      "akinsho/flutter-tools.nvim",
      "nanotee/sqls.nvim",
      "nvim-lua/plenary.nvim",
      "nvimtools/none-ls.nvim",
      "williamboman/mason-lspconfig.nvim",
      "williamboman/mason.nvim",
    },
    opts = {
      autoformat = false,
    },
  },
  {
    "APZelos/blamer.nvim",
  },
  {
    "tomtom/tcomment_vim",
    keys = {
      {
        "<C-_>",
        ":<C-u>TCommentInline<CR>",
      },
    },
  },
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end,
  },
  {
    "thinca/vim-quickrun",
    config = function()
      vim.g.quickrun_config = {
        ["_"] = {
          ["runner"] = "neovim_job",
          ["outputter"] = "error",
          ["outputter/error/success"] = "buffer",
          ["outputter/error/error"] = "quickfix",
          ["outputter/buffer/opener"] = ":below new",
          ["outputter/buffer/close_on_empty"] = 1,
        },
      }
    end,
    dependencies = {
      "lambdalisue/vim-quickrun-neovim-job",
    },
    keys = {
      {
        "<LEADER>r",
        ":<C-u>QuickRun<CR>",
      },
    },
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
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },
  {
    "anuvyklack/pretty-fold.nvim",
    config = function()
      require("pretty-fold").setup()
    end,
  },
  {
    "glidenote/memolist.vim",
    config = function()
      vim.g.memolist_path = vim.fn.expand("~/Documents/memo")
    end,
  },
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    config = function()
      require("chatgpt").setup({
        api_key_cmd = "pass show chat-gpt-api-key 2>/dev/null",
      })
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "folke/trouble.nvim", -- optional
      "nvim-telescope/telescope.nvim",
    },
  },
})
