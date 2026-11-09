#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
# Preserve conflicts before mise creates the declared links.
for item in '.config/nvim:vim/nvim' '.config/fish/config.fish:fish/config.fish' '.config/starship.toml:starship2.toml'; do
  destination=$HOME/${item%%:*}
  source_path=$DOTFILES_DIR/${item#*:}
  if [[ -e $destination || -L $destination ]]; then
    [[ -L $destination && $(realpath -m "$destination") == "$(realpath -m "$source_path")" ]] ||
      backup_conflict "$destination"
  fi
done
