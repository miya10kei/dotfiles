---@type LazySpec
return {
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
      "mfussenegger/nvim-dap-python",
    },
    config = function()
      print("called1")
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
    end,
    keys = {
      {
        "<LEADER>du",
        function()
          -- print("called2")
          -- require("dapui").toggle()
        end,
        mode = "n",
        silent = true,
        desc = "Dap: Toggle UI",
      },
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        mode = "n",
        desc = "Dap: Toggle Breakpoint",
      },
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        mode = "n",
        desc = "Dap: Continue",
      },
      {
        "<leader>dso",
        function()
          require("dap").step_over()
        end,
        mode = "n",
        desc = "Dap: Step Over",
      },
      {
        "<leader>dsi",
        function()
          require("dap").step_into()
        end,
        mode = "n",
        desc = "Dap: Step Into",
      },
      {
        "<leader>dso",
        function()
          require("dap").step_out()
        end,
        mode = "n",
        desc = "Dap: Step Out",
      },
    },
  },
}
