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

vim.lsp.enable({'rescriptls'})
vim.lsp.enable({'ocamllsp'})
