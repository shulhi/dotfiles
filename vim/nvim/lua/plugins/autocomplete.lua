return {
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-cmdline",
  "hrsh7th/cmp-nvim-lsp",
  {
    "hrsh7th/nvim-cmp",
    event = {'BufReadPre', 'BufNewFile'},
    dependencies = { "onsails/lspkind-nvim" },
    config = function()
      local cmp = require("cmp")

      cmp.setup({
        window = {
          completion = {
            winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None,CursorLine:PmenuSel",
            col_offset = -3,
            side_padding = 0,
            border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
          },
          documentation = {
            border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
          },
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
        }, {
          { name = 'buffer' },
        }),
        formatting = {
          deprecated = true,
          fields = { "kind", "abbr", "menu" },
          format = function(entry, vim_item)
            local kind = require("lspkind").cmp_format({ mode = "symbol_text", maxwidth = 50 })(entry, vim_item)
            local strings = vim.split(kind.kind, "%s", { trimempty = true })
            local source = ({
              buffer = "[Buffer]",
              nvim_lsp = "[LSP]",
            })[entry.source.name]
            vim_item.kind = " " .. (strings[1] or "") .. " "
            vim_item.menu = "    (" .. (strings[2] or "") .. ")" .. " " .. (source or "")

            return vim_item
          end,
        },
      })
    end
  },
}
