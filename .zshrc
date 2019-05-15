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
export EDITOR=nvim

## PATH
export PATH="/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"
export PATH="/usr/local/bin:$HOME/.local/bin:$PATH"

# Rust
export PATH="$HOME/.cargo/bin:$PATH"
export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"
export LD_LIBRARY_PATH="$(rustc --print sysroot)/lib"

# Pyenv
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# GHC
# export PATH="$HOME/.stack/snapshots/x86_64-linux/lts-11.20/8.2.2/bin:$PATH"

# ReasonML/Ocaml
# . /home/shulhi/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true

# NPM
export N_PREFIX="$HOME/.n"; [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"  # Added by n-install (see http://git.io/n-install-repo).
#export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="$(yarn global bin):$PATH"

# ASDF
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash

# if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
#         source /etc/profile.d/vte.sh
# fi

# zsh
bindkey "^P" history-beginning-search-backward
bindkey "^N" history-beginning-search-forward

source /etc/profile.d/nix.sh

export LocalDevResultFolder=~/Plow/all/result
export LocalDevSiteBuildFolder=~/Plow/testOnping/sitebuild
export LocalDevDockerComposeFolder=~/Plow/testOnping/sitebuild
export LocalDevTestingPath=~/Plow/testOnping/
