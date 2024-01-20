vim.fn['ddc#custom#patch_global']({
    ui = 'native',
    sources = {
        'around',
        'lsp',
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
        ['lsp'] = {
            mark = '[LSP]',
            forceCompletionPattern = '\\.\\w*|:\\w*|->\\w*',
        },
    },
    sourceParams = {
        around = {
            maxSize = 500,
        },
        ['lsp'] = {
            kindLabels = {
                Class = 'c',
            },
        },
    },
})

vim.fn['ddc#enable']()
