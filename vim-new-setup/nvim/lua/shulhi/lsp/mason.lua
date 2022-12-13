require("mason").setup()
require("mason-lspconfig").setup()
-- require("lspconfig").elixirls.setup {}
-- require("lspconfig").rescriptls.setup {}

local cmp = require('cmp')
local lspkind = require('lspkind')

local kind_icons = {
  Text = "",
  Method = "",
  Function = "",
  Constructor = "",
  Field = "",
  Variable = "",
  Class = "ﴯ",
  Interface = "",
  Module = "",
  Property = "ﰠ",
  Unit = "",
  Value = "",
  Enum = "",
  Keyword = "",
  Snippet = "",
  Color = "",
  File = "",
  Reference = "",
  Folder = "",
  EnumMember = "",
  Constant = "",
  Struct = "",
  Event = "",
  Operator = "",
  TypeParameter = ""
}

cmp.setup({
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    -- { name = 'luasnip' }, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
    -- { name = 'snippy' }, -- For snippy users.
  }, {
    { name = 'buffer' },
  }),
  formatting = {
    deprecated = true,
    format = function(entry, vim_item)
      -- Kind icons
      vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
      -- Source
      vim_item.menu = ({
        buffer = "[Buffer]",
        nvim_lsp = "[LSP]",
        luasnip = "[LuaSnip]",
        nvim_lua = "[Lua]",
        latex_symbols = "[LaTeX]",
      })[entry.source.name]
      return vim_item
    end
  },
})


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
            root_dir = vim.fs.dirname(path[1])
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
            }
        })
    end,
})

vim.api.nvim_create_autocmd("LspAttach", {
    group = lsp,
    callback = function(args)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = args.buf })
        vim.keymap.set("n", "gh", vim.lsp.buf.hover, { buffer = args.buf })
        vim.keymap.set("n", "ca", vim.lsp.buf.code_action, { buffer = args.buf })
        vim.keymap.set("n", "[g", vim.diagnostic.goto_prev, { buffer = args.buf })
        vim.keymap.set("n", "]g", vim.diagnostic.goto_next, { buffer = args.buf })
    end,
})

vim.api.nvim_create_autocmd("LspDetach", {
    group = lsp,
    callback = function(args)
        vim.keymap.delete("n", "gd", { buffer = args.buf })
        vim.keymap.delete("n", "gh", { buffer = args.buf })
        vim.keymap.delete("n", "ca", { buffer = args.buf })
        vim.keymap.delete("n", "[g", { buffer = args.buf })
        vim.keymap.delete("n", "]g", { buffer = args.buf })
    end,
})
