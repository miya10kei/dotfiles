local map = vim.keymap.set
local silent = { silent = true }

map("i", "<C-h>", "<C-o>h", silent)
map("i", "<C-j>", "<C-o>j", silent)
map("i", "<C-k>", "<C-o>k", silent)
map("i", "<C-l>", "<C-o>l", silent)
map("i", "jj", "<ESC>", silent)
map("n", "<ESC><ESC>", "<Cmd>nohlsearch<CR>", silent)
map("n", "<LEADER>n", "<Cmd>bnext<CR>", silent)
map("n", "<LEADER>p", "<Cmd>bprevious<CR>", silent)
map("n", "j", "gj", silent)
map("n", "k", "gk", silent)
map("n", "q", "<NOP>", silent)
map({ "n", "x" }, "x", '"_x', silent)
map({ "n", "x" }, "X", '"_X', silent)
map("n", "<C-n>", "<Cmd>set number!<CR>", silent)
map("n", "<SPACE><SPACE>", "\"zyiw:let @/ = '\\<' . @z . '\\>'<CR>:set hlsearch<CR>", silent)
map("x", "p", '"_dP', silent)
map("x", "P", '"_dP', silent)

-- 現在のセッションを保存して再起動し、復元する
map("n", "<F5>", "<Cmd>restart<CR>", { silent = true, desc = "Restart Neovim" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", silent)
map("n", "<C-j>", "<C-w>j", silent)
map("n", "<C-k>", "<C-w>k", silent)
map("n", "<C-l>", "<C-w>l", silent)

-- Terminal mode window navigation
map("t", "<C-h>", "<C-\\><C-n><C-w>h", silent)
map("t", "<C-j>", "<C-\\><C-n><C-w>j", silent)
map("t", "<C-k>", "<C-\\><C-n><C-w>k", silent)
map("t", "<C-l>", "<C-\\><C-n><C-w>l", silent)

-- Terminal
map("n", "<F12>", function()
  vim.cmd("botright split")
  vim.cmd.resize(math.floor(vim.o.lines / 3))
  vim.cmd.terminal()
end, silent)
map("n", "<F11>", "<Cmd>rightbelow vsplit | terminal<CR>", silent)
map("t", "<ESC>", "<C-\\><C-n>", silent)

-- ファイル参照（@path/to/file、@path/to/file#L1-5）をクリップボードへコピーする
local function copy_file_reference(start_line, end_line)
  local text = "@" .. vim.fn.expand("%:.")
  if start_line then
    text = text .. "#L" .. start_line .. (start_line ~= end_line and "-" .. end_line or "")
  end
  vim.fn.setreg("+", text)
  vim.notify("Copied: " .. text, vim.log.levels.INFO)
end

map("n", "<LEADER>yf", function()
  copy_file_reference()
end, { silent = true, desc = "Copy file reference" })
map("x", "<LEADER>yf", function()
  local s, e = vim.fn.line("v"), vim.fn.line(".")
  copy_file_reference(math.min(s, e), math.max(s, e))
end, { silent = true, desc = "Copy file reference with lines" })
