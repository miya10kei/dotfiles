local keymap = vim.keymap.set local fn = vim.fn

vim.g.mapleader = ' '

keymap('i', '<C-h>', '<C-o>h')
keymap('i', '<C-j>', '<C-o>j')
keymap('i', '<C-k>', '<C-o>k')
keymap('i', '<C-l>', '<C-o>l')
keymap('i', 'jj', '<ESC>')
keymap('n', '<ESC><ESC>', ':<C-u>nohlsearch<CR>', { silent = true })
keymap('n', '<LEADER>n', ':<C-u>bn<CR>', { silent = true })
keymap('n', '<LEADER>p', ':<C-u>bp<CR>', { silent = true })
keymap('n', 'j', 'gj')
keymap('n', 'k', 'gk')
keymap('n', 'q', '<NOP>')
keymap('n', '<C-n>', function()
    return vim.o.number == true and ':<C-u>set nonumber<CR>' or ':<C-u>set number<CR>'
end, { expr = true, silent = true })
keymap('n', '<SPACE><SPACE>', "\"zyiw:let @/ = '\\<' . @z . '\\>'<CR>:set hlsearch<CR>")

-- ddc
keymap('i', '<TAB>', function()
    if fn.pumvisible() > 0 then
        return '<C-n>'
    else
        local line = vim.api.nvim_get_current_line()
        local col = fn.col('.')
        if col <= 1 or line:sub(col - 2):match('%s') then
            return '<C-t>'
        else
            return fn['ddc#map#manual_complete']()
        end
    end
end, { expr = true, silent = true })
keymap('i', '<S-TAB>', function()
    return fn.pumvisible() > 0 and '<C-p>' or '<C-d>'
end, { expr = true, silent = true })
