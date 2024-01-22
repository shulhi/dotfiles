call plug#begin('~/.local/share/nvim/plugged')

  Plug 'scrooloose/nerdtree'
  Plug 'terryma/vim-multiple-cursors'
  Plug 'airblade/vim-gitgutter'
  Plug 'vim-airline/vim-airline',
  Plug 'vim-airline/vim-airline-themes',
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-rhubarb'
  Plug 'sheerun/vim-polyglot'
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  Plug 'vimwiki/vimwiki'
  Plug 'elixir-editors/vim-elixir'
  Plug 'rescript-lang/vim-rescript'
  Plug 'sdiehl/vim-ormolu'
  Plug 'ryanoasis/vim-devicons'

  " Themes
  Plug 'gruvbox-community/gruvbox'
  Plug 'EdenEast/nightfox.nvim'

call plug#end()

filetype on
filetype plugin on
filetype indent on

syntax enable
set t_Co=256
set background=light
set termguicolors
if (has('nvim'))
  let $NVIM_TUI_ENABLE_TRUE_COLOR = 1
endif
colorscheme gruvbox

" let g:material_theme_style = 'darker'
let g:gruvbox_invert_selection=0

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

let mapleader = "\<space>"
noremap ; :


let wiki_1 = {}
let wiki_1.path = '~/wiki/'
let wiki_1.syntax = 'markdown'
let wiki_1.ext = '.md'
let wiki_1.nested_syntaxes = {'python': 'python', 'reason': 'reason', 'haskell': 'haskell', 'elixir': 'elixir'}
let g:vimwiki_list = [wiki_1]

"Coc

" use <tab> for trigger completion and navigate to the next complete item
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#insert():
      \ <SID>check_back_space() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

command! -nargs=0 Format :call CocActionAsync('format')
nmap <silent> <leader>f :call CocActionAsync('format')<CR>

inoremap <silent><expr> <C-space> coc#refresh()

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Fzf
function! s:GotoOrOpen(command, ...)
  for file in a:000
    if a:command == 'e'
      exec 'e ' . file
    else
      exec "tab drop " . file
    endif
  endfor
endfunction

command! -nargs=+ GotoOrOpen call s:GotoOrOpen(<f-args>)

let g:fzf_action = {
  \ 'ctrl-t': 'GotoOrOpen tab',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }
let g:fzf_buffers_jump = 1
let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.8 } }
nnoremap <silent> <C-p> :Files<CR>
" nnoremap <silent> <C-p> :call fzf#vim#files(FindRootDirectory())<CR>


command! -bang -nargs=* Rg call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1, {'options': '--delimiter : --nth 4..'}, <bang>0)

" Fugitive
nnoremap <silent> <leader>gs :Gstatus<CR>

nnoremap <leader>h :wincmd h<CR>
nnoremap <leader>j :wincmd j<CR>
nnoremap <leader>k :wincmd k<CR>
nnoremap <leader>l :wincmd l<CR>
nnoremap <leader>ss :source session.vim<CR>
nnoremap <leader>ms :mksession! session.vim<CR>

let g:python3_host_prog='/home/shulhi/.pyenv/versions/3.8.2/bin/python'
let g:loaded_python_provider = 1

let g:multi_cursor_next_key='<C-n>'
let g:multi_cursor_prev_key='<C-i>'
let g:multi_cursor_skip_key='<C-x>'
let g:multi_cursor_quit_key='<C-c>'

let g:airline_powerline_fonts=1

nnoremap <silent> <leader>nt :NERDTreeToggle<CR>
nnoremap <silent> <leader>nf :NERDTreeFind<CR>
let NERDTreeShowHidden=1
let NERDTreeQuitOnOpen=1
let NERDTreeIgnore = ['\.swp$', '\.pyc$', '\.git$']

set statusline+=%#warningmsg#
set statusline+=%*

let g:rustfmt_autosave = 1

nmap <c-c> <esc>
imap <c-c> <esc>
vmap <c-c> <esc>
omap <c-c> <esc>
cmap w!! w !sudo tee > /dev/null %

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

augroup new_reason_syntax
  au!
  autocmd BufNewFile,BufRead *.res   set syntax=reason
  autocmd BufNewFile,BufRead *.resi   set syntax=reason
augroup END

" Hooking up the ReScript autocomplete function
set omnifunc=rescript#Complete

" When preview is enabled, omnicomplete will display additional
" information for a selected item
set completeopt+=preview

" augroup numbertoggle
"   autocmd!
"   autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
"   autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
" augroup END

function! Darkorlight(file) abort
  if getftype(expand(a:file)) != 'link'
    return
  endif
  if resolve(glob(expand(a:file))) =~ 'dark'
    set background=dark
  else
    set background=dark
  endif
  redraw

  hi CocMenuSel cterm=bold ctermfg=239 ctermbg=109 gui=bold guifg=#504945 guibg=#83a598

  try
    execute "AirlineRefresh"
  catch
    redrawstatus!
  endtry
endfunction

call Darkorlight('/home/shulhi/.config/kitty/theme.conf')
au Signal SIGUSR1 call Darkorlight('/home/shulhi/.config/kitty/theme.conf')

au TabLeave * let g:lasttab = tabpagenr()
nnoremap <silent> <c-l> :exe "tabn ".g:lasttab<cr>
vnoremap <silent> <c-l> :exe "tabn ".g:lasttab<cr>

lua << EOF
vim.api.nvim_set_keymap('v', '<c-k>', ':lua require"bbupload".upload()<CR>', {noremap = true})
EOF


hi CocMenuSel cterm=bold ctermfg=239 ctermbg=109 gui=bold guifg=#504945 guibg=#83a598

set rtp^="/home/shulhi/.opam/4.14.0/share/ocp-indent/vim"
