local M = {}
local api = vim.api
local autocmd = api.nvim_create_autocmd
local fn = vim.fn
local keymap = vim.keymap.set
local opt = vim.opt

---------------------
--- Base Settings ---
---------------------
fn["ddu#custom#patch_global"]({
  ui = "ff",
  sourceOptions = {
    _ = {
      matchers = {
        "matcher_fzf",
      },
      sorters = {
        "sorter_fzf",
      },
    },
  },
  kindOptions = {
    file = {
      defaultAction = "open",
    },
    word = {
      defaultAction = "append",
    },
  },
  filterParams = {
    matcher_fzf = {
      highlightMatched = "Search",
    },
  },
  uiParams = {
    ff = {
      autoAction = {
        name = "preview",
      },
      startAutoAction = true,
      floatingBorder = "double",
      ignoreEmpty = true,
      previewFloating = true,
      previewFloatingBorder = "double",
      previewSplit = "vertical",
      prompt = "> ",
      split = "floating",
    },
  },
})

-----------------
--- Functions ---
-----------------
function M.ddu__file_rec()
  fn["ddu#start"]({
    sources = {
      {
        name = "file_rec",
        params = {
          ignoredDirectories = {
            ".git",
            ".gradle",
            ".next",
            ".terraform",
            ".tmux",
            ".venv",
            "__pycache__",
            "data-volume",
            "node_modules",
            "python3.11",
          },
        },
      },
    },
    sourceOptions = {
      file_rec = {
        path = fn.getcwd(),
      },
    },
    uiParams = {
      ff = {
        ignoreEmpty = true,
      },
    },
  })
end

function M.ddu__buffer()
  fn["ddu#start"]({
    sources = {
      {
        name = "buffer",
      },
    },
  })
end

function M.ddu__register()
  fn["ddu#start"]({
    sources = {
      {
        name = "register",
      },
    },
  })
end

function M.ddu__grep()
  fn["ddu#start"]({
    sources = {
      { name = "rg" },
    },
    sourceParams = {
      rg = {
        args = { "--json", "-i" },
        input = fn.input("Pattern: "),
      },
    },
    uiParams = {
      ff = {
        autoAction = { name = "preview" },
        startAutoAction = true,
        ignoreEmpty = true,
      },
    },
  })
end

function M.ddu__grep_current_file()
  fn["ddu#start"]({
    sources = { { name = "rg" } },
    sourceParams = {
      rg = {
        args = {
          "--json",
          "-i",
        },
        paths = { fn.expand("%") },
        input = fn.input("Pattern: "),
      },
    },
    uiParams = {
      ff = {
        autoAction = {
          name = "preview",
        },
        startAutoAction = true,
        ignoreEmpty = true,
      },
    },
  })
end

function M.ddu__lsp_definition()
  fn["ddu#start"]({
    kindOptions = {
      lsp = {
        defaultAction = "open",
      },
    },
    sources = {
      {
        name = "lsp_definition",
      },
    },
    sync = true,
    uiParams = {
      ff = {
        immediateAction = "open",
      },
    },
  })
end

function M.ddu__lsp_call_hierarchy()
  fn["ddu#start"]({
    kindOptions = {
      lsp = {
        defaultAction = "open",
      },
    },
    sources = {
      {
        name = "lsp_callHierarchy",
        params = {
          method = "callHierarchy/incomingCalls",
        },
      },
    },
    uiParams = {
      ff = {
        displayTree = true,
      },
    },
  })
end

function M.ddu__lsp_references()
  fn["ddu#start"]({
    kindOptions = {
      lsp = {
        defaultAction = "open",
      },
    },
    sources = {
      {
        name = "lsp_references",
      },
    },
  })
end

function M.ddu__lsp_workspace()
  fn["ddu#start"]({
    sources = {
      {
        name = "lsp_workspaceSymbol",
      },
    },
    sourceOptions = {
      lsp = {
        volatile = true,
      },
    },
    uiParams = {
      ff = {
        ignoreEmpty = false,
      },
    },
  })
end

function M.ddu__filer()
  fn["ddu#start"]({
    actionOptions = {
      narrow = {
        quit = false,
      },
    },
    searchPath = fn.expand("%:p"),
    sources = {
      {
        name = "file",
      },
    },
    sourceOptions = {
      file = {
        columns = {
          "icon_filename",
        },
        path = fn.getcwd(),
      },
    },
    sync = true,
    ui = "filer",
    uiParams = {
      filer = {
        previewSplit = "no",
        sort = "filename",
        sortTreesFirst = true,
        split = "vertical",
        statusline = false,
        winCol = 1,
        winWidth = fn.winwidth(0) / 3,
      },
    },
  })
end

-----------------------
--- Local Functions ---
-----------------------
local function resize()
  local function to_nearest_even(val)
    return math.floor(val / 2) * 2
  end
  local lines = opt.lines:get()
  local columns = opt.columns:get()
  local height = to_nearest_even(lines * 0.2)
  local width = to_nearest_even(columns * 0.9)

  fn["ddu#custom#patch_global"]("uiParams", {
    ff = {
      winHeight = height,
      winWidth = width,
      winCol = to_nearest_even(width * 0.05),
      winRow = to_nearest_even(height * 0.6),
      previewHeight = height * 2,
      previewWidth = width,
      previewCol = to_nearest_even(width * 0.05),
      previewRow = to_nearest_even(height * 1.8),
    },
  })
end

---------------------
--- User Commands ---
---------------------
api.nvim_create_user_command("Ddu", function(opts)
  local subcomand = opts.fargs[1]
  fn["ddu#ui#do_action"]("quit")
  resize()
  M[subcomand]()
end, {
  nargs = 1,
})

--------------------
--- Autocommands ---
--------------------
autocmd({
  "FileType",
}, {
  pattern = { "ddu-ff" },
  callback = function()
    local action = fn["ddu#ui#do_action"]
    local bufopts = { buffer = true, silent = true }
    keymap("n", "<CR>", function()
      action("itemAction")
    end, bufopts)
    keymap("n", "<SPACE>", function()
      action("toggleSelectItem")
    end, bufopts)
    keymap("n", "i", function()
      action("openFilterWindow")
    end, bufopts)
    keymap("n", "p", function()
      action("preview")
    end, bufopts)
    keymap("n", "q", function()
      action("quit")
    end, bufopts)
    keymap("n", "yy", function()
      action("itemAction", { name = "yank" })
    end, bufopts)
  end,
})

autocmd({ "FileType" }, {
  pattern = { "ddu-ff-filter" },
  callback = function()
    local close_action = function()
      fn["ddu#ui#do_action"]("closeFilterWindow")
    end
    local bufops = { buffer = true, silent = true }
    keymap("i", "<CR>", "<ESC><CMD>call ddu#ui#do_action('closeFilterWindow')<CR>", bufops)
    keymap("n", "<CR>", close_action, bufops)
    keymap("n", "q", close_action, bufops)
  end,
})

autocmd({ "FileType" }, {
  pattern = { "ddu-filer" },
  callback = function()
    local action = fn["ddu#ui#do_action"]
    local bufopts = { buffer = true, silent = true }
    keymap("n", "<CR>", function()
      if fn["ddu#ui#get_item"]()["isTree"] == true then
        action("itemAction", { name = "narrow" })
      else
        action("itemAction", { name = "open" })
      end
    end, bufopts)
    keymap("n", "cp", function()
      action("itemAction", { name = "copy" })
    end, bufopts)
    keymap("n", "mk", function()
      action("itemAction", { name = "newDirectory" })
    end, bufopts)
    keymap("n", "mv", function()
      action("itemAction", { name = "move" })
    end, bufopts)
    keymap("n", "nf", function()
      action("itemAction", { name = "newFile" })
    end, bufopts)
    keymap("n", "o", function()
      action("expandItem", { mode = "toggle" })
    end, bufopts)
    keymap("n", "pt", function()
      action("itemAction", { name = "paste" })
    end, bufopts)
    keymap("n", "q", function()
      action("quit")
    end, bufopts)
    keymap("n", "rm", function()
      action("itemAction", { name = "delete" })
    end, bufopts)
    keymap("n", "rn", function()
      action("itemAction", { name = "rename" })
    end, bufopts)
    keymap("n", "s", function()
      action("toggleSelectItem")
    end, bufopts)
    keymap("n", "uu", function()
      action("itemAction", { name = "narrow", params = { path = ".." } })
    end, bufopts)
    keymap("n", "..", function()
      action("itemAction", { name = "narrow", params = { path = ".." } })
    end, bufopts)
    keymap("n", "p", function()
      action("preview")
    end, bufopts)
  end,
})

autocmd({ "TabEnter", "WinEnter", "CursorHold", "FocusGained" }, {
  pattern = { "*" },
  callback = function()
    fn["ddu#ui#do_action"]("checkItems")
  end,
})

local dduAutogroup = api.nvim_create_augroup("Ddu", {})
api.nvim_clear_autocmds({ group = dduAutogroup })
api.nvim_create_autocmd({ "WinResized" }, {
  group = dduAutogroup,
  pattern = {
    "*",
  },
  callback = function()
    resize()
  end,
})
