---@type LazySpec
return {
  {
    "Shougo/pum.vim",
    enabled = false,
    config = function()
      vim.fn["pum#set_option"]({
        border = "none",
        max_height = 10,
        scrollbar_char = "",
        preview = true,
        preview_delay = 0,
      })
    end,
    keys = {
      {
        "<CR>",
        function()
          if vim.fn["pum#visible"]() then
            return vim.fn["pum#map#confirm"]()
          else
            return vim.api.nvim_feedkeys(require("nvim-autopairs").autopairs_cr(), "in", true)
          end
        end,
        mode = { "i" },
      },
      {
        "<TAB>",
        function()
          if vim.fn["pum#visible"]() then
            return vim.fn["pum#map#select_relative"](1)
          else
            local line = vim.api.nvim_get_current_line()
            local col = vim.fn.col(".")
            if col <= 1 or line:sub(col - 2):match("%s") then
              return "<C-t>"
            else
              return vim.fn["ddc#map#manual_complete"]()
            end
          end
        end,
        mode = { "i" },
      },
      {
        "<S-TAB>",
        function()
          if vim.fn["pum#visible"]() then
            return vim.fn["pum#map#select_relative"](-1)
          else
            return "<C-h>"
          end
        end,
        mode = { "i" },
      },
    },
  },
}
