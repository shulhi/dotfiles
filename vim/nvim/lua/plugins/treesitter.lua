return {
  {
    "nvim-treesitter/nvim-treesitter",
    ["do"] = ":TSUpdate",
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          "elixir",
          "heex",
          "eex",
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
    end,
  }
}
