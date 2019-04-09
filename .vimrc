set encoding=utf-8

"### encoding settings ###
scriptencoding utf-8
set fileencoding=utf-8
set fileencodings=utf-8


"### color settings ###
colorscheme molokai
if has('mac')
  set termguicolors
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif


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
set cindent
set softtabstop=2
set tabstop=2
set fileformats=unix,dos,mac
set binary noeol
set list
set listchars=tab:»-,trail:-,eol:↲,extends:»,precedes:«,nbsp:%
hi NonText    ctermbg=NONE ctermfg=59 guibg=NONE guifg=NONE
hi SpecialKey ctermbg=NONE ctermfg=59 guibg=NONE guifg=NONE


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
Plug 'vim-airline/vim-airline'
Plug 'Shougo/neocomplete.vim'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'szw/vim-tags'
Plug 'ngmy/vim-rubocop'
Plug 'scrooloose/syntastic'
Plug 'othree/html5.vim'
Plug 'gorodinskiy/vim-coloresque'
call plug#end()

"### neocomplete.vim ###
if has('lua') && v:version > 703
  " Disable AutoComplPop.
  let g:acp_enableAtStartup = 0
  " Use neocomplete.
  let g:neocomplete#enable_at_startup = 1
  " Use smartcase.
  let g:neocomplete#enable_smart_case = 1
  if !exists('g:neocomplete#force_omni_input_patterns')
    let g:neocomplete#force_omni_input_patterns = {}
  endif
  let g:neocomplete#force_omni_input_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'
  inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
  inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"
  inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
endif

"### vim-indent-guides.vim
let g:indent_guides_enable_on_vim_startup = 1

"### fzf.vim ###
let g:mapleader=' '
nmap <Leader> [Fzf]
nnoremap [Fzf]<Space> :<C-u>Files<CR>

"### syntastic ###
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
let g:syntastic_mode_map = { 'mode': 'passive', 'passive_filetypes': ['ruby']  }
let g:syntastic_ruby_checkers=['rubocop']
nnoremap <C-l> :w<CR>:SyntasticCheck<CR>


"### html5.vim ###
let g:html5_event_handler_attributes_complete = 1
let g:html5_rdfa_attributes_complete = 1
let g:html5_microdata_attributes_complete = 1
let g:html5_aria_attributes_complete = 1

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
