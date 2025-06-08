return {
  "neovim/nvim-lspconfig",
  cmd = 'LspInfo',
  event = {'BufReadPre', 'BufNewFile'},
  dependencies = { 
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    {"rescript-lang/vim-rescript", ft = {"rescript"}},
    {"elixir-tools/elixir-tools.nvim", ft = {"elixir"}},
    {"mrcjkb/rustaceanvim", ft = {"rust"}}
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
      init_options = {
        extensionConfiguration = {
          incrementalTypecheking = {
            enabled = true
          }
        }
      },
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
