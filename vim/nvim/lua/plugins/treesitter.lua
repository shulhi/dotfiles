return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          "elixir",
          "heex",
          "eex",
          "lua",
          "haskell",
          "rescript"
        },
        sync_install = false,
        ignore_install = { },
        highlight = {
          enable = true,
          disable = { },
        },
      }
    end,
  }
}
