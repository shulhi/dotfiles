#!/bin/bash

DARK_THEME="$HOME/.kitty-themes/themes/gruvbox_dark.conf"
LIGHT_THEME="$HOME/.kitty-themes/themes/gruvbox_light.conf"
THEME_LINK="$HOME/.config/kitty/theme.conf"

if [[ "$(readlink $THEME_LINK)" = $DARK_THEME ]]; then
  rm $THEME_LINK
  ln -s $LIGHT_THEME $THEME_LINK

  sed -i '0,/--theme="TwoDark"/{s/--theme="TwoDark"/--theme="GitHub"/}' $HOME/.config/bat/config
  sed -i '0,/set background=dark/{s/set background=dark/set background=light/}' $HOME/.config/nvim/init.vim
else
  rm $THEME_LINK
  ln -s $DARK_THEME $THEME_LINK

  sed -i '0,/--theme="GitHub"/{s/--theme="GitHub"/--theme="TwoDark"/}' $HOME/.config/bat/config
  sed -i '0,/set background=light/{s/set background=light/set background=dark/}' $HOME/.config/nvim/init.vim
fi


KITTY_PID=$(ps aux | grep "kitty.app/bin/kitty" | awk '{print $2;exit}')

kill -USR1 $KITTY_PID
killall -USR1 nvim
