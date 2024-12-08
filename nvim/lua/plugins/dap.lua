local M = require("my_module")
local mode = { silent = true }

M.keymap("n", "<LEADER>du", ":lua require('dapui').toggle()<CR>", mode)
M.keymap("n", "<LEADER>db", ":<C-u>DapToggleBreakpoint<CR>", mode)
M.keymap("n", "<LEADER>dc", ":<C-u>DapContinue<CR>", mode)
M.keymap("n", "<LEADER>dso", ":<C-u>DapStepOver<CR>", mode)
M.keymap("n", "<LEADER>dsi", ":<C-u>DapStepInto<CR>", mode)
M.keymap("n", "<LEADER>dsi", ":<C-u>DapStepOut<CR>", mode)

local dap = require("dap")
require("dapui").setup()

-- Python
local path_of_python = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
require("dap-python").setup(path_of_python)

-- Rust
dap.adapters = {
  codelldb = {
    type = "server",
    port = "${port}",
    executable = {
      command = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb",
      args = { "--port", "${port}" },
    },
  },
}
dap.configurations = {
  rust = {
    {
      type = "codelldb",
      request = "launch",
      program = function()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
    },
  },
}
