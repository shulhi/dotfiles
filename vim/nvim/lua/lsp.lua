local lsp = vim.api.nvim_create_augroup("LSP", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp,
  callback = function(args)
    local buf = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = buf })
    vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = buf })
    vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, { buffer = buf })
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover({ border = 'rounded' }) end, { buffer = buf })
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = buf })
    vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { buffer = buf })
    vim.keymap.set("n", "[g", function() vim.diagnostic.jump({ count = -1 }) end, { buffer = buf })
    vim.keymap.set("n", "]g", function() vim.diagnostic.jump({ count = 1 }) end, { buffer = buf })

    if client.supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = buf })
    end

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

--    if client and client.name == "rescriptls" then
--      client.server_capabilities.semanticTokensProvider = nil
--    end
  end,
})


vim.diagnostic.config({
  virtual_lines = true,
  float = { border = 'rounded' },
})


vim.lsp.enable({'rescriptls'})
vim.lsp.enable({'ocamllsp'})
