local fileTypeIndentAutogroup = vim.api.nvim_create_augroup('FileTypeIndent', {})
vim.api.nvim_clear_autocmds({
    group = fileTypeIndentAutogroup,
})
vim.api.nvim_create_autocmd({
    'BufWritePre',
}, {
    group = fileTypeIndentAutogroup,
    buffer = bufnr,
    callback = function()
        vim.lsp.buf.format({
            bufnr = bufnr,
            filter = function(lsp_client) return lsp_client.name == 'null-ls' end,
        })
    end,
})

local extendsAutogroup = vim.api.nvim_create_augroup('Extends', {})
vim.api.nvim_clear_autocmds({
    group = extendsAutogroup,
})
vim.api.nvim_create_autocmd({
    'BufRead',
}, {
    group = extendsAutogroup,
    pattern = {
        '*',
    },
    callback = function()
        if vim.fn.line('\'"') > 0 and vim.fn.line('\'"') <= vim.fn.line('$') then
            vim.api.nvim_command('normal g`\"')
        end
    end,
})
