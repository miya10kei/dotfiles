local keymap = vim.keymap.set
local keymap_opts_silent = {
  silent = true,
}

vim.g.mapleader = " "

keymap("i", "<C-h>", "<C-o>h", keymap_opts_silent)
keymap("i", "<C-j>", "<C-o>j", keymap_opts_silent)
keymap("i", "<C-k>", "<C-o>k", keymap_opts_silent)
keymap("i", "<C-l>", "<C-o>l", keymap_opts_silent)
keymap("i", "jj", "<ESC>", keymap_opts_silent)
keymap("n", "<ESC><ESC>", " :<C-u>nohlsearch<CR>", keymap_opts_silent)
keymap("n", "<LEADER>n", ": <C-u>bn<CR>", keymap_opts_silent)
keymap("n", "<LEADER>p", ": <C-u>bp<CR>", keymap_opts_silent)
keymap("n", "<LEADER>r", ":<C-u>source $MYVIMRC<CR>", keymap_opts_silent)
keymap("n", "j", "gj", keymap_opts_silent)
keymap("n", "k", "gk", keymap_opts_silent)
keymap("n", "q", "<NOP>", keymap_opts_silent)
keymap("n", "<C-n>", function()
  return vim.o.number == true and ":<C-u>set nonumber<CR>" or ":<C-u>set number<CR>"
end, {
  expr = true,
  silent = true,
})
keymap("n", "<SPACE><SPACE>", "\"zyiw:let @/ = '\\<' . @z . '\\>'<CR>:set hlsearch<CR>", keymap_opts_silent)
