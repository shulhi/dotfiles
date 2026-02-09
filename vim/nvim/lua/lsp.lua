vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp,
  callback = function(args)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = args.buf })
    vim.keymap.set("n", "[g", vim.diagnostic.goto_prev, { buffer = args.buf })
    vim.keymap.set("n", "]g", vim.diagnostic.goto_next, { buffer = args.buf })

    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = lsp, buffer = args.buf })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = lsp,
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.format()
        end,
      })
    end
  end,
})


vim.diagnostic.config({
  virtual_lines = true
})

vim.lsp.enable({'rescriptls'})
vim.lsp.enable({'ocamllsp'})
