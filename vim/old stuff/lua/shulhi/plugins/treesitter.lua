require('nvim-treesitter.configs').setup {
  ensure_installed = {
    "elixir",
    "heex",
    "eex",
    "rescript",
    "lua",
    "haskell"
  },
  sync_install = false,
  ignore_install = { },
  highlight = {
    enable = true,
    disable = { },
  },
}

-- vim.api.nvim_create_augroup("cmdwin_treesitter", { clear = true })
-- vim.api.nvim_create_autocmd("CmdwinEnter", {
--   pattern = "*",
--   command = "TSBufDisable incremental_selection",
--   group = "cmdwin_treesitter",
--   desc = "Disable treesitter's incremental selection in Command-line window",
-- })
