local BLAMER_VERSION = '1.3.0'
local DDC_VERSION = 'v3.9.0'
local DDU_VERSION = 'v3.4.4'
local DENOPS_VERSION = '5.0.0'
local EASYMOTION_VERSION = '3.0.1'
local GRUVBOX_VERSION = '2.0.0'
local INDENT_LINE_VERSION = '2.0'
local LEXIMA_VERSION = 'v2.1.0'
local NVIM_LSPCONFIG_VERSION = '0.1.4'
local TCOMMENT_VERSION = '4.00'


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
      'Yggdroot/indentLine',
      version = INDENT_LINE_VERSION,
    },
    {
      'cohama/lexima.vim',
      tag = LEXIMA_VERSION,
    },
    {
        'morhetz/gruvbox',
        version = GRUVBOX_VERSION,
        config = function()
            vim.g.gruvbox_contrast_dark='hard'
            vim.cmd([[colorscheme gruvbox]])
        end
    },
    {
        'easymotion/vim-easymotion',
        version = EASYMOTION_VERSION,
        config = function()
            vim.g.EasyMotion_do_mapping = 0
            vim.g.EasyMotion_smartcase = 1
        end,
        keys = {
            { 's',         '<Plug>(easymotion-overwin-f2)', silent = true },
            { '<LEADER>j', '<Plug>(easymotion-j)',          silent = true },
            { '<LEADER>k', '<Plug>(easymotion-k)',          silent = true },
        },
    },
    {
        'vim-denops/denops.vim',
        version = DENOPS_VERSION,
        config = function()
          vim.g.denops_server_addr = '127.0.0.1:32123'
        end
    },
    {
        'Shougo/ddc.vim',
        version = DDC_VERSION,
        config = function() require('ddc') end,
        dependencies = {
            'Shougo/ddc-matcher_head',
            'Shougo/ddc-sorter_rank',
            'Shougo/ddc-source-around',
            'Shougo/ddc-source-nvim-lsp',
            'Shougo/ddc-ui-native',
        },
        lazy = true,
        keys = {
            {
                '<TAB>',
                function()
                    print("TAB")
                    if vim.fn.pumvisible() > 0 then
                        return '<C-n>'
                    else
                        local line = vim.api.nvim_get_current_line()
                        local col = vim.fn.col('.')
                        if col <= 1 or line:sub(col - 2):match('%s') then
                            return '<C-t>'
                        else
                            return vim.fn['ddc#map#manual_complete']()
                        end
                    end
                end,
                mode = 'i',
                expr = true,
                silent = true,
            },
            {
                '<S-TAB>',
                function()
                    print("S-TAB")
                    return vim.fn.pumvisible() > 0 and '<C-p>' or '<C-d>'
                end,
                mode = 'i',
                expr = true,
                silent = true,
            }
        }
    },
    {
        'Shougo/ddu.vim',
        version = DDU_VERSION,
        config = function() require('ddu') end,
        dependencies = {
            'Milly/ddu-filter-kensaku',
            'Shougo/ddu-column-filename',
            'Shougo/ddu-filter-matcher_substring',
            'Shougo/ddu-kind-file',
            'Shougo/ddu-kind-word',
            'Shougo/ddu-source-buffer',
            'Shougo/ddu-source-file',
            'Shougo/ddu-source-file_rec',
            'Shougo/ddu-source-register',
            'Shougo/ddu-ui-ff',
            'Shougo/ddu-ui-filer',
            'lambdalisue/kensaku.vim',
            'ryota2357/ddu-column-icon_filename',
            'shun/ddu-source-rg',
            'uga-rosa/ddu-source-lsp',
            'yuki-yano/ddu-filter-fzf',
        },
        lazy = false,
        keys = {
            { '<C-t>',      "<ESC><CMD>Ddu ddu__filer<CR>",      silent = true },
            { '<LEADER>df', "<ESC><CMD>Ddu ddu__file_rec<CR>",   silent = true },
            { '<LEADER>db', "<ESC><CMD>Ddu ddu__buffer<CR>",     silent = true },
            { '<LEADER>dr', "<ESC><CMD>Ddu ddu__register<CR>",   silent = true },
            { '<LEADER>dg', "<ESC><CMD>Ddu ddu__grep<CR>",       silent = true },
            { 'gd', "<ESC><CMD>Ddu ddu__lsp_definition<CR>",     silent = true },
            { 'gh', "<ESC><CMD>Ddu ddu__lsp_call_hierarchy<CR>", silent = true },
            { 'gr', "<ESC><CMD>Ddu ddu__lsp_references<CR>",     silent = true },
            { 'gw', "<ESC><CMD>Ddu ddu__lsp_workspace<CR>",      silent = true },
        }
    },
    {
        'neovim/nvim-lspconfig',
        --version = NVIM_LSPCONFIG_VERSION,
        config = function()
            require('lsp')
        end,
        dependencies = {
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            'jose-elias-alvarez/null-ls.nvim',
            'nvim-lua/plenary.nvim',
        }
    },
    {
        'APZelos/blamer.nvim',
        version = BLAMER_VERSION,
    },
    {
        'tomtom/tcomment_vim',
        tag = TCOMMENT_VERSION,
        keys = {
          { '<C-_>', ':<C-u>TCommentInline<CR>' },
        }
    }
})
