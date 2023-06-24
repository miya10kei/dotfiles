local autocmd = vim.api.nvim_create_autocmd
local fn = vim.fn
local keymap = vim.keymap.set

vim.fn['ddu#custom#patch_global']({
    ui = 'ff',
    sources = {
        {
            name = 'file'
        },
    },
    sourceOptions = {
        _ = {
            matchers = { 'matcher_fzf' },
            sorters = { 'sorter_fzf' }
        },
    },
    kindOptions = {
        file = {
            defaultAction = 'open',
        },
        word = {
            defaultAction = 'append',
        }
    },
    filterParams = {
        matcher_fzf = {
            highlightMatched = 'Search'
        }
    },
    uiParams = {
        ff = {
            autoAction = { name = 'preview' },
            filterFloatingPosition = 'top',
            floatingBorder = 'double',
            ignoreEmpty = true,
            previewFloating = true,
            previewFloatingBorder = 'double',
            previewSplit = 'vertical',
            prompt = '> ',
            split = 'floating',
            startFilter = true,
        }
    },
})


local function resize()
    local function to_nearest_even(val)
        return math.floor(val / 2) * 2
    end
    local lines = vim.opt.lines:get()
    local columns = vim.opt.columns:get()
    --local lines = to_nearest_even(vim.api.nvim_win_get_height(0))
    --local columns = to_nearest_even(vim.api.nvim_win_get_width(0))
    local height = to_nearest_even(lines * 0.8)
    local width = to_nearest_even(columns * 0.4)

    vim.fn['ddu#custom#patch_global']('uiParams',{
        ff = {
            winHeight = height,
            winWidth = width,
            winCol = to_nearest_even(width * 0.1),
            winRow = to_nearest_even(height * 0.2),
            previewHeight = height,
            previewWidth = width,
            previewCol = to_nearest_even(width * 0.2),
            --previewRow  = math.floor(vim.opt.lines:get() * 0.08),
        }
    })
end

local M = {}

function M.ddu__file_rec()
  vim.fn['ddu#start']({
      sources = {
          {
              name = 'file_rec',
              path = vim.fn.expand('~'),
              params = {
                  ignoredDirectories = { '.git', '.gradle', 'node_modules', '__pycache__' }
              }
          },
      },
  })
end

function M.ddu__buffer()
    vim.fn['ddu#start']({
        sources = {
            {
                name = 'buffer'
            },
        },
        uiParams = {
            ff = {
                startFilter = false,
            }
        },
    })
end

function M.ddu__register()
    vim.fn['ddu#start']({
        sources = {
            { name = 'register' },
        },
        uiParams = {
            ff = {
                startFilter = false,
            }
        },
    })
end

function M.ddu__grep()
    vim.fn['ddu#start']({
        sources = {
            {
                name = 'rg',
            }
        },
        sourceOptions = {
            rg = {
                volatile = true,
                matchers = { 'matcher_kensaku' },
            },
        },
        sourceParams = {
            rg = {
                args = { '--json' },
                inputType = 'migemo',
            }
        },
        uiParams = {
            ff = {
                ignoreEmpty = false,
            }
        },
    })
end

function M.ddu__lsp_call_hierarchy()
    vim.fn['ddu#start']({
        kindOptions = {
            lsp = {
                defaultAction = 'open',
            }
        },
        sources = {
            {
                name = 'lsp_callHierarchy',
                params = {
                    method = 'callHierarchy/incomingCalls',
                }
            }
        },
        uiParams = {
            ff = {
                displayTree = true,
                startFilter = false,
            }
        }
    })
end

function M.ddu__lsp_references()
    vim.fn['ddu#start']({
        kindOptions = {
            lsp = {
                defaultAction = 'open',
            }
        },
        sources = {
            {
                name = 'lsp_references',
            }
        },
    })
end

function M.ddu__filer()
    vim.fn['ddu#start']({
        ui = 'filer',
        searchPath = vim.fn.getcwd(),
        sources = {
            {
                name = 'file',
            },
        },
        sourceOptions = {
            file = {
                columns = { 'icon_filename' },
            },
        },
        actionOptions = {
            narrow = {
                quit = false
            }
        },
        uiParams = {
            filer = {
                previewSplit = 'no',
                sortTreesFirst = true,
                split = 'vertical',
                statusline = false,
                winWidth = fn.winwidth(0) / 3,
            }
        }
    })
end

---------------------
--- User Commands ---
---------------------

vim.api.nvim_create_user_command(
    'Ddu',
    function(opts)
        local subcomand = opts.fargs[1]
        vim.fn['ddu#ui#do_action']('quit')
        resize()
        M[subcomand]()
    end,
    { nargs=1 }
)


--------------------
--- Autocommands ---
--------------------

autocmd({ 'FileType' }, {
    pattern = { 'ddu-ff' },
    callback = function()
        local action = fn['ddu#ui#do_action']
        local bufopts = { buffer = true, silent = true }
        keymap('n', '<CR>', function() action('itemAction') end, bufopts)
        keymap('n', '<SPACE>', function() action('toggleSelectItem') end, bufopts)
        keymap('n', 'i', function() action('openFilterWindow') end, bufopts)
        keymap('n', 'p', function() action('preview') end, bufopts)
        keymap('n', 'q', function() action('quit') end, bufopts)
        keymap('n', 'yy', function() action('itemAction', { name = 'yank' }) end, bufopts)
    end
})

autocmd({ 'FileType' }, {
    pattern = { 'ddu-ff-filter' },
    callback = function()
        local close_action = function() fn['ddu#ui#do_action']('closeFilterWindow') end
        local bufops = { buffer = true, silent = true }
        keymap('i', '<CR>', '<ESC><CMD>call ddu#ui#do_action(\'closeFilterWindow\')<CR>', bufops)
        keymap('n', '<CR>', close_action, bufops)
        keymap('n', 'q', close_action, bufops)
    end
})

autocmd({ 'FileType' }, {
    pattern = { 'ddu-filer' },
    callback = function()
        local action = fn['ddu#ui#do_action']
        local bufopts = { buffer = true, silent = true }
        keymap('n', '<CR>', function()
            if fn['ddu#ui#get_item']()['isTree'] == true then
                action('itemAction', { name = 'narrow' })
            else
                action('itemAction', { name = 'open' })
            end
        end, bufopts)
        keymap('n', 'cp', function() action('itemAction', { name = 'copy' }) end, bufopts)
        keymap('n', 'mk', function() action('itemAction', { name = 'newDirectory' }) end, bufopts)
        keymap('n', 'mv', function() action('itemAction', { name = 'move' }) end, bufopts)
        keymap('n', 'nf', function() action('itemAction', { name = 'newFile' }) end, bufopts)
        keymap('n', 'o',  function() action('expandItem', { mode = 'toggle' }) end, bufopts)
        keymap('n', 'pt', function() action('itemAction', { name = 'paste' }) end, bufopts)
        keymap('n', 'q',  function() action('quit') end, bufopts)
        keymap('n', 'rm', function() action('itemAction', { name = 'delete' }) end, bufopts)
        keymap('n', 'rn', function() action('itemAction', { name = 'rename' }) end, bufopts)
        keymap('n', 's',  function() action('toggleSelectItem') end, bufopts)
        keymap('n', 'uu', function() action('itemAction', { name = 'narrow', params = { path = '..' } }) end, bufopts)
        keymap('n', '..', function() action('itemAction', { name = 'narrow', params = { path = '..' } }) end, bufopts)
        keymap('n', 'p',  function() action('preview') end, bufopts)
    end
})

local dduAutogroup = vim.api.nvim_create_augroup('Ddu', {})
vim.api.nvim_clear_autocmds({ group = dduAutogroup })
vim.api.nvim_create_autocmd({ 'WinResized' }, {
    group = dduAutogroup,
    pattern = { '*' },
    callback = function()
        resize()
    end
})
