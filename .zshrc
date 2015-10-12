export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
## ZSH
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="gentoo-custom"

# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
plugins=(git)

source $ZSH/oh-my-zsh.sh

## ALIAS
alias git-graph-all="git log --graph --decorate --all"

## PATH
export PATH="$PATH:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"
export PATH="/usr/local/bin:$PATH"

## Platform specific
if [[ $(uname) == 'Darwin' ]]; then
  # NVM
  export NVM_DIR=~/.nvm
  source $(brew --prefix nvm)/nvm.sh

  # Pyenv
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/shims:$PATH"

  # Boot2Docker
  eval $(boot2docker shellinit 2>/dev/null)
elif [[ $(uname) == 'Linux' ]]; then
  # Pyenv
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
fi

## Common

# Pyenv
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi

# golang
export GOPATH="$HOME/.go"
export PATH="$GOPATH/bin:$PATH"
