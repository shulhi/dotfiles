call plug#begin('~/.local/share/nvim/plugged')

  Plug 'scrooloose/nerdtree'
  Plug 'terryma/vim-multiple-cursors'
  Plug 'airblade/vim-gitgutter'
  Plug 'bling/vim-airline'
  Plug 'tpope/vim-fugitive'
  Plug 'ctrlpvim/ctrlp.vim'
  Plug 'Shougo/vimproc.vim', {'do' : 'make'}
  Plug 'neovimhaskell/haskell-vim'
  Plug 'elixir-editors/vim-elixir'
  Plug 'slashmili/alchemist.vim'
  Plug 'mhinz/vim-mix-format'
  Plug 'hdima/python-syntax'
  Plug 'rust-lang/rust.vim'
  Plug 'racer-rust/vim-racer'
  Plug 'kaicataldo/material.vim'
  Plug 'LnL7/vim-nix'

  Plug 'autozimu/LanguageClient-neovim', {
      \ 'branch': 'next',
      \ 'do': 'bash install.sh',
      \ }
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

call plug#end()

filetype on
filetype plugin on
filetype indent on

syntax enable
set t_Co=256
set background=dark
set termguicolors
colorscheme material

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

set completeopt-=preview
set completefunc=LanguageClient#complete
let g:LanguageClient_serverCommands = {
    \ 'rust': ['~/.cargo/bin/rustup', 'run', 'nightly', 'rls'],
    \ }
let g:deoplete#enable_at_startup = 1
let g:deoplete#sources = {}
let g:deoplete#sources.rust = ['LanguageClient']

nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
nnoremap <silent> <F2> :call LanguageClient#textDocument_rename()<CR>

let g:python3_host_prog='/home/shulhi/.pyenv/versions/py3/bin/python'
"let g:python3_host_prog='/usr/bin/python3'
let g:loaded_python_provider = 1

let g:multi_cursor_next_key='<C-n>'
let g:multi_cursor_prev_key='<C-i>'
let g:multi_cursor_skip_key='<C-x>'
let g:multi_cursor_quit_key='<Esc>'

let g:ctrlp_prompt_mappings = {
    \ 'AcceptSelection("e")': ['<c-t>'],
    \ 'AcceptSelection("t")': ['<cr>', '<2-LeftMouse>'],
    \ }
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'

let g:airline_powerline_fonts=1
let g:airline_theme='material'

let g:mix_format_on_save = 1

map <C-k> :NERDTreeToggle<CR>
let NERDTreeShowHidden=1
let NERDTreeIgnore = ['\.swp$', '\.pyc$', '\.git$']

set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:rustfmt_autosave = 1
let g:racer_cmd = '/home/shulhi/.cargo/bin/racer'
let g:racer_experimental_completer = 1

fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun

autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()
au BufRead,BufNewFile *.go set filetype=go

set updatetime=750
set autoread
au FocusGained,FocusLost,BufEnter,BufLeave,CursorHold,CursorHoldI * :silent! checktime
au BufRead,BufWinEnter * normal zR

augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END
