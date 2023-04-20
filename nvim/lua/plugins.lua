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
        'morhetz/gruvbox',
        config = function()
            vim.g.gruvbox_contrast_dark='hard'
            vim.cmd([[colorscheme gruvbox]])
        end
    },
    {
        'easymotion/vim-easymotion',
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
    },
    {
        'Shougo/ddc.vim',
        config = function() require('ddc') end,
        dependencies = {
            'Shougo/ddc-matcher_head',
            'Shougo/ddc-sorter_rank',
            'Shougo/ddc-source-around',
            'Shougo/ddc-source-nvim-lsp',
            'Shougo/ddc-ui-native',
        },
        lazy = false,
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
        config = function() require('ddu') end,
        dependencies = {
            'Shougo/ddu-column-filename',
            'Shougo/ddu-filter-matcher_substring',
            'Shougo/ddu-kind-file',
            'Shougo/ddu-kind-word',
            'Shougo/ddu-source-buffer',
            'Shougo/ddu-source-file',
            'Shougo/ddu-source-file_rec',
            'Shougo/ddu-source-register',
            'Shougo/ddu-source-rg',
            'Shougo/ddu-ui-ff',
            'Shougo/ddu-ui-filer',
        },
        lazy = false,
        keys = {
            { '<C-t>',      "<CMD>call ddu#start({ 'name': 'filer'    })<CR>", silent = true },
            { '<LEADER>db', "<CMD>call ddu#start({ 'name': 'buffer'   })<CR>", silent = true },
            { '<LEADER>df', "<CMD>call ddu#start({ 'name': 'file_rec' })<CR>", silent = true },
            { '<LEADER>dr', "<CMD>call ddu#start({ 'name': 'register' })<CR>", silent = true },
            { '<LEADER>dg', "<CMD>call ddu#start({ 'name': 'grep'     })<CR>", silent = true },
        }
    },
    {
        'neovim/nvim-lspconfig',
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
    },
})
