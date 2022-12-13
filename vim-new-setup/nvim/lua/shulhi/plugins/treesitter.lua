require('nvim-treesitter.configs').setup {
  ensure_installed = {
    "elixir",
    "heex",
    "eex"
  },
  sync_install = false,
  ignore_install = { },
  highlight = {
    enable = true,
    disable = { },
  },
}

-- Utilities for creating configurations
local util = require('formatter.util')

-- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
require("formatter").setup {
  -- Enable or disable logging
  logging = true,
  -- Set the log level
  log_level = vim.log.levels.WARN,
  -- All formatter configurations are opt-in
  filetype = {
    rescript = {
      -- vim.fn['rescript#Format']
      function ()
        vim.lsp.buf.format()
      end,
    },

    elixir = {
      function ()
        vim.lsp.buf.format()
      end,
    },

    haskell = {
      vim.fn['ormolu#RunOrmolu']
    },

    -- Use the special "*" filetype for defining formatter configurations on
    -- any filetype
    ["*"] = {
      -- "formatter.filetypes.any" defines default configurations for any
      -- filetype
      require("formatter.filetypes.any").remove_trailing_whitespace
    }
  }
}

vim.cmd([[
augroup FormatAutogroup
  autocmd!
  autocmd BufWritePre * FormatWrite
augroup END
]])
