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
keymap("x", "P", '"_dP', opts.silent)

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
keymap(
  "n",
  "<F12>",
  "<CMD>botright split<CR><CMD>resize " .. math.floor(vim.o.lines / 3) .. "<CR><CMD>terminal<CR>",
  opts.silent
)
keymap("n", "<F11>", "<CMD>rightbelow vsplit<CR><CMD>terminal<CR>", opts.silent)
keymap("t", "<ESC>", "<C-\\><C-n>", opts.silent)

-- Build file reference (@path/to/file, @path/to/file#L1-5)
local function build_file_reference(start_line, end_line)
  local filepath = vim.fn.expand("%:.")
  local text = "@" .. filepath
  if start_line then
    text = text .. "#L" .. start_line .. (start_line ~= end_line and "-" .. end_line or "")
  end
  return text
end

local function copy_file_reference(start_line, end_line)
  local text = build_file_reference(start_line, end_line)
  vim.fn.setreg("+", text)
  vim.notify("Copied: " .. text, vim.log.levels.INFO)
end

local function send_file_reference_to_tmux(start_line, end_line)
  local text = build_file_reference(start_line, end_line)
  local panes = vim.fn.systemlist("tmux list-panes -F '#{pane_index} #{pane_title}' -f '#{?pane_active,0,1}'")
  if vim.v.shell_error ~= 0 then
    return vim.notify("tmux is not running", vim.log.levels.ERROR)
  end
  require("fzf-lua").fzf_exec(panes, {
    prompt = "Pane> ",
    preview = "tmux capture-pane -t {1} -p -e -S - | tail -20",
    fzf_opts = { ["--ansi"] = "" },
    actions = {
      ["default"] = function(selected)
        local target = selected[1]:match("^(%S+)")
        vim.fn.system(
          string.format("tmux send-keys -t %s %s && tmux select-pane -t %s", target, vim.fn.shellescape(text), target)
        )
        vim.notify("Sent to pane " .. target .. ": " .. text, vim.log.levels.INFO)
      end,
    },
  })
end

keymap("n", "<LEADER>yf", copy_file_reference, opts.silent)
keymap("x", "<LEADER>yf", function()
  local s, e = vim.fn.line("v"), vim.fn.line(".")
  copy_file_reference(math.min(s, e), math.max(s, e))
end, opts.silent)
keymap("n", "<LEADER>sf", send_file_reference_to_tmux, opts.silent)
keymap("x", "<LEADER>sf", function()
  local s, e = vim.fn.line("v"), vim.fn.line(".")
  send_file_reference_to_tmux(math.min(s, e), math.max(s, e))
end, opts.silent)
