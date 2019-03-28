set encoding=utf-8

"### encoding settings ###
scriptencoding utf-8
set fileencoding=utf-8
set fileencodings=utf-8


"### color settings ###
set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"


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
Plug 'https://github.com/tpope/vim-endwise.git'
Plug 'othree/yajs.vim'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'cohama/lexima.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'kaicataldo/material.vim'
Plug 'vim-airline/vim-airline'
call plug#end()

"### material.vim ###
set background=dark
colorscheme material
let g:airline_theme = 'material'
if (has("nvim"))
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif
if (has("termguicolors"))
  set termguicolors
endif

"### fzf.vim ###
let g:mapleader=' '
nmap <Leader> [Fzf]
nnoremap [Fzf]<Space> :<C-u>Files<CR>

augroup MyXML
  autocmd!
  autocmd Filetype xml inoremap <buffer> </ </<C-x><C-o>
  autocmd Filetype html inoremap <buffer> </ </<C-x><C-o>
  autocmd Filetype eruby inoremap <buffer> </ </<C-x><C-o>
augroup END

augroup vimrcEx
  au BufRead * if line("'\"") > 0 && line("'\"") <= line("$") |
  \ exe "normal g`\"" | endif
augroup END
