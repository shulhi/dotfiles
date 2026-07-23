return {
  'mrcjkb/rustaceanvim',
  version = '^4', -- Recommended
  ft = { 'rust' },
  enabled = false, -- disabled: conflicts with native vim.lsp.enable('rust_analyzer') in lsp.lua, was causing duplicate completions/diagnostics
}
