local function create_autocmd_group(name, autocmds)
  local group = vim.api.nvim_create_augroup(name, { clear = true })
  for _, autocmd in ipairs(autocmds) do
    vim.api.nvim_create_autocmd(autocmd.event, vim.tbl_extend("force", autocmd.opts, { group = group }))
  end
end

-- LSP formatting on save
create_autocmd_group("FileTypeIndent", {
  {
    event = "BufWritePre",
    opts = {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({
          bufnr = bufnr,
          filter = function(lsp_client)
            return lsp_client.name == "null-ls"
          end,
        })
      end,
    },
  },
})

-- Restore cursor position
create_autocmd_group("Extends", {
  {
    event = "BufRead",
    opts = {
      pattern = "*",
      callback = function()
        if vim.fn.line("'\"") > 0 and vim.fn.line("'\"") <= vim.fn.line("$") then
          vim.api.nvim_command('normal g`"')
        end
      end,
    },
  },
})

-- Oil.nvim relative path fix
create_autocmd_group("OilRelPathFix", {
  {
    event = "BufLeave",
    opts = {
      pattern = "oil:///*",
      callback = function()
        vim.cmd("cd .")
      end,
    },
  },
})

-- fzf-specific keymaps
create_autocmd_group("FzfKeymaps", {
  {
    event = "FileType",
    opts = {
      pattern = "fzf",
      callback = function()
        vim.keymap.set("t", "<C-j>", "<Down>", { buffer = true, silent = true })
        vim.keymap.set("t", "<C-k>", "<Up>", { buffer = true, silent = true })
      end,
    },
  },
})

-- blink.cmp completion menu keymaps
create_autocmd_group("BlinkCmpKeymaps", {
  {
    event = "User",
    opts = {
      pattern = "BlinkCmpMenuOpen",
      callback = function()
        vim.keymap.set("i", "<C-j>", function()
          require('blink.cmp').select_next()
        end, { buffer = true, silent = true })
        vim.keymap.set("i", "<C-k>", function()
          require('blink.cmp').select_prev()
        end, { buffer = true, silent = true })
      end,
    },
  },
  {
    event = "User",
    opts = {
      pattern = "BlinkCmpMenuClose",
      callback = function()
        pcall(vim.keymap.del, "i", "<C-j>", { buffer = true })
        pcall(vim.keymap.del, "i", "<C-k>", { buffer = true })
      end,
    },
  },
})
