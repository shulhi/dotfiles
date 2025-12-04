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
          on_attach = function(client, bufnr)
            if client.supports_method("textDocument/formatting") then
              vim.api.nvim_clear_autocmds({ group = lsp, buffer = bufnr })
              vim.api.nvim_create_autocmd("BufWritePre", {
                group = lsp,
                buffer = bufnr,
                callback = function()
                  vim.lsp.buf.format()
                end,
              })
            end
          end
        },
        elixirls = {
          enable = true,
          on_attach = function(client, bufnr)
            if client.supports_method("textDocument/formatting") then
              vim.api.nvim_clear_autocmds({ group = lsp, buffer = bufnr })
              vim.api.nvim_create_autocmd("BufWritePre", {
                group = lsp,
                buffer = bufnr,
                callback = function()
                  vim.lsp.buf.format()
                end,
              })
            end
         end
        }
      }
    end
  }
}
