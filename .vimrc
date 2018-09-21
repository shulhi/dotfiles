call plug#begin('~/.vim/plugged')

Plug 'scrooloose/nerdtree'
Plug 'terryma/vim-multiple-cursors'
Plug 'airblade/vim-gitgutter'
Plug 'bling/vim-airline'
Plug 'tpope/vim-fugitive'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'Shougo/vimproc.vim', {'do' : 'make'}
Plug 'neovimhaskell/haskell-vim'
Plug 'elixir-editors/vim-elixir'
Plug 'mhinz/vim-mix-format'
Plug 'hdima/python-syntax'
Plug 'rust-lang/rust.vim'
Plug 'racer-rust/vim-racer'

call plug#end()

filetype on
filetype plugin on
filetype indent on

syntax enable
set t_Co=256
set background=dark
colorscheme solarized

set hidden
set clipboard=unnamed
set cursorline
set expandtab
set hlsearch
set nowrap
set number
set shiftwidth=2
set showmatch
set showcmd
set smarttab
set tabstop=2
set laststatus=2
set ttimeoutlen=50
set encoding=utf-8
set list listchars=tab:→\ ,trail:·
set list
set mouse=a
set backspace=indent,eol,start
set foldmethod=syntax

let g:python3_host_prog='/home/shulhi/.pyenv/versions/py3neovim/bin/python'
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

let g:mix_format_on_save = 1

map <C-k> :NERDTreeToggle<CR>
let NERDTreeShowHidden=1
let NERDTreeIgnore = ['\.swp$', '\.pyc$', '\.git$']

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
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
