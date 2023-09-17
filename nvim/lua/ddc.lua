vim.fn['ddc#custom#patch_global']({
    ui = 'native',
    sources = {
        'around',
        'nvim-lsp',
    },
    sourceOptions = {
        _ = {
            matchers = {
                'matcher_head',
            },
        },
        around = {
            mark = '[A]',
        },
        ['nvim-lsp'] = {
            mark = '[LSP]',
            forceCompletionPattern = '\\.\\w*|:\\w*|->\\w*',
        },
    },
    sourceParams = {
        around = {
            maxSize = 500,
        },
        ['nvim-lsp'] = {
            kindLabels = {
                Class = 'c',
            },
        },
    },
})

vim.fn['ddc#enable']()
