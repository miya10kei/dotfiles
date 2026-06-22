return {
  "polarmutex/git-worktree.nvim",
  version = "^2",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope.nvim",
      branch = "0.1.x",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      opts = {
        defaults = {
          mappings = {
            i = {
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",
            },
          },
        },
      },
    },
  },
  config = function()
    local Hooks = require("git-worktree.hooks")
    Hooks.register(Hooks.type.SWITCH, function(path, prev_path)
      Hooks.builtins.update_current_buffer_on_switch(path, prev_path)
      require("utils.worktree").refresh()
    end)
    require("telescope").load_extension("git_worktree")
  end,
  keys = {
    {
      "<leader>gw",
      function()
        require("telescope").extensions.git_worktree.git_worktree()
      end,
      desc = "Switch git worktree",
    },
    {
      "<leader>gW",
      function()
        require("telescope").extensions.git_worktree.create_git_worktree()
      end,
      desc = "Create git worktree",
    },
  },
}
