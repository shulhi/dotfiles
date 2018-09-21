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
alias grep-src="grep -inIEr --color=ALWAYS"
alias vim="nvim"
alias vimdiff='nvim -d'
export EDITOR=nvim

## PATH
export PATH="/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"
export PATH="/usr/local/bin:$HOME/.local/bin:$PATH"

# Go
export PATH="$PATH:/usr/local/go/bin"
export GOPATH="$HOME/.golang"

# Rust
export PATH="$HOME/.cargo/bin:$PATH"
export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"
export LD_LIBRARY_PATH="$(rustc --print sysroot)/lib"

# Pyenv
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# GHC
export PATH="$HOME/.cabal/bin:/opt/ghc/7.10.3/bin:$PATH"

# NPM
export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="$(yarn global bin):$PATH"


. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash

. /home/shulhi/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true
