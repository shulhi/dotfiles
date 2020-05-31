call plug#begin('~/.local/share/nvim/plugged')

  Plug 'scrooloose/nerdtree'
  Plug 'terryma/vim-multiple-cursors'
  Plug 'airblade/vim-gitgutter'
  Plug 'vim-airline/vim-airline',
  Plug 'vim-airline/vim-airline-themes',
  Plug 'tpope/vim-fugitive'
  Plug 'neovimhaskell/haskell-vim'
  Plug 'elixir-editors/vim-elixir'
  Plug 'hdima/python-syntax'
  Plug 'rust-lang/rust.vim'
  Plug 'racer-rust/vim-racer'
  Plug 'LnL7/vim-nix'
  Plug 'lervag/vimtex'
  Plug 'reasonml-editor/vim-reason-plus'
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'
  Plug 'neoclide/coc.nvim', {'branch': 'release'}

  " Themes
  Plug 'kaicataldo/material.vim'
  Plug 'gruvbox-community/gruvbox'

call plug#end()

filetype on
filetype plugin on
filetype indent on

syntax enable
set t_Co=256
set background=dark
set termguicolors
if (has('nvim'))
  let $NVIM_TUI_ENABLE_TRUE_COLOR = 1
endif

" let g:material_theme_style = 'darker'
let g:gruvbox_invert_selection=0
colorscheme gruvbox

set hidden
set clipboard=unnamed
set cursorline
set expandtab
set hlsearch
set nowrap
set number relativenumber
set shiftwidth=2
set showmatch
set showcmd
set smarttab
set scrolloff=10
set tabstop=2
set laststatus=2
set ttimeoutlen=50
set encoding=utf-8
set list listchars=tab:→\ ,trail:·
set list
set mouse=a
set backspace=indent,eol,start
set foldmethod=syntax
set signcolumn=yes
set colorcolumn=120


let g:vimtex_compiler_latexmk = {
    \ 'options' : [
    \   '-pdf',
    \   '-pdflatex="xelatex --shell-escape %O %S"',
    \   '-verbose',
    \   '-file-line-error',
    \   '-synctex=1',
    \   '-interaction=nonstopmode',
    \ ]
    \}

"Coc

" use <tab> for trigger completion and navigate to the next complete item
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <Tab>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<Tab>" :
      \ coc#refresh()

inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

command! -nargs=0 Format :call CocActionAsync('format')
nmap <silent> <leader>f :call CocActionAsync('format')<CR>

inoremap <silent><expr> <leader><space> coc#refresh()

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Fzf
nnoremap <silent> <C-p> :Files<CR>

" Fugitive
nnoremap <silent> <leader>gs :Gstatus<CR>

nnoremap <leader>h :wincmd h<CR>
nnoremap <leader>j :wincmd j<CR>
nnoremap <leader>k :wincmd k<CR>
nnoremap <leader>l :wincmd l<CR>

let g:python3_host_prog='/home/shulhi/.pyenv/versions/3.8.2/bin/python'
let g:loaded_python_provider = 1

let g:multi_cursor_next_key='<C-n>'
let g:multi_cursor_prev_key='<C-i>'
let g:multi_cursor_skip_key='<C-x>'
let g:multi_cursor_quit_key='<C-c>'

let g:airline_powerline_fonts=1

map <C-k> :NERDTreeToggle<CR>
nnoremap <silent> <leader>nf :NERDTreeFind<CR>
let NERDTreeShowHidden=1
let NERDTreeQuitOnOpen=1
let NERDTreeIgnore = ['\.swp$', '\.pyc$', '\.git$']

set statusline+=%#warningmsg#
set statusline+=%*

let g:rustfmt_autosave = 1
let g:racer_cmd = '/home/shulhi/.cargo/bin/racer'
let g:racer_experimental_completer = 1

let g:vimtex_compiler_progname = 'nvr'

nmap <c-c> <esc>
imap <c-c> <esc>
vmap <c-c> <esc>
omap <c-c> <esc>

fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun

autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()

set updatetime=200
set autoread
au FocusGained,FocusLost,BufEnter,BufLeave,CursorHold,CursorHoldI * :silent! checktime
au BufRead,BufWinEnter * normal zR

augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END
