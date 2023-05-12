require('luatab').setup{}

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {
        'NvimTree'
      },
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = true,
    refresh = {
      statusline = 500,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', {'diagnostics', sources = {'coc'}}},
    lualine_c = {'filename', 'coc#status'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename', 'coc#status'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {
        { 'filetype', icon_only = true },
        { 'filename', path = 1, color = { bg = 'NONE' } },
    },
    lualine_x = {},
    lualine_y = {},
    lualine_z = {}
  },
  inactive_winbar = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {
        { 'filetype', icon_only = true },
        { 'filename', path = 1, color = { bg = 'NONE' } },
    },
    lualine_x = {},
    lualine_y = {},
    lualine_z = {}
  },
  extensions = {}
}

vim.cmd([[
  autocmd User CocStatusChange redrawstatus
]])

-- vim.opt.winbar = "%=%m %f"
-- vim.opt.laststatus = 3
