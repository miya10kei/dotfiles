-----------------------
--- nvim-treesitter ---
-----------------------
local used_treesitter_packages = {
    'bash',
    'css',
    'csv',
    'diff',
    'dockerfile',
    'git_config',
    'git_rebase',
    'gitattributes',
    'gitcommit',
    'gitignore',
    'go',
    'haskell',
    'javascript',
    'jq',
    'lua',
    'make',
    'markdown',
    'python',
    'rust',
    'sql',
    'terraform',
    'toml',
    'tsv',
    'tsx',
    'typescript',
    'xml',
    'yaml',
}

---------------------
--- User Commands ---
---------------------
vim.api.nvim_create_user_command('TreeSitterInstall', function()
    local install_packages_string = table.concat(used_treesitter_packages, ' ')
    vim.api.nvim_command(string.format('TSInstallSync! %s', install_packages_string))
end, {})
