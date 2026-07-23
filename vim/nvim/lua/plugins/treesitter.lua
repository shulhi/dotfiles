local languages = {
  "elixir",
  "heex",
  "eex",
  "lua",
  "haskell",
  "rescript",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup()
      require("nvim-treesitter").install(languages)

      vim.api.nvim_create_autocmd("FileType", {
        pattern = languages,
        callback = function()
          vim.treesitter.start()
        end,
      })
    end,
  }
}
