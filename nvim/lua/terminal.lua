local keymap = vim.keymap.set

keymap("n", "<F12>", "<CMD>belowright new<CR><CMD>terminal<CR>")
keymap("t", "<ESC>", "<C-\\><C-n>")

vim.api.nvim_create_augroup("terminal_config", {})
vim.api.nvim_create_autocmd("TermOpen", {
  command = "startinsert",
  group = "terminal_config",
  pattern = "*",
})
