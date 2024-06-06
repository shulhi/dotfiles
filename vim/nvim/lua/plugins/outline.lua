return {
  "hedyhli/outline.nvim",
  keys = { -- Example mapping to toggle outline
    { "<leader>o", "<cmd>Outline<CR>", desc = "Toggle outline" },
  },
  config = function()
    require("outline").setup({
      providers = {
        priority = { 'lsp' }
      }
    })
  end
}
