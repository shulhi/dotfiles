return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = true,
    events = {"BufEnter"},
    ["do"] = ":TSUpdate",
    config = function()
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
    end,
  },
  {
    "nkrkv/nvim-treesitter-rescript",
    lazy = true,
    ft = {"rescript"},
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  }
}
