return {
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    config = function()
      require('gitsigns').setup()
    end
  },
  {
    "ruifm/gitlinker.nvim",
    event = "BufReadPre",
    config = function()
      require("gitlinker").setup()
    end
  }
}
