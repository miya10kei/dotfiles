---------------
--- Keymaps ---
---------------
local keymap = vim.keymap.set
local keymap_opts_slient = {
    silent = true,
}
keymap('n', '<SPACE>e', vim.diagnostic.open_float, keymap_opts_slient)
keymap('n', '[d', vim.diagnostic.goto_prev, keymap_opts_slient)
keymap('n', ']d', vim.diagnostic.goto_next, keymap_opts_slient)
keymap('n', '<SPACE>q', vim.diagnostic.setloclist, keymap_opts_slient)

local on_attach = function(_, bufnr)
    local bufopts = {
        buffer = bufnr,
        silent = true,
    }
    keymap('n', 'gD', vim.lsp.buf.declaration, bufopts)
    keymap('n', 'K', vim.lsp.buf.hover, bufopts)
    keymap('n', 'gi', vim.lsp.buf.implementation, bufopts)
    keymap('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    keymap('n', '<SPACE>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    keymap('n', '<SPACE>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
    keymap('n', '<SPACE>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, bufopts)
    keymap('n', '<SPACE>D', vim.lsp.buf.type_definition, bufopts)
    keymap('n', '<SPACE>rn', vim.lsp.buf.rename, bufopts)
    keymap('n', '<SPACE>ca', vim.lsp.buf.code_action, bufopts)
    keymap('n', '<SPACE>f', function()
        vim.lsp.buf.format {
            async = true,
        }
    end, bufopts)
end

-------------
--- Mason ---
-------------
require('mason').setup({
    log_level = vim.log.levels.WARN,
})
require('mason-lspconfig').setup()
local mason_registry = require('mason-registry')
local mason_package = require('mason-core.package')

----------------------
--- nvim-lspconfig ---
----------------------
local lspconfig = require('lspconfig')
local used_masson_packages = {
    ['lsp'] = {
        'angular-language-server',
        'bash-language-server',
        'docker-compose-language-service',
        'dockerfile-language-server',
        'gopls',
        'haskell-language-server',
        'html-lsp',
        'json-lsp',
        'lua-language-server',
        'python-lsp-server',
        'terraform-ls',
        'typescript-language-server',
        'yaml-language-server',
    },
    ['linter'] = {
        'flake8',
        'tflint',
        'tfsec',
    },
    ['formatter'] = {
        'goimports',
    },
}

for _, v in pairs(used_masson_packages['lsp']) do
    local alias = mason_registry.get_package_aliases(v)[1] or v
    if alias == 'lua_ls' then
        lspconfig[alias].setup {
            on_attach = on_attach,
            settings = {
                Lua = {
                    runtime = {
                        version = 'LuaJIT',
                    },
                    diagnostics = {
                        globals = {
                            'vim',
                        },
                    },
                    workspace = {
                        library = vim.api.nvim_get_runtime_file('', true),
                    },
                    telemetry = {
                        enable = false,
                    },
                },
            },
        }
    elseif alias == 'pylsp' then
        lspconfig[alias].setup {
            on_attach = on_attach,
            settings = {
                pylsp = {
                    configurationSources = {
                        'flake8',
                    },
                    plugins = {
                        flake8 = {
                            enabled = true,
                        },
                        rope_autoimport = {
                            enabled = true,
                        },
                    },
                },
            },
        }
    elseif alias == 'yamlls' then
        lspconfig[alias].setup {
            on_attach = on_attach,
            settings = {
                yaml = {
                    schemas = {
                        ['https://raw.githubusercontent.com/aws/serverless-application-model/develop/samtranslator/validator/sam_schema/schema.json'] = 'template.yaml',
                    },
                },
            },
        }
    else
        lspconfig[alias].setup {
            on_attach = on_attach,
        }
    end
end

---------------
--- null-ls ---
---------------
local null_ls = require('null-ls')
local null_sources = {
    null_ls.builtins.formatting.terraform_fmt,
}

for _, package in ipairs(mason_registry.get_installed_packages()) do
    local package_category = package.spec.categories[1]
    if package_category == mason_package.Cat.Formatter then
        for k, _ in pairs(package.spec.bin) do
            local name = string.gsub(k, '-', '_')
            table.insert(null_sources, null_ls.builtins.formatting[name])
        end
    end
end

null_ls.setup({
    sources = null_sources,
    on_attach = function(client, bufnr)
        if client.supports_method('textDocument/formatting') then
            local augroup = vim.api.nvim_create_augroup('LspFormatting', {})
            vim.api.nvim_clear_autocmds({
                group = augroup,
                buffer = bufnr,
            })
            vim.api.nvim_create_autocmd({
                'BufWritePre',
            }, {
                group = augroup,
                buffer = bufnr,
                callback = function()
                    vim.lsp.buf.format({
                        bufnr = bufnr,
                        filter = function(lsp_client) return lsp_client.name == 'null-ls' end,
                    })
                end,
            })
        end
    end,
})

---------------------
--- User Commands ---
---------------------
vim.api.nvim_create_user_command('MasonInstallNeeded', function()
    local install_packages = {}
    for _, packages in pairs(used_masson_packages) do
        local not_installed_packages = {}
        for _, package in pairs(packages) do
            if not mason_registry.is_installed(package) then
                table.insert(not_installed_packages, package)
            end
        end
        local not_installed_packages_string = table.concat(not_installed_packages, ' ')
        table.insert(install_packages, not_installed_packages_string)
    end
    local install_packages_string = table.concat(install_packages, ' ')
    vim.api.nvim_command(string.format('MasonInstall %s', install_packages_string))
end, {})
