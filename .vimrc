execute pathogen#infect()
filetype plugin on
filetype indent on

let mapleader=","

colorscheme monokai

set background=dark
set clipboard=unnamed
set cursorline
set expandtab
set hlsearch
set nowrap
set number
set shiftwidth=2
set showmatch
set smarttab
set t_Co=256
set tabstop=2
set laststatus=2
set ttimeoutlen=50
set encoding=utf-8
set list listchars=tab:→\ ,trail:·
set list
set mouse=a
set backspace=indent,eol,start

syntax enable

map <C-k> :NERDTreeToggle<CR>

let g:ctrlp_prompt_mappings = {
    \ 'AcceptSelection("e")': ['<c-t>'],
    \ 'AcceptSelection("t")': ['<cr>', '<2-LeftMouse>'],
    \ }
let g:multi_cursor_next_key='<C-n>'
let g:multi_cursor_prev_key='<C-i>'
let g:multi_cursor_skip_key='<C-x>'
let g:multi_cursor_quit_key='<Esc>'

let g:airline_powerline_fonts=1

let NERDTreeShowHidden=1
let NERDTreeIgnore = ['\.swp$', '\.pyc$', '\.git$']

fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun

autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()

set updatetime=750
set autoread
au FocusGained,FocusLost,BufEnter,BufLeave,CursorHold,CursorHoldI * :silent! checktime
