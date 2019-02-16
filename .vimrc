set encoding=utf-8

"### encoding settings ###
scriptencoding utf-8
set fileencoding=utf-8
set fileencodings=utf-8


"### display settings ###
set ambiwidth=double
set cursorline
set cursorcolumn
set laststatus=2
set number
set showmatch
set title
syntax on


"### tab/indent/separate settings ###
set autoindent
set expandtab
set shiftwidth=2
set smartindent
set softtabstop=2
set tabstop=2
set fileformats=unix,dos,mac

"### search settings ###
set hlsearch
set ignorecase
set incsearch
set smartcase
set wrapscan


"### command settings ###
set history=5000
set showcmd
set wildmenu


"### file settings ###
set autoread
set confirm
set hidden
set nobackup
set noswapfile


"### input settings
set wildmode=list:longest


"### key settings ###
nnoremap <down> gj
nnoremap <up> gk
nnoremap j gj
nnoremap k gk
inoremap <silent> jj <ESC>
set backspace=indent,eol,start
set virtualedit=onemore
source $VIMRUNTIME/macros/matchit.vim

if has('mouse')
  set mouse=a
  if has('mouse_sgr')
    set ttymouse=sgr
  elseif v:version > 703 || v:version is 703 && has('patch632')
    set ttymouse=sgr
  else
   set ttymouse=xterm2
  endif
endif

if &term =~ "xterm"
  let &t_SI .= "\e[?2004h"
  let &t_EI .= "\e[?2004l"
  let &pastetoggle = "\e[201~"
  function XTermPasteBegin(ret)
    set paste
    return a:ret
  endfunction
  inoremap <special> <expr> <Esc>[200~ XTermPasteBegin("")
endif

"### function settings ###
set clipboard=unnamed,autoselect
autocmd BufWritePre * :%s/\s\+$//ge

"### Plugin ###
call plug#begin('~/.vim/plugged')

Plug 'Shougo/neocomplcache.vim'
Plug 'Shougo/neocomplcache-rsense.vim'
Plug 'https://github.com/tpope/vim-endwise.git'

call plug#end()

"### neocomplcache settings ###
let g:acp_enableAtStartup = 0 "Disable AutoComplePop
let g:neocomplcache_enable_at_startup = 1 "Use rneocomplcache
let g:neocomplcache_enable_smart_case = 1 " Use smartcase
let g:neocomplcache_min_syntax_length = 3 " Set minimum syntax keyword length.
let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'
let g:neocomplcache_keyword_patterns['default'] = '\h\w*' " Don't cache Japanese
let g:neocomplcache_enable_camel_case_completion = 1 "Use camel case completion
let g:neocomplcache_enable_underbar_completion = 1 " Use underbar completion.
if !exists('g:neocomplcache_omni_patterns')
    let g:neocomplcache_omni_patterns = {}
endif
let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'

"### Rsense settings ###
let g:rsenseHome = expand("/home/miya10kei/.rbenv/shims/rsense")
let g:rsenseUseOmniFunc = 1
