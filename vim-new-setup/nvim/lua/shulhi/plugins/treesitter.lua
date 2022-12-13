require('nvim-treesitter.configs').setup {
  ensure_installed = {
    "elixir",
    "heex",
    "eex",
    "rescript"
  },
  sync_install = false,
  ignore_install = { },
  highlight = {
    enable = true,
    disable = { },
  },
}
