local augroup = vim.api.nvim_create_augroup('FileTypeIndent')
vim.api.nvim_clear_autocmds({ group = augroup })
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
    group = augroup,
    buffer = bufnr,
    callback = function()
        vim.lsp.buf.format({
            bufnr = bufnr,
            filter = function(lsp_client)
                return lsp_client.name == 'null-ls'
            end
        })
    end
})
