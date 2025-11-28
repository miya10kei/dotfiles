local keymap = vim.keymap.set
local keymap_opts_silent = {
  silent = true,
  noremap = true,
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
keymap("x", "p", '"_dP', keymap_opts_silent)

-- Window navigation
keymap("n", "<C-h>", "<C-w>h", keymap_opts_silent)
keymap("n", "<C-j>", "<C-w>j", keymap_opts_silent)
keymap("n", "<C-k>", "<C-w>k", keymap_opts_silent)
keymap("n", "<C-l>", "<C-w>l", keymap_opts_silent)

-- Terminal mode window navigation
keymap("t", "<C-h>", "<C-\\><C-n><C-w>h", keymap_opts_silent)
keymap("t", "<C-j>", "<C-\\><C-n><C-w>j", keymap_opts_silent)
keymap("t", "<C-k>", "<C-\\><C-n><C-w>k", keymap_opts_silent)
keymap("t", "<C-l>", "<C-\\><C-n><C-w>l", keymap_opts_silent)

-- Terminal
keymap("n", "<F12>", "<CMD>botright split<CR><CMD>resize " .. math.floor(vim.o.lines / 3) .. "<CR><CMD>terminal<CR>", keymap_opts_silent)
keymap("n", "<F11>", "<CMD>rightbelow vsplit<CR><CMD>terminal<CR>", keymap_opts_silent)
keymap("t", "<ESC>", "<C-\\><C-n>", keymap_opts_silent)
