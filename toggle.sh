#!/bin/sh

if [ $# -eq 0 ]; then
  if grep -q dark "$HOME/.theme"; then
    theme=light
  else
    theme=dark
  fi
else
  theme="$1"
fi

# CHANGE THE THEMES TO THE ONES RELEVANT TO YOU
if [ "$theme" = "dark" ]; then
  kitty +kitten themes --reload-in=all Gruvbox Dark Hard
  echo 'dark' > "$HOME/.theme"
else
  # kitty +kitten themes --reload-in=all One Half Light
  kitty +kitten themes --cache-age=0 --reload-in=all Catppuccin Kitty Latte
  # kitty +kitten themes --cache-age=0 --reload-in=all Tokyo Night Day
  echo 'light' > "$HOME/.theme"
fi

# DARK_THEME="$HOME/.kitty-themes/themes/OneHalfDark.conf"
# LIGHT_THEME="$HOME/.kitty-themes/themes/OneHalfLight.conf"
# THEME_LINK="$HOME/.config/kitty/theme.conf"
# 
# if [[ "$(readlink $THEME_LINK)" = $DARK_THEME ]]; then
#   rm $THEME_LINK
#   ln -s $LIGHT_THEME $THEME_LINK
# 
#   # sed -i '0,/--theme="TwoDark"/{s/--theme="TwoDark"/--theme="GitHub"/}' $HOME/.config/bat/config
#   sed -i '0,/set background=dark/{s/set background=dark/set background=light/}' $HOME/.config/nvim/init.vim
# else
#   rm $THEME_LINK
#   ln -s $DARK_THEME $THEME_LINK
# 
#   # sed -i '0,/--theme="GitHub"/{s/--theme="GitHub"/--theme="TwoDark"/}' $HOME/.config/bat/config
#   sed -i '0,/set background=light/{s/set background=light/set background=dark/}' $HOME/.config/nvim/init.vim
# fi
# 
# 
# KITTY_PID=$(ps aux | grep kitty | awk '{print $2;exit}')
# 
# kill -USR1 $KITTY_PID
# killall -USR1 nvim
# 
# exit 0
