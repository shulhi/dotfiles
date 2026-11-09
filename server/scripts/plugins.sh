#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
restore_plugins() {
  log 'Restoring Neovim plugins and installing configured parsers'
  # Pin the plugin manager too; Lazy restore does not restore its own checkout.
  local manager="$HOME/.local/share/nvim/lazy/lazy.nvim" commit
  commit=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["lazy.nvim"]["commit"])' "$DOTFILES_DIR/vim/nvim/lazy-lock.json")
  if [[ ! -d $manager/.git ]]; then
    git clone --filter=blob:none -- https://github.com/folke/lazy.nvim.git "$manager"
  fi
  git -C "$manager" checkout --detach "$commit"
  # Restore respects lazy-lock.json. Do not use Lazy sync, which updates it.
  timeout 600 nvim --headless '+Lazy! restore' +qa
  timeout 600 nvim --headless \
    "+lua local ok, err = pcall(function() local langs = {'elixir','heex','eex','lua','haskell','rescript'}; require('nvim-treesitter').install(langs):wait(300000); for _, lang in ipairs(langs) do vim.treesitter.language.add(lang) end end); if not ok then print(err); vim.cmd('cquit 1') end" +qa
}
restore_plugins
