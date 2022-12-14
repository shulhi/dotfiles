require("nvim-tree").setup({
  git = {
    ignore = false
  },
  actions = {
    open_file = {
      quit_on_open = true
    }
  },
  view = {
    adaptive_size = true
  },
  renderer = {
    indent_markers = {
      enable = true
    },
    icons = {
      git_placement = "signcolumn",
      glyphs = {
        git = {
          unstaged = 'M',
          untracked = 'U',
          deleted = 'D',
          staged = 'A'
        },
      },
    }
  }
})

vim.keymap.set('n', '<leader>nt', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>nf', ':NvimTreeFindFileToggle<CR>', { noremap = true, silent = true })

require('gitsigns').setup()

vim.cmd [[
hi CocMenuSel cterm=bold ctermfg=239 ctermbg=109 gui=bold guifg=#504945 guibg=#83a598
hi GitSignsAdd ctermfg=142 ctermbg=237 guifg=#b8bb26 guibg=#3c3836
hi GitSignsChange ctermfg=142 ctermbg=237 guifg=#83a598 guibg=#3c3836
]]
