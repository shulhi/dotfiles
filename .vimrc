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

syntax enable

map <C-k> :NERDTreeToggle<CR>
map <Leader>t :call RunCurrentSpecFile()<CR>
map <Leader>s :call RunNearestSpec()<CR>
map <Leader>l :call RunLastSpec()<CR>
map <Leader>a :call RunAllSpecs()<CR>

let g:ctrlp_prompt_mappings = {
    \ 'AcceptSelection("e")': ['<c-t>'],
    \ 'AcceptSelection("t")': ['<cr>', '<2-LeftMouse>'],
    \ }
let g:multi_cursor_next_key='<C-n>'
let g:multi_cursor_prev_key='<C-i>'
let g:multi_cursor_skip_key='<C-x>'
let g:multi_cursor_quit_key='<C-c>'

let g:airline_powerline_fonts=1
let NERDTreeShowHidden=1
