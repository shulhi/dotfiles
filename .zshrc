export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export NINJA_ANSI_FORCED=1
export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive

## ZSH
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="gentoo-custom"

# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
plugins=(git bgnotify)

source $ZSH/oh-my-zsh.sh

## ALIAS
alias git-graph-all="git log --graph --decorate --all"
alias grep-src="grep -nIEr --color=ALWAYS"
alias nvim2="XDG_CONFIG_HOME=/home/shulhi/.config/nvim/new_setup nvim"
alias vim="nvim"
alias vimdiff='nvim -d'

alias notes="cd ~/notes && nvim index.md"
alias plow="cd ~/Plow/all"
alias devel="cd ~/Devel"
alias projects="cd ~/Devel/projects"
alias onping="cd ~/Plow/all/onping2.0 && nvim ."
alias rrof="cd ~/Plow/all/re-react-onping-frontend && nvim ."

export EDITOR=nvim

## PATH
export PATH="/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"
export PATH="/usr/local/bin:$HOME/.local/bin:$PATH"

# Rust
export PATH="$HOME/.cargo/bin:$PATH"
# export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"
# export LD_LIBRARY_PATH="$(rustc --print sysroot)/lib"

# Python
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="$PYENV_ROOT/shims:$PATH"

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# NPM
# export PATH="$(yarn global bin):$PATH"

# ASDF
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash

. $HOME/.local/share/lscolors.sh

export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-ignore-vcs -g "!{**/node_modules,.git,**/dist-newstyle,**/*.cmj,**/*.cmi,**/*.cmt,**/lib/bs,**/lib/js,**/dist/build,_build,.elixir_ls,priv/static,deps}"'

# zsh
bindkey "^P" history-beginning-search-backward
bindkey "^N" history-beginning-search-forward

source /etc/profile.d/nix.sh

export LocalDevResultFolder=~/Plow/all/result
export LocalDevSiteBuildFolder=~/Plow/plow-configs/local-dev-testing/sitebuild
export LocalDevDockerComposeFolder=~/Plow/plow-configs/local-dev-testing/sitebuild
export LocalDevTestingPath=~/Plow/plow-configs/local-dev-testing

export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

#[ -f "/home/shulhi/.ghcup/env" ] && source "/home/shulhi/.ghcup/env" # ghcup-env

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/bin/terraform terraform
source <(kubectl completion zsh)

#[ -f "/home/shulhi/.ghcup/env" ] && source "/home/shulhi/.ghcup/env" # ghcup-env

# opam configuration
[[ ! -r /home/shulhi/.opam/opam-init/init.zsh ]] || source /home/shulhi/.opam/opam-init/init.zsh  > /dev/null 2> /dev/null

[ -f "/home/shulhi/.ghcup/env" ] && source "/home/shulhi/.ghcup/env" # ghcup-env
