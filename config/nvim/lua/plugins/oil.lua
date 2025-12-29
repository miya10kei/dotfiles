---@type LazySpec
return {
  {
    'stevearc/oil.nvim',
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
      columns = {
        "icon",
        "permissions",
        "size",
        "mtime",
      },
      view_options = {
        show_hidden = true,
      },
      float  = {
          border = "rounded",
          preview_split =  "below",
          max_width = 0.8,
          max_height = 0.8,
      },
      keymaps = {
        [".."] = "actions.parent",
      },
      lsp_file_methods = {
        autosave_changes = true,
      },
      watch_for_changes = true,
    },
    keys = {
      {
        "<LEADER>o",
        function()
          require("oil").open_float(nil, {
            preview = {
              vertical = false,
              horizontal = true,
              split = "belowright"
            }
          })
        end,
        desc = "Toggle oil floating window",
      },
    },
  }
}
