return {
  {
    "elixir-tools/elixir-tools.nvim",
    ft = {"elixir"},
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      local elixir = require("elixir")
      local elixirls = require("elixir.elixirls")

      elixir.setup {
        nextls = {
          enable = false, -- defaults to false
          filetypes = { 'elixir', 'eelixir', 'heex', 'surface' },
          root_markers = { 'mix.exs', '.git' },
          init_options = {
            experimental = {
              completions = {
                enable = true -- control if completions are enabled. defaults to false
              }
            }
          },
        },
        elixirls = {
          enable = true,
        }
      }
    end
  }
}
