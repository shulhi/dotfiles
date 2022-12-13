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
      git_placement = "signcolumn"
    }
  }
})

vim.keymap.set('n', '<leader>nt', ':NvimTreeToggle<CR>', { noremap = true })
vim.keymap.set('n', '<leader>nf', ':NvimTreeFindFileToggle<CR>', { noremap = true })
