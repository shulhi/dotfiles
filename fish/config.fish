# Homebrew (zsh gets this from ~/.zprofile)
test -x /opt/homebrew/bin/brew; and /opt/homebrew/bin/brew shellenv fish | source

# OrbStack
test -r ~/.orbstack/shell/init2.fish; and source ~/.orbstack/shell/init2.fish

## ENV
set -gx LC_ALL en_US.UTF-8
set -gx LANG en_US.UTF-8
set -gx NINJA_ANSI_FORCED 0
test -e /usr/lib/locale/locale-archive; and set -gx LOCALE_ARCHIVE /usr/lib/locale/locale-archive

set -gx EDITOR nvim
set -gx EXA_COLORS "oc=0"

set -gx FZF_DEFAULT_COMMAND 'rg --files --hidden --follow --no-ignore-vcs -g "!{**/node_modules,.git,**/dist-newstyle,**/*.cmj,**/*.cmi,**/*.cmt,**/lib/bs,**/lib/js,**/dist/build,_build,.elixir_ls,priv/static,deps}"'

set -gx LocalDevResultFolder ~/Plow/all/result
set -gx LocalDevSiteBuildFolder ~/Plow/plow-configs/local-dev-testing/sitebuild
set -gx LocalDevDockerComposeFolder ~/Plow/plow-configs/local-dev-testing/sitebuild
set -gx LocalDevTestingPath ~/Plow/plow-configs/local-dev-testing

test -d /usr/lib/jvm/java-20-openjdk-amd64; and set -gx JAVA_HOME /usr/lib/jvm/java-20-openjdk-amd64

## PATH
# fish_add_path skips directories that don't exist, so Linux-only paths are harmless here
fish_add_path -ga /usr/local/go/bin ~/go/bin
fish_add_path -gm /usr/local/bin ~/.local/bin
fish_add_path -gm ~/.local/share/nvim/mason/bin

# Rust / Haskell
fish_add_path -gm ~/.cargo/bin ~/.cabal/bin

# ASDF
set -gx ASDF_DATA_DIR ~/.asdf
fish_add_path -gm $ASDF_DATA_DIR/shims

# opam
test -r ~/.opam/opam-init/init.fish; and source ~/.opam/opam-init/init.fish >/dev/null 2>/dev/null; or true

if status is-interactive
    set -g fish_greeting

    ## ALIAS
    alias git-graph-all "git log --graph --decorate --all"
    alias grep-src "grep -nIEr --color=ALWAYS"
    alias vim nvim
    alias vimdiff "nvim -d"

    alias plow "cd ~/Plow/all"
    alias devel "cd ~/Devel"
    alias projects "cd ~/Devel/projects"
    alias onping "cd ~/Plow/all/onping2.0 && nvim ."
    alias rrof "cd ~/Plow/all/re-react-onping-frontend && nvim ."

    # File system
    alias ls 'eza -lh -o --icons=never --group-directories-first --time-style="+%Y-%m-%d %H:%M" -r -s modified'
    alias lsa "ls -a"
    alias lt "eza --tree --level=2 --long --icons --git"
    alias lta "lt -a"

    type -q fzf; and fzf --fish | source
    type -q starship; and starship init fish | source
    type -q mise; and mise activate fish | source
end

function fish_user_key_bindings
    bind ctrl-p history-prefix-search-backward
    bind ctrl-n history-prefix-search-forward
end
