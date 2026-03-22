---@type LazySpec
return {
  {
    "hedyhli/outline.nvim",
    lazy = true,
    cmd = { "Outline", "OutlineOpen" },
    keys = {
      { "<leader>to", "<cmd>Outline<CR>", desc = "Toggle outline" },
    },
    opts = {
      outline_window = {
        focus_on_open = true,
      },
      symbol_folding = {
        autofold_depth = false,
      },
      guides = {
        enabled = true,
      },
      keymaps = {
        down_and_jump = "j",
        up_and_jump = "k",
      },
    },
  },
}
