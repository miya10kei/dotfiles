local keymap = vim.keymap.set

vim.g.mapleader = ' '

keymap('i', '<C-h>', '<C-o>h')
keymap('i', '<C-j>', '<C-o>j')
keymap('i', '<C-k>', '<C-o>k')
keymap('i', '<C-l>', '<C-o>l')
keymap('i', 'jj', '<ESC>')
keymap('n', '<ESC><ESC>', ':<C-u>nohlsearch<CR>', { silent = true })
keymap('n', '<LEADER>n', ':<C-u>bn<CR>', { silent = true })
keymap('n', '<LEADER>p', ':<C-u>bp<CR>', { silent = true })
keymap('n', '<LEADER>r', ':<C-u>source $MYVIMRC<CR>', { silent=true })
keymap('n', 'j', 'gj')
keymap('n', 'k', 'gk')
keymap('n', 'q', '<NOP>')
keymap('n', '<C-n>', function()
    return vim.o.number == true and ':<C-u>set nonumber<CR>' or ':<C-u>set number<CR>'
end, { expr = true, silent = true })
keymap('n', '<SPACE><SPACE>', "\"zyiw:let @/ = '\\<' . @z . '\\>'<CR>:set hlsearch<CR>")
