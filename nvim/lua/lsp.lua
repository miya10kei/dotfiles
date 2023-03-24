--local masson_ok, _ = pcall(require, 'mason')
--local masson_lspconfig_ok, _ = pcall(require, 'mason-lspconfig')
--local lspconfig_ok, _ = pcall(require, 'lspconfig')
--local null_ls_ok = pcall(require, 'null-ls')
--if not (masson_ok
--    and masson_lspconfig_ok
--    and lspconfig_ok
--    and null_ls_ok) then
--    return
--end

-- keymaps
local keymap = vim.keymap.set
keymap('n', '<SPACE>e', vim.diagnostic.open_float, { silent = true })
keymap('n', '[d', vim.diagnostic.goto_prev, { silent = true })
keymap('n', ']d', vim.diagnostic.goto_next, { silent = true })
keymap('n', '<SPACE>q', vim.diagnostic.setloclist, { silent = true })

local on_attach = function(_, bufnr)
    local bufopts = { buffer = bufnr, silent = true }
    keymap('n', 'gD', vim.lsp.buf.declaration, bufopts)
    keymap('n', 'gd', vim.lsp.buf.definition, bufopts)
    keymap('n', 'K', vim.lsp.buf.hover, bufopts)
    keymap('n', 'gi', vim.lsp.buf.implementation, bufopts)
    keymap('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    keymap('n', '<SPACE>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    keymap('n', '<SPACE>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
    keymap('n', '<SPACE>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
    keymap('n', '<SPACE>D', vim.lsp.buf.type_definition, bufopts)
    keymap('n', '<SPACE>rn', vim.lsp.buf.rename, bufopts)
    keymap('n', '<SPACE>ca', vim.lsp.buf.code_action, bufopts)
    keymap('n', 'gr', vim.lsp.buf.references, bufopts)
    keymap('n', '<SPACE>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end


-- mason
require('mason').setup({
    log_level = vim.log.levels.WARN,
    max_concurrent_installers = 1,
})
require('mason-lspconfig').setup()


-- nvim-lspconfig
local lspconfig = require('lspconfig')
lspconfig['gopls'].setup {
    on_attach = on_attach,
    cmd = {
        'gopls',
        '-remote=:37374',
        '-logfile=auto',
        '-debug=:0',
        '-rpc.trace'
    }
}
lspconfig['hls'].setup {
    on_attach = on_attach,
}
lspconfig['lua_ls'].setup {
    on_attach = on_attach,
    settings = {
        Lua = {
            runtime = {
                version = 'LuaJIT',
            },
            diagnostics = {
                globals = { 'vim' },
            },
            workspace = {
                library = vim.api.nvim_get_runtime_file('', true)
            },
            telemetry = {
                enable = false,
            },
        }
    }
}
lspconfig['pyright'].setup {
    on_attach = on_attach,
}
lspconfig['terraformls'].setup {
    on_attach = on_attach,
}


-- null-ls
local null_ls = require('null-ls')
local mason_package = require('mason-core.package')
local mason_registry = require('mason-registry')
local null_sources = {}
for _, package in ipairs(mason_registry.get_installed_packages()) do
    local package_category = package.spec.categories[1]
    if package_category == mason_package.Cat.Formatter then
        table.insert(null_sources, null_ls.builtins.formatting[package.name])
    end
end

null_ls.setup({
    sources = null_sources,
    on_attach = function(client, bufnr)
        if client.supports_method('textDocument/formatting') then
            local augroup = vim.api.nvim_create_augroup('LspFormatting', {})
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
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
        end
    end,
})
