local autocmd = require("utils.autocmd")

---------------------
--- User Commands ---
---------------------
vim.api.nvim_create_user_command("Jq", function()
  vim.cmd("%!jq '.'")
end, {})

---------------------
--- Autocommands ---
---------------------
autocmd.create_group("vimrc-checktime", {
  {
    event = { "BufEnter", "FocusGained", "TermClose", "TermLeave" },
    opts = {
      command = "checktime",
    },
  },
})
