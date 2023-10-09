---------------------
--- User Commands ---
---------------------
vim.api.nvim_create_user_command('Jq', function() vim.api.nvim_command('%!jq \'.\'') end, {})
