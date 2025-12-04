return {
  cmd = { '/Users/shulhi/.local/share/nvim/mason/bin/rescript-language-server', '--stdio' },
  filetypes = { 'rescript' },
  root_markers = { 'bsconfig.json', 'rescript.json', '.git' },
  settings = {},
  init_options = {
    extensionConfiguration = {
      -- buggy, prompts much too often, superseded by incrementalTypechecking, below
      askToStartBuild = false,

      allowBuiltInFormatter = true, -- lower latency
      incrementalTypechecking = { -- removes the need for external build process
        enabled = true,
        acrossFiles = true,
      },
      cache = { projectConfig = { enabled = true } }, -- speed up latency dramatically
      codeLens = true,
      inlayHints = { enable = true },
    },
  },
}
