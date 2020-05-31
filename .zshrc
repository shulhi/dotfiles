export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

## ZSH
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="gentoo-custom"

# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
plugins=(git bgnotify)

source $ZSH/oh-my-zsh.sh

## ALIAS
alias git-graph-all="git log --graph --decorate --all"
alias grep-src="grep -nIEr --color=ALWAYS"
alias vim="nvim"
alias vimdiff='nvim -d'

alias plow="cd ~/Plow/all"
alias devel="cd ~/Devel"
alias projects="cd ~/Devel/projects"
alias peronda="cd ~/Devel/projects/peronda && nvim ."
alias onping="cd ~/Plow/all/onping2.0 && nvim ."
alias onpingfe="cd ~/Plow/all/re-react-onping-frontend && code ."

export EDITOR=nvim

## PATH
export PATH="/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"
export PATH="/usr/local/bin:$HOME/.local/bin:$PATH"

# Rust
# export PATH="$HOME/.cargo/bin:$PATH"
# export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"
# export LD_LIBRARY_PATH="$(rustc --print sysroot)/lib"

# Python
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# NPM
export PATH="$(yarn global bin):$PATH"

# ASDF
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash

if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
  source /etc/profile.d/vte.sh
fi

. $HOME/.local/share/lscolors.sh

export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-ignore-vcs -g "!{**/node_modules,.git,dist-newstyle,*.cmj,*.cmi,*.cmt,_build,.elixir_ls,priv/static,deps}"'
export BAT_THEME="Solarized (dark)"

# zsh
bindkey "^P" history-beginning-search-backward
bindkey "^N" history-beginning-search-forward

source /etc/profile.d/nix.sh

export LocalDevResultFolder=~/Plow/all/result
export LocalDevSiteBuildFolder=~/Plow/testOnping/sitebuild
export LocalDevDockerComposeFolder=~/Plow/testOnping/sitebuild
export LocalDevTestingPath=~/Plow/testOnping/
