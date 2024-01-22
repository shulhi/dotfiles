return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup {
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
            folder = {
              arrow_closed = "",
              arrow_open = "",
            },
            git = {
              unstaged = 'M',
              untracked = 'U',
              deleted = 'D',
              staged = 'A',
              unmerged = 'C'
            },
          },
        }
      },
      git = {
        show_on_dirs = true,
        show_on_open_dirs = false
      }
    }

    vim.keymap.set('n', '<leader>nt', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>nf', ':NvimTreeFindFileToggle<CR>', { noremap = true, silent = true })
  end,
}
