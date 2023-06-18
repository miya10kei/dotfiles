local autocmd = vim.api.nvim_create_autocmd
local fn = vim.fn
local keymap = vim.keymap.set

vim.fn['ddu#custom#patch_global']({
    ui = 'ff',
    sources = {
        { name = 'file' },
    },
    sourceOptions = {
        _ = {
            matchers = { 'matcher_substring' },
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
    uiParams = {
        ff = {
            autoAction = { name = 'preview' },
            floatingBorder = 'double',
            previewSplit = 'no',
            previewWidth = fn.winwidth(0) / 3,
            prompt = '> ',
            split = 'floating',
            startFilter = true,
        }
    },
})

vim.fn['ddu#custom#patch_local']('file_rec', {
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

vim.fn['ddu#custom#patch_local']('buffer', {
    sources = {
        { name = 'buffer' },
    },
    uiParams = {
        ff = {
            startFilter = false,
        }
    },
})

vim.fn['ddu#custom#patch_local']('register', {
    sources = {
        { name = 'register' },
    },
    uiParams = {
        ff = {
            startFilter = false,
        }
    },
})

vim.fn['ddu#custom#patch_local']('filer', {
    ui = 'filer',
    sources = {
        {
            name = 'file',
        },
    },
    sourceOptions = {
        _ = {
            columns = { 'icon_filename' },
        },
    },
    actionOptions = {
        narrow = { quit = false }
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

vim.fn['ddu#custom#patch_local']('grep', {
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
    }
})

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
