return {
  "neovim/nvim-lspconfig",
  dependencies = { 
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "rescript-lang/vim-rescript",
    "elixir-tools/elixir-tools.nvim",
  },
  config = function()
    local elixir = require("elixir")
    local elixirls = require("elixir.elixirls")
    local lspconfig = require('lspconfig')
    local lsp = vim.api.nvim_create_augroup("LSP", { clear = true })

    vim.cmd[[
    au BufRead,BufNewFile *.res set filetype=rescript
    au BufRead,BufNewFile *.resi set filetype=rescript
    ]]

    lspconfig.rescriptls.setup({
      -- format on save using LSP's formatter
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
      end,
      on_error = function(code, params)
        print(vim.inspect(code))
        print(vim.inspect(params))
      end,
    })

    elixir.setup {
      nextls = {
        enable = true, -- defaults to false
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
        enable = false,
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

    lspconfig.ocamllsp.setup({})

    vim.api.nvim_create_autocmd("LspAttach", {
        group = lsp,
        callback = function(args)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = args.buf })
          vim.keymap.set("n", "[g", vim.diagnostic.goto_prev, { buffer = args.buf })
          vim.keymap.set("n", "]g", vim.diagnostic.goto_next, { buffer = args.buf })
        end,
    })

    vim.api.nvim_create_autocmd("LspDetach", {
        group = lsp,
        callback = function(args)
          vim.keymap.del("n", "gd", { buffer = args.buf })
          vim.keymap.del("n", "[g", { buffer = args.buf })
          vim.keymap.del("n", "]g", { buffer = args.buf })
        end,
    })
  end
}
