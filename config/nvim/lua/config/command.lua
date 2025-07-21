---------------------
--- User Commands ---
---------------------
vim.api.nvim_create_user_command("Jq", function()
  vim.api.nvim_command("%!jq '.'")
end, {})

---------------------
--- Autocommands ---
---------------------
local vimrc_checktime_group = vim.api.nvim_create_augroup("vimrc-checktime", { clear = true })

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  command = "checktime",
  group = vimrc_checktime_group,
})
