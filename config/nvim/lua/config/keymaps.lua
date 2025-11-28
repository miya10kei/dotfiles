local keymap = vim.keymap.set
local opts = require("utils.keymap")

vim.g.mapleader = " "

keymap("i", "<C-h>", "<C-o>h", opts.silent)
keymap("i", "<C-j>", "<C-o>j", opts.silent)
keymap("i", "<C-k>", "<C-o>k", opts.silent)
keymap("i", "<C-l>", "<C-o>l", opts.silent)
keymap("i", "jj", "<ESC>", opts.silent)
keymap("n", "<ESC><ESC>", " :<C-u>nohlsearch<CR>", opts.silent)
keymap("n", "<LEADER>n", ": <C-u>bn<CR>", opts.silent)
keymap("n", "<LEADER>p", ": <C-u>bp<CR>", opts.silent)
keymap("n", "j", "gj", opts.silent)
keymap("n", "k", "gk", opts.silent)
keymap("n", "q", "<NOP>", opts.silent)
keymap("n", "<C-n>", function()
  return vim.o.number == true and ":<C-u>set nonumber<CR>" or ":<C-u>set number<CR>"
end, {
  expr = true,
  silent = true,
})
keymap("n", "<SPACE><SPACE>", "\"zyiw:let @/ = '\\<' . @z . '\\>'<CR>:set hlsearch<CR>", opts.silent)
keymap("x", "p", '"_dP', opts.silent)

-- Window navigation
keymap("n", "<C-h>", "<C-w>h", opts.silent)
keymap("n", "<C-j>", "<C-w>j", opts.silent)
keymap("n", "<C-k>", "<C-w>k", opts.silent)
keymap("n", "<C-l>", "<C-w>l", opts.silent)

-- Terminal mode window navigation
keymap("t", "<C-h>", "<C-\\><C-n><C-w>h", opts.silent)
keymap("t", "<C-j>", "<C-\\><C-n><C-w>j", opts.silent)
keymap("t", "<C-k>", "<C-\\><C-n><C-w>k", opts.silent)
keymap("t", "<C-l>", "<C-\\><C-n><C-w>l", opts.silent)

-- Terminal
keymap("n", "<F12>", "<CMD>botright split<CR><CMD>resize " .. math.floor(vim.o.lines / 3) .. "<CR><CMD>terminal<CR>", opts.silent)
keymap("n", "<F11>", "<CMD>rightbelow vsplit<CR><CMD>terminal<CR>", opts.silent)
keymap("t", "<ESC>", "<C-\\><C-n>", opts.silent)
