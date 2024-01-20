local BLAMER_VERSION = '1.3.0'
local DDC_VERSION = 'v4.3.1'
local DDU_VERSION = 'v3.10.0'
local GRUVBOX_VERSION = '2.0.0'
local INDENT_LINE_VERSION = '2.0'
local LEXIMA_VERSION = 'v2.1.0'
local TCOMMENT_VERSION = '4.00'

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable',
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
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
            vim.g.gruvbox_contrast_dark = 'hard'
            vim.cmd([[colorscheme gruvbox]])
        end,
    },
    {
        'vim-denops/denops.vim',
    },
    {
        'Shougo/ddc.vim',
        version = DDC_VERSION,
        config = function() require('ddc') end,
        dependencies = {
            'Shougo/ddc-matcher_head',
            'Shougo/ddc-sorter_rank',
            'Shougo/ddc-source-around',
            'Shougo/ddc-source-lsp',
            'Shougo/ddc-ui-native',
        },
        lazy = true,
        keys = {
            ---@diagnostic disable-next-line: missing-fields
            {
                '<TAB>',
                function()
                    print('TAB')
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
            ---@diagnostic disable-next-line: missing-fields
            {
                '<S-TAB>',
                function()
                    print('S-TAB')
                    return vim.fn.pumvisible() > 0 and '<C-p>' or '<C-d>'
                end,
                mode = 'i',
                expr = true,
                silent = true,
            },
        },
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
            'miya10kei/ddu-source-rg',
            'uga-rosa/ddu-source-lsp',
            'yuki-yano/ddu-filter-fzf',
        },
        lazy = false,
        keys = {
            ---@diagnostic disable-next-line: missing-fields
            {
                '<C-t>',
                '<ESC><CMD>Ddu ddu__filer<CR>',
                silent = true,
            },
            ---@diagnostic disable-next-line: missing-fields
            {
                '<LEADER>df',
                '<ESC><CMD>Ddu ddu__file_rec<CR>',
                silent = true,
            },
            ---@diagnostic disable-next-line: missing-fields
            {
                '<C-e>',
                '<ESC><CMD>Ddu ddu__buffer<CR>',
                silent = true,
            },
            ---@diagnostic disable-next-line: missing-fields
            {
                '<LEADER>dr',
                '<ESC><CMD>Ddu ddu__register<CR>',
                silent = true,
            },
            ---@diagnostic disable-next-line: missing-fields
            {
                '<LEADER>dg',
                '<ESC><CMD>Ddu ddu__grep<CR>',
                silent = true,
            },
            ---@diagnostic disable-next-line: missing-fields
            {
                '<LEADER>gd',
                '<ESC><CMD>Ddu ddu__grep_current_file<CR>',
                silent = true,
            },
            ---@diagnostic disable-next-line: missing-fields
            {
                'gd',
                '<ESC><CMD>Ddu ddu__lsp_definition<CR>',
                silent = true,
            },
            ---@diagnostic disable-next-line: missing-fields
            {
                'gh',
                '<ESC><CMD>Ddu ddu__lsp_call_hierarchy<CR>',
                silent = true,
            },
            ---@diagnostic disable-next-line: missing-fields
            {
                'gr',
                '<ESC><CMD>Ddu ddu__lsp_references<CR>',
                silent = true,
            },
            ---@diagnostic disable-next-line: missing-fields
            {
                'gw',
                '<ESC><CMD>Ddu ddu__lsp_workspace<CR>',
                silent = true,
            },
        },
    },
    {
        'neovim/nvim-lspconfig',
        config = function() require('lsp') end,
        dependencies = {
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            'nvimtools/none-ls.nvim',
            'nvim-lua/plenary.nvim',
        },
        opts = {
            autoformat = false,
        },
    },
    {
        'APZelos/blamer.nvim',
        version = BLAMER_VERSION,
    },
    {
        'tomtom/tcomment_vim',
        tag = TCOMMENT_VERSION,
        keys = {
            ---@diagnostic disable-next-line: missing-fields
            {
                '<C-_>',
                ':<C-u>TCommentInline<CR>',
            },
        },
    },
    {
        'kristijanhusak/vim-dadbod-ui',
        dependencies = {
            {
                'tpope/vim-dadbod',
                lazy = true,
            },

            {
                'kristijanhusak/vim-dadbod-completion',
                ft = {
                    'sql',
                    'mysql',
                    'plsql',
                },
                lazy = true,
            },
        },
        cmd = {
            'DBUI',
            'DBUIToggle',
            'DBUIAddConnection',
            'DBUIFindBuffer',
        },
    },
    {
        'tpope/vim-surround',
    },
    {
        'thinca/vim-quickrun',
        config = function()
            vim.g.quickrun_config = {
                ['_'] = {
                    ['runner'] = 'neovim_job',
                    ['outputter'] = 'error',
                    ['outputter/error/success'] = 'buffer',
                    ['outputter/error/error'] = 'quickfix',
                    ['outputter/buffer/opener'] = ':below new',
                    ['outputter/buffer/close_on_empty'] = 1,
                },
            }
        end,
        dependencies = {
            'lambdalisue/vim-quickrun-neovim-job',
        },
        keys = {
            ---@diagnostic disable-next-line: missing-fields
            {
                '<LEADER>r',
                ':<C-u>QuickRun<CR>',
            },
        },
    },
    {
        'nvim-treesitter/nvim-treesitter',
        config = function()
            require'nvim-treesitter.configs'.setup {
                highlight = {
                    enable = true,
                },
            }
        end,
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',
        },
    },
    {
        'windwp/nvim-ts-autotag',
        config = function() require('nvim-ts-autotag').setup() end,
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
        },
        lazy = true,
        event = 'VeryLazy',
    },
    {
        'mattn/vim-chatgpt',
    },
})
