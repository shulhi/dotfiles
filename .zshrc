export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
# ==== ZSH
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="gentoo-custom"

# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
plugins=(git)

source $ZSH/oh-my-zsh.sh
# source kvm.sh

# ==== ALIAS
alias powpow="rvm env > .powenv"
alias git-graph-all="git log --graph --decorate --all"

# ==== PATH
export PATH="$PATH:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"
export PATH="/usr/local/bin:$PATH"

# java
# export JAVA_HOME=$(/usr/libexec/java_home)
# export PATH=$JAVA_HOME/bin:$PATH
# export PATH="$HOME/.jenv/bin:$PATH"
# eval "$(jenv init -)"

# golang
export GOPATH="$HOME/.go"
export PATH="$GOPATH/bin:$PATH"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/shims:$PATH"

# export PATH="$HOME/.rvm/bin:$PATH"
export ANDROID_HOME=/usr/local/opt/android-sdk

# ==== PYENV
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi

[ -s "/Users/shulhi/.nvm/nvm.sh" ] && . "/Users/shulhi/.nvm/nvm.sh" # This loads nvm
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
source dnvm.sh

# docker
eval $(boot2docker shellinit 2>/dev/null)
