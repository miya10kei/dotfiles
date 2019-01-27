set encoding=utf-8

"### encoding settings ###
scriptencoding utf-8
set fileencoding=utf-8
set fileencodings=utf-8


"### display settings ###
set ambiwidth=double
set cursorline
set laststatus=2
set number
set showmatch
set title
syntax on


"### tab/indent settings ###
set autoindent
set expandtab
set shiftwidth=2
set smartindent
set softtabstop=2
set tabstop=2


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

