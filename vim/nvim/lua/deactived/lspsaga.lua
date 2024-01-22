return {
  "nvimdev/lspsaga.nvim",
  config = function()
    require("lspsaga").setup({
      finder_request_timeout = 30000, -- 30 seconds
      lightbulb = {
        enable = false
      }
    })

    vim.keymap.set("n", "gh", "<cmd>Lspsaga lsp_finder<CR>", { silent = true })
    vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", { silent = true })
    vim.keymap.set("n","<leader>o", "<cmd>LSoutlineToggle<CR>",{ silent = true })
    vim.keymap.set({"n","v"}, "<leader>ca", "<cmd>Lspsaga code_action<CR>", { silent = true })
    -- Show line diagnostics
    vim.keymap.set("n", "<leader>cd", "<cmd>Lspsaga show_line_diagnostics<CR>", { silent = true })
    -- Show cursor diagnostics
    vim.keymap.set("n", "<leader>cd", "<cmd>Lspsaga show_cursor_diagnostics<CR>", { silent = true })
  end,
  dependencies = {
    "nvim-treesitter/nvim-treesitter", -- optional
    "nvim-tree/nvim-web-devicons"     -- optional
  }
}
