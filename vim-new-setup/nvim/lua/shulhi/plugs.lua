local Plug = vim.fn['plug#']

vim.call('plug#begin', '~/.config/nvim/new_setup/nvim/plugged')

-- Tree pane
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-tree/nvim-web-devicons'

Plug 'terryma/vim-multiple-cursors'
Plug 'lewis6991/gitsigns.nvim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'sheerun/vim-polyglot'
Plug('junegunn/fzf', { ['do'] = vim.fn["fzf#install"] })
Plug 'junegunn/fzf.vim'
Plug 'rescript-lang/vim-rescript'

-- Formatter that doesn't depend on LSP
Plug 'mhartington/formatter.nvim'

-- Status line
Plug 'nvim-lualine/lualine.nvim'

-- Telescope
Plug 'nvim-lua/plenary.nvim'
Plug('nvim-telescope/telescope.nvim', { ['tag'] = '0.1.0' })

-- Treesitter
Plug('nvim-treesitter/nvim-treesitter', {['do'] = vim.fn[':TSUpdate']})
Plug 'nkrkv/nvim-treesitter-rescript'


-- Either use native LSP or COC.
-- Comment/Uncomment accordingly
--
-- Native LSP
--Plug 'neovim/nvim-lspconfig'
--Plug 'williamboman/mason-lspconfig.nvim'
--Plug 'williamboman/mason.nvim'
-- Auto complete for native LSP
--Plug 'hrsh7th/cmp-buffer'
--Plug 'hrsh7th/cmp-path'
--Plug 'hrsh7th/cmp-cmdline'
--Plug 'hrsh7th/cmp-nvim-lsp'
--Plug 'hrsh7th/nvim-cmp'
--Plug 'onsails/lspkind-nvim'
-- Improve LSP UI
--Plug('glepnir/lspsaga.nvim', { ['branch'] = 'main' })

-- CoC.nvim
Plug('neoclide/coc.nvim', { ['branch'] = 'release' })

-- themes
Plug 'gruvbox-community/gruvbox'
Plug 'EdenEast/nightfox.nvim'

vim.call('plug#end')
