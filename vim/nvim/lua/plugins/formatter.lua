return {
  "mhartington/formatter.nvim",
  lazy = true,
  event = "BufWritePre",
  config = function()
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
          function ()
            vim.lsp.buf.format()
          end,
        },

        elixir = {
          function ()
            vim.lsp.buf.format()
          end,
        },

        haskell = function()
          return {
            exe = "ormolu",
            args = {
              "--stdin-input-file",
              util.escape_path(util.get_current_buffer_file_path()),
            },
            stdin = true,
          }
        end,

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
      autocmd BufWritePost *.hs FormatWrite
    augroup END
    ]])
  end
}
