" -------------------------
" --- Encoding settings ---
" -------------------------
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8,ucs-boms,euc-jp,cp932
set termencoding=utf-8
scriptencoding utf-8
let mapleader = "\<C-w>"

" ------------------------
" --- Install vim-plug ---
" ------------------------
if has('vim_starting')
  set runtimepath+=~/.config/nvim/plugged/vim-plug
  if !isdirectory(expand('$NVIM_HOME') . '/plugged/vim-plug')
    call system('mkdir -p ~/.config/nvim/plugged/vim-plug')
    call system('git clone https://github.com/junegunn/vim-plug.git ~/.config/nvim/plugged/vim-plug/autoload')
  end
endif


" ----------------------
" --- Install plugin ---
" ----------------------
call plug#begin('~/.vim/plugged')
Plug 'itchyny/lightline.vim'
Plug 'scrooloose/nerdtree'
Plug 'posva/vim-vue'
Plug 'cohama/lexima.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'https://github.com/nicwest/vim-camelsnek.git'
Plug 'tmux-plugins/vim-tmux'
Plug 'glidenote/memolist.vim'
Plug 'tpope/vim-surround'
" --- fish
Plug 'dag/vim-fish'
" --- markdown
Plug 'godlygeek/tabular', { 'for': 'markdown' }
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }
Plug 'kannokanno/previm', {'for': 'markdown'}
" --- TypeScript
Plug 'leafgarland/typescript-vim'
" --- vue
Plug 'posva/vim-vue', {'for': 'vue'}
" --- GraphQL
Plug 'jparise/vim-graphql'
" --- Language Server Protocol
Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()

" -----------------------
" --- Plugin settings ---
" -----------------------

" --------------------------------
" ------ lightline settings ------
" --------------------------------

" --- color settings ---
let g:lightline = { 'colorscheme': 'jellybeans' }
let g:lightline.active = {
    \ 'left': [ [ 'mode', 'paste' ],
    \           [ 'readonly', 'filepath', 'modified' ] ],
    \ 'right': [ [ 'lineinfo' ],
    \            [ 'percent' ],
    \            [ 'fileformat', 'fileencoding', 'filetype' ] ] }
let g:lightline.inactive = {
    \ 'left': [ [ 'filepath' ] ],
    \ 'right': [ [ 'lineinfo' ],
    \            [ 'percent' ] ] }
let g:lightline.component_function = { 'filepath': 'LightLineFilepath' }

function! LightLineFilepath()
  return expand('%')
endfunction

" -------------------------------
" ------ NERDTree settings ------
" -------------------------------

" --- hidden status line
let g:NERDTreeStatusline = '%#NonText#'
" --- close tree after opening file
let g:NERDTreeQuitOnOpen=1
" --- show dotfile
let NERDTreeShowHidden=1
" --- toggle NERDTree
nnoremap <C-t> :<C-u>NERDTreeToggle<CR>

augroup nerd_tree
  autocmd!
  " --- close NERDTree tab if other bufferes is closed
  autocmd bufenter * if (winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree()) | q | endif
augroup END

" -----------------------------
" --- vim-markdown settings ---
" -----------------------------
" --- disable folding
let g:vim_markdown_folding_disabled = 1


" --------------
" --- previm ---
" --------------
let g:previm_open_cmd = 'open -a Google\ Chrome'


" -----------
" --- fzf ---
" -----------
nnoremap <silent> <C-e> :<C-u>:GFiles<CR>
nnoremap <silent> <Leader><C-e> :<C-u>:Files<CR>
nnoremap <silent> <C-p> :<C-u>:Buffers<CR>

" [Buffers] Jump to the existing window if possible
let g:fzf_buffers_jump = 1
"
" ripgrepで検索中、?を押すとプレビュー:
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

" Filesコマンドにもプレビューを出す
command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

" ----------------
" --- memolist ---
" ----------------
let g:memolist_path = "~/Documents/memo"
nnoremap <Leader>mn  :MemoNew<CR>
nnoremap <Leader>ml  :MemoList<CR>
nnoremap <Leader>mg  :MemoGrep<CR>

" --------------------------------
" --- coc(Language Server Procotol) ---
" --------------------------------
" if hidden is not set, TextEdit might fail.
set hidden

" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

" Better display for messages
set cmdheight=2

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

" don't give |ins-completion-menu| messages.
set shortmess+=c

" always show signcolumns
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" Or use `complete_info` if your vim support it, like:
" inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Create mappings for function text object, requires document symbols feature of languageserver.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

" Use <TAB> for select selections ranges, needs server support, like: coc-tsserver, coc-python
nmap <silent> <TAB> <Plug>(coc-range-select)
xmap <silent> <TAB> <Plug>(coc-range-select)

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')
nmap <silent> <C-l> :<C-u>Format<CR>

" Use `:Fold` to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" use `:OR` for organize import of current buffer
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add status line support, for integration with other plugin, checkout `:h coc-status`
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Using CocList
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>


" -------------------------
" --- Function settings ---
" -------------------------
if executable('jq')
  function! s:jq(...)
    execute '%!jq' (a:0 == 0 ? '.' : a:1)
  endfunction
  command! -bar -nargs=? Jq  call s:jq(<f-args>)
endif


" ----------------------------
" --- Key mapping settings ---
" ----------------------------

" --- retrun normal mode from insert mode
inoremap <silent> jj <ESC>
" --- return terminal-normal mode from terminal-job mode
tnoremap <ESC> <C-\><C-n>
" --- cursole movement settings
nnoremap <silent> j gj
nnoremap <silent> k gk
nnoremap <silent> gj j
nnoremap <silent> gk k
nnoremap <silent> $ $l

inoremap <silent> <C-j> <Down>
inoremap <silent> <C-h> <Left>
inoremap <silent> <C-k> <Up>
inoremap <silent> <C-l> <Right>
inoremap <silent> <C-x> <C-h>

" --- split window
nnoremap <silent> <C-w>- :<C-u>:split<CR><C-w>j
nnoremap <silent> <C-w>\| :<C-u>:vsplit<CR><C-w>l
" --- split window size
nnoremap <silent> < <C-w><<C-w><<C-w><
nnoremap <silent> > <C-w>><C-w>><C-w>>
nnoremap <silent> + <C-w>+<C-w>+<C-w>+
nnoremap <silent> - <C-w>-<C-w>-<C-w>-
" --- save
nnoremap <silent> <C-s> :<C-u>:w<CR>
inoremap <silent> <C-s> <ESC>:<C-u>:w<CR>

" --- open init.vim
nnoremap <F5> :<C-u>edit $NVIM_HOME/init.vim<CR>
" --- reload init.vim
nnoremap <F6> :<C-u>source $NVIM_HOME/init.vim<CR>
" --- turn off search highlighst
nnoremap <ESC><ESC> :<C-u>noh<CR>
" --- highlighst by cursol word
nnoremap <silent> <Space><Space> "zyiw:let @/ = '\<' . @z . '\>'<CR>:set hlsearch<CR>
" --- to block hole register
nnoremap x "_x
nnoremap s "_s

" ----------------------
" --- Color settings ---
" ----------------------
colorschem molokai

" --------------------
" Default settings
" --------------------

" --- enable cursol line
set cursorline
" --- can open other file even if not save current file
set hidden
" --- history count
set history=100
" --- visible invisible charactor
set list
set listchars=tab:»-,trail:-,eol:↲,extends:»,precedes:«,nbsp:%
" --- enable mouse control
set mouse=a
" --- disable Beep Sound
set noerrorbells
set novisualbell
set visualbell t_vb=
" --- disable generate backup file
set nobackup
set nowritebackup
" --- disable generate swap file
set noswapfile
" --- display row number
set number
" --- always show command
set showcmd
" --- enable syntax highlights
syntax on
" --- enable word wrap
set wrap
" --- allow the cursor to move just past the end of the line
set virtualedit=onemore
" --- always show signcolumn
set signcolumn=yes
" --- ???
set updatetime=300
" --- load file in real time
set autoread
" --- recognize full width
set ambiwidth=double


" -----------------------------
" --- tab & indent settings ---
" -----------------------------
set autoindent
set expandtab
set smartindent
set smarttab
set shiftwidth=2
set tabstop=2

" -----------------------
" --- search settings ---
" -----------------------

" --- link clipboard
set clipboard^=unnamed
" --- enable search highlights
set hlsearch
" --- enable incremental search
set incsearch
" --- enable case insensitive
set ignorecase
" --- enable case sensitivDTreeToggle:patterns contains uppercase charactore
set smartcase
" --- return to the beginning if go to the end of the search
set wrapscan

" -----------------------------
" --- command line settings ---
" -----------------------------
" number of command line
set cmdheight=2

" ----------------------------
" --- status line settings ---
" ----------------------------

" --- always display status line
set laststatus=2
" --- display file name
set statusline=%F
" --- dispaly modify flag
set statusline+=%m


" -------------------------
" --- filetype settings ---
" -------------------------
" --- enable plugin and indent by filetype
filetype plugin indent on

" ---------------------
" --- auto command ---
" ---------------------
autocmd BufWritePre * :%s/\s\+$//ge
autocmd FileType vue syntax sync fromstart
" ------------------
" --- auto group ---
" ------------------
augroup vimrcEx
  au BufRead * if line("'\"") > 0 && line("'\"") <= line("$") |
  \ exe "normal g`\"" | endif
augroup END

augroup makeEx
  autocmd!
  autocmd FileType make * set noexpandtab
augroup END

augroup kotlin
  autocmd!
  autocmd BufNewFile,BufRead *.kt setfiletype kotlin
augroup END

" Windows Subsystem for Linux で、ヤンクでクリップボードにコピー
if system('uname -a | grep Microsoft') != ''
  augroup myYank
    autocmd!
    autocmd TextYankPost * :call system('clip.exe', @")
  augroup END
endif
