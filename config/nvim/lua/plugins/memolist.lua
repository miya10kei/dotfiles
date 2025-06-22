---@type LazySpec
return {
  {
    "glidenote/memolist.vim",
    config = function()
      vim.g.memolist_path = vim.fn.expand("~/Documents/memo")
      vim.g.memolist_template_dir_path = vim.fn.expand("~/.config/memo")
    end,
    keys = {
      {
        "<LEADER>ml",
        "<ESC><CMD>MemoList<CR>",
        mode = { "n" },
        desc = "MemoList: Open memo list",
      },
      {
        "<LEADER>mn",
        "<ESC><CMD>MemoNew<CR>",
        mode = { "n" },
        desc = "MemoList: Open new memo",
      },
    },
  },
}
