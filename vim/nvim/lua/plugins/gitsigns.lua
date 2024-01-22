return {
  {
    "lewis6991/gitsigns.nvim",
    event = "BufEnter",
    config = function()
      require('gitsigns').setup()
    end
  },
  {
    "ruifm/gitlinker.nvim",
    event = "BufEnter",
    config = function()
      require("gitlinker").setup()
    end
  }
}
