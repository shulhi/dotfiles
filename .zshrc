export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export NINJA_ANSI_FORCED=0
export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive

## ZSH
export ZSH=$HOME/.oh-my-zsh
# ZSH_THEME="gentoo-custom"

# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
plugins=(git bgnotify)

source $ZSH/oh-my-zsh.sh

## ALIAS
alias git-graph-all="git log --graph --decorate --all"
alias grep-src="grep -nIEr --color=ALWAYS"
alias vim="nvim"
alias vimdiff='nvim -d'

alias notes="cd ~/notes && nvim index.md"
alias plow="cd ~/Plow/all"
alias devel="cd ~/Devel"
alias projects="cd ~/Devel/projects"
alias onping="cd ~/Plow/all/onping2.0 && nvim ."
alias rrof="cd ~/Plow/all/re-react-onping-frontend && nvim ."
# File system
export EXA_COLORS="$(vivid generate solarized-light)"
export EXA_COLORS="oc=0"
alias ls='eza -lh -o --icons=never --group-directories-first --time-style="+%Y-%m-%d %H:%M" -r -s modified'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'

export EDITOR=nvim

## PATH
export PATH="$PATH:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"
export PATH="/usr/local/bin:$HOME/.local/bin:$PATH"

# Rust
export PATH="$HOME/.cargo/bin:$HOME/.cabal/bin:$PATH"
. "$HOME/.cargo/env"

# ASDF
# . $HOME/.asdf/asdf.sh
# . $HOME/.asdf/completions/asdf.bash
# export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"
# export LD_LIBRARY_PATH="$(rustc --print sysroot)/lib"

export PATH=$PATH:/usr/local/go/bin

# NPM
# export PATH="$(yarn global bin):$PATH"


# . $HOME/.local/share/lscolors.sh

export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-ignore-vcs -g "!{**/node_modules,.git,**/dist-newstyle,**/*.cmj,**/*.cmi,**/*.cmt,**/lib/bs,**/lib/js,**/dist/build,_build,.elixir_ls,priv/static,deps}"'

# zsh
bindkey "^P" history-beginning-search-backward
bindkey "^N" history-beginning-search-forward

export LocalDevResultFolder=~/Plow/all/result
export LocalDevSiteBuildFolder=~/Plow/plow-configs/local-dev-testing/sitebuild
export LocalDevDockerComposeFolder=~/Plow/plow-configs/local-dev-testing/sitebuild
export LocalDevTestingPath=~/Plow/plow-configs/local-dev-testing

export JAVA_HOME=/usr/lib/jvm/java-20-openjdk-amd64


autoload -U +X bashcompinit && bashcompinit


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval "$(starship init zsh)"

if [[ -n "$SSH_CONNECTION" ]]; then
  kitty @ set-tab-color #ffffff #ff0000  # Blue tab for remote
fi


# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
[[ ! -r '/Users/shulhi/.opam/opam-init/init.zsh' ]] || source '/Users/shulhi/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null
# END opam configuration
#
eval "$(mise activate zsh)"
