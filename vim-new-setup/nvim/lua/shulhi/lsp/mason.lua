require("mason").setup()
require("mason-lspconfig").setup()

local lsp = vim.api.nvim_create_augroup("LSP", { clear = true })

-- Elixir
vim.api.nvim_create_autocmd("FileType", {
    group = lsp,
    pattern = "elixir",
    callback = function()
        local path = vim.fs.find({ "mix.exs" })
        vim.lsp.start({
            name = "elixirls",
            cmd = { "/home/shulhi/.local/share/nvim/mason/bin/elixir-ls" },
            root_dir = vim.fs.dirname(path[1]),
            -- format on save using LSP's formatter
            on_attach = function(client, bufnr)
              if client.supports_method("textDocument/formatting") then
                vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
                vim.api.nvim_create_autocmd("BufWritePre", {
                  group = augroup,
                  buffer = bufnr,
                  callback = function()
                    vim.lsp.buf.format()
                  end,
                })
              end
            end,
        })
    end,
})

-- ReScript
vim.api.nvim_create_autocmd("FileType", {
    group = lsp,
    pattern = "rescript",
    callback = function()
        local path = vim.fs.find({ "bsconfig.json" })
        vim.lsp.start({
            name = "rescriptls",
            cmd = { "node", "/home/shulhi/.local/share/nvim/mason/packages/rescript-lsp/extension/server/out/server.js", "--stdio" },
            root_dir = vim.fs.dirname(path[1]),
            settings = {
              rescriptls = {
                allowBuiltInFormatter = true,
                codeLens = true
              }
            },
            -- format on save using LSP's formatter
            on_attach = function(client, bufnr)
              if client.supports_method("textDocument/formatting") then
                vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
                vim.api.nvim_create_autocmd("BufWritePre", {
                  group = augroup,
                  buffer = bufnr,
                  callback = function()
                    vim.lsp.buf.format()
                  end,
                })
              end
            end,
        })
    end,
})

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
