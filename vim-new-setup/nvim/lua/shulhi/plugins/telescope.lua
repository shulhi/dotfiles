local actions = require('telescope.actions')
local builtin = require('telescope.builtin')

require('telescope').setup({
  defaults = {
      mappings = {
          i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous
          }
      }
  }
})

vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

require("nvim-tree").setup({
  git = {
    ignore = false
  },
  actions = {
    open_file = {
      quit_on_open = true
    }
  }
})

vim.keymap.set('n', '<leader>nt', ':NvimTreeToggle<CR>', { noremap = true })
vim.keymap.set('n', '<leader>nf', ':NvimTreeFindFileToggle<CR>', { noremap = true })
