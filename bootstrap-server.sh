#!/usr/bin/env bash
# Bootstrap Shulhi's Ubuntu/Debian server. Run as your normal sudo-capable user.
# Preview anywhere: bash bootstrap-server.sh --dry-run
set -Eeuo pipefail

DOTFILES_REPO=${DOTFILES_REPO:-https://github.com/shulhi/dotfiles.git}
GIT_NAME=${GIT_NAME:-Shulhi Sapli}
GIT_EMAIL=${GIT_EMAIL:-913103+shulhi@users.noreply.github.com}
NVIM_VERSION=${NVIM_VERSION:-latest}
NODE_VERSION=${NODE_VERSION:-lts}
SHIPPDF_ROOT=$HOME/Dev/codemorehq/shippdf
SHIPPDF_GIT_NAME=${SHIPPDF_GIT_NAME:-$GIT_NAME}
SHIPPDF_GIT_EMAIL=${SHIPPDF_GIT_EMAIL:-$GIT_EMAIL}
SHIPPDF_GIT_TRANSPORT=${SHIPPDF_GIT_TRANSPORT:-ssh}
GITHUB_SSH_KEY=${GITHUB_SSH_KEY:-}
REX_CHANNEL=${REX_CHANNEL:-}
DRY_RUN=0
WITH_DOCKER=1
WITH_TAILSCALE=1
WITH_REX=1
WITH_CLAUDE=1
WITH_CODEX=1
WITH_GH=1
WITH_NODE=1
WITH_SHIPPDF=1
WITH_PLUGINS=1
CHANGE_SHELL=1
DOCKER_GROUP=1
TMP_WORK=

log() { printf '\n==> %s\n' "$*"; }
die() { printf 'Error: %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

usage() {
  cat <<'EOF'
Usage: bash bootstrap-server.sh [options]

Supports Ubuntu 24.04+ / Debian 13+, amd64 or arm64, with systemd and sudo.
Run as the account you intend to use, WITHOUT sudo in front of the script.

  --dry-run         Print the plan; perform no changes or downloads
  --skip-docker     Skip Docker Engine, Compose, and Buildx
  --skip-tailscale  Skip Tailscale
  --skip-rex        Skip Superlogical Rex
  --skip-claude     Skip Claude Code CLI
  --skip-codex      Skip OpenAI Codex CLI
  --skip-gh         Skip GitHub CLI
  --skip-node       Skip mise and its Node.js setup
  --skip-shippdf    Skip ShipPDF repository cloning and scoped Git configuration
  --skip-plugins    Let Neovim install its plugins on first launch instead
  --no-chsh         Leave your login shell unchanged
  --docker-group   Enable Docker group setup (default; root-equivalent access)
  --no-docker-group Skip Docker group setup
  -h, --help       Show this help

Environment:
  DOTFILES_REPO    Clone URL (default: https://github.com/shulhi/dotfiles.git)
  GIT_NAME        Git author name, set only if currently missing
  GIT_EMAIL       Git author email, set only if currently missing
  NVIM_VERSION    GitHub tag, e.g. v0.12.6 (default: latest stable)
  NODE_VERSION    mise Node.js version, e.g. 22 or 22.14.0 (default: lts)
  SHIPPDF_GIT_NAME  Author name for repositories under ~/Dev/codemorehq/shippdf/
  SHIPPDF_GIT_EMAIL Author email for those repositories (defaults to GIT_EMAIL)
  SHIPPDF_GIT_TRANSPORT ssh or https (default: ssh; authenticate Git first)
  GITHUB_SSH_KEY   Optional existing private-key path; automatically uses
                   ~/.ssh/id_ed25519_github when present
  REX_CHANNEL     Optional stable, preview, or snapshot; omitted uses vendor default

Existing ~/.dotfiles is reused without pulling, resetting, or cleaning it.
Conflicting managed files are moved into ~/.local/state/server-bootstrap/backups/.
Tailscale, Claude, Codex, and GitHub CLI authentication follow installation.
Rex remote access is configured separately after installation.
EOF
}

parse_args() {
  while (($#)); do
    case "$1" in
      --dry-run) DRY_RUN=1 ;;
      --skip-docker) WITH_DOCKER=0 ;;
      --skip-tailscale) WITH_TAILSCALE=0 ;;
      --skip-rex) WITH_REX=0 ;;
      --skip-claude) WITH_CLAUDE=0 ;;
      --skip-codex) WITH_CODEX=0 ;;
      --skip-gh) WITH_GH=0 ;;
      --skip-node) WITH_NODE=0 ;;
      --skip-shippdf) WITH_SHIPPDF=0 ;;
      --skip-plugins) WITH_PLUGINS=0 ;;
      --no-chsh) CHANGE_SHELL=0 ;;
      --docker-group) DOCKER_GROUP=1 ;;
      --no-docker-group) DOCKER_GROUP=0 ;;
      -h|--help) usage; exit 0 ;;
      *) die "Unknown option: $1 (see --help)" ;;
    esac
    shift
  done
  case "$REX_CHANNEL" in ''|stable|preview|snapshot) ;; *) die 'Invalid REX_CHANNEL' ;; esac
  [[ "$NVIM_VERSION" =~ ^[A-Za-z0-9._-]+$ ]] || die 'Invalid NVIM_VERSION'
  [[ "$NODE_VERSION" =~ ^[A-Za-z0-9][A-Za-z0-9._/-]*$ ]] || die 'Invalid NODE_VERSION'
  case "$SHIPPDF_GIT_TRANSPORT" in ssh|https) ;; *) die 'SHIPPDF_GIT_TRANSPORT must be ssh or https' ;; esac
}

print_plan() {
  cat <<EOF
Target: Ubuntu 24.04+ / Debian 13+, x86-64 or ARM64, systemd.
Account: the normal user running the script; privileged steps use sudo.
1. Install Git, Fish, ripgrep, fd, C build tools, Python, locales, and archive tools.
2. Reuse ~/.dotfiles, or clone ${DOTFILES_REPO} into it.
3. Install compatible Neovim (${NVIM_VERSION}), fzf, eza, lazygit, tree-sitter, and Starship.
   Existing working tools are kept; Neovim/tree-sitter/fzf compatibility is checked.
   GitHub binary downloads are checked against their published SHA-256 digests.
4. Back up conflicting files, then link:
   ~/.config/nvim          -> ~/.dotfiles/vim/nvim
   ~/.config/fish/config.fish -> ~/.dotfiles/fish/config.fish
   ~/.config/starship.toml -> ~/.dotfiles/starship2.toml
   Rex config is linked only if rex/init.linux.lua exists in your dotfiles.
5. Fill missing Git name/email/editor values; generate en_US.UTF-8 for Fish.
EOF
  ((WITH_DOCKER == 0)) || printf '6. Install official Docker Engine + Compose + Buildx and enable docker.service.\n'
  ((WITH_TAILSCALE == 0)) || printf '7. Install official Tailscale and enable tailscaled.service; login remains manual.\n'
  ((WITH_REX == 0)) || printf '8. Install Superlogical Rex via its official installer; enable its personal user socket if supplied.\n'
  ((WITH_PLUGINS == 0)) || printf '9. Restore Neovim plugins from lazy-lock.json and install configured Tree-sitter parsers.\n'
  ((CHANGE_SHELL == 0)) || printf '10. Set Fish as this account\047s login shell.\n'
  ((DOCKER_GROUP == 0 || WITH_DOCKER == 0)) || printf '11. Add this account to the root-equivalent docker group.\n'
  ((WITH_CLAUDE == 0)) || printf 'Install Claude Code for this user with its official native installer (no Node.js required).\n'
  ((WITH_CODEX == 0)) || printf 'Install Codex CLI for this user with its official standalone installer (no Node.js required).\n'
  ((WITH_GH == 0)) || printf 'Install GitHub CLI (gh) from its verified official binary release.\n'
  ((WITH_NODE == 0)) || printf 'Install mise and Node.js (%s) with npm; pin the resolved global version and configure Fish shims.\n' "$NODE_VERSION"
  if ((WITH_SHIPPDF)); then
    printf 'Configure Git identity and existing SSH credentials for ShipPDF repositories.\n'
    printf 'Clone ShipPDF/shippdf-marketing and ShipPDF/shippdf-app over %s under %s/.\n' "$SHIPPDF_GIT_TRANSPORT" "$SHIPPDF_ROOT"
    printf 'Existing checkouts and local changes are preserved; unexpected destinations stop setup.\n'
  fi
  printf 'No SSH keys, credentials, shell history, or Tailscale identity are copied.\n'
}

preflight() {
  [[ $(uname -s) == Linux ]] || die 'This installer targets Linux. Use --dry-run to preview on macOS.'
  ((EUID != 0)) || die 'Run as your normal sudo-capable account, without sudo. Root execution would configure /root.'
  [[ -r /etc/os-release ]] || die '/etc/os-release is missing'
  # shellcheck disable=SC1091
  source /etc/os-release
  case "${ID:-}" in
    ubuntu) [[ ${VERSION_ID%%.*} -ge 24 ]] || die 'Ubuntu 24.04 or later is required' ;;
    debian) [[ ${VERSION_ID%%.*} -ge 13 ]] || die 'Debian 13 or later is required (upstream tree-sitter needs newer glibc)' ;;
    *) die "Unsupported distribution: ${ID:-unknown}. Expected Ubuntu or Debian." ;;
  esac
  [[ -n ${VERSION_CODENAME:-} ]] || die 'Cannot determine the distribution codename'
  local libc_version
  libc_version=$(getconf GNU_LIBC_VERSION)
  dpkg --compare-versions "${libc_version##* }" ge 2.39 || die 'The upstream tree-sitter binary requires glibc 2.39 or later'
  DISTRO=$ID
  CODENAME=$VERSION_CODENAME
  case "$(uname -m)" in
    x86_64) ARCH=amd64; NVIM_ARCH=x86_64; EZA_ARCH=x86_64; LAZYGIT_ARCH=x86_64; TS_ARCH=x64 ;;
    aarch64|arm64) ARCH=arm64; NVIM_ARCH=arm64; EZA_ARCH=aarch64; LAZYGIT_ARCH=arm64; TS_ARCH=arm64 ;;
    *) die 'Only x86-64 and ARM64 are supported' ;;
  esac
  [[ $(dpkg --print-architecture) == "$ARCH" ]] || die 'Kernel and package architectures differ'
  [[ -d /run/systemd/system ]] || die 'A running systemd server is required (not a bare container)'
  have sudo || die 'Install sudo and grant this account sudo access first'
  CURRENT_USER=$(id -un)
  ACCOUNT_HOME=$(getent passwd "$CURRENT_USER" | cut -d: -f6)
  [[ "$HOME" == "$ACCOUNT_HOME" ]] || die 'HOME does not match this account; log in as the intended user'
  [[ -z ${XDG_CONFIG_HOME:-} || $XDG_CONFIG_HOME == "$HOME/.config" ]] || die 'Use the standard ~/.config location for these dotfiles'
  CONFIG_DIR=$HOME/.config
  DOTFILES_DIR=$HOME/.dotfiles
  LOCAL_BIN=$HOME/.local/bin
  STATE_DIR=$HOME/.local/state/server-bootstrap
  BACKUP_DIR=$STATE_DIR/backups/$(date -u +%Y%m%dT%H%M%SZ)-$$
  export PATH="$LOCAL_BIN:/usr/local/bin:$PATH"
  # Refresh sudo now. Each privileged step still uses sudo explicitly.
  sudo -v
}

download() {
  local url=$1 destination=$2
  shift 2
  curl --proto '=https' --tlsv1.2 --fail --silent --show-error --location \
    --retry 3 --connect-timeout 15 --max-time 300 "$@" "$url" -o "$destination"
}

apt_install() {
  sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$@"
}

install_base() {
  log 'Installing base packages'
  sudo apt-get update
  apt_install ca-certificates curl git fish ripgrep fd-find build-essential pkg-config \
    python3 unzip xz-utils locales ncurses-bin openssh-client
  if ! locale -a | grep -qi '^en_US\.utf8$'; then
    sudo localedef -i en_US -f UTF-8 en_US.UTF-8
  fi
  mkdir -p "$LOCAL_BIN" "$STATE_DIR" "$CONFIG_DIR" "$HOME/.local/share"
  if ! have fd && have fdfind; then
    link_config "$(command -v fdfind)" "$LOCAL_BIN/fd"
  fi
}

prepare_dotfiles() {
  if [[ -e "$DOTFILES_DIR" || -L "$DOTFILES_DIR" ]]; then
    [[ -d "$DOTFILES_DIR" ]] || die "$DOTFILES_DIR exists but is not a directory"
    log 'Reusing existing ~/.dotfiles without changing its checkout'
  else
    log 'Cloning dotfiles (private repositories require Git authentication first)'
    git clone -- "$DOTFILES_REPO" "$DOTFILES_DIR"
  fi
  local item
  for item in fish/config.fish starship2.toml vim/nvim/init.lua vim/nvim/lazy-lock.json; do
    [[ -f "$DOTFILES_DIR/$item" ]] || die "Missing dotfile: $item"
  done
  # utils.lua uses this exact path on Linux, including when outside Rex.
  mkdir -p "$DOTFILES_DIR/active-theme"
  [[ -e "$DOTFILES_DIR/active-theme/theme" ]] || printf 'dark\n' > "$DOTFILES_DIR/active-theme/theme"
}

version_at_least() {
  # Compare dotted versions without sort -V (also usable by local macOS checks).
  python3 - "$1" "$2" <<'PY'
import re, sys
def version(s):
    m = re.search(r'(\d+)\.(\d+)(?:\.(\d+))?', s)
    return tuple(int(n or 0) for n in m.groups()) if m else (0, 0, 0)
sys.exit(0 if version(sys.argv[1]) >= version(sys.argv[2]) else 1)
PY
}

release_asset() {
  # Resolve one exact/glob asset from a stable release, then verify before extracting.
  local repo=$1 pattern=$2 output=$3 tag=${4:-latest} endpoint meta selection url digest
  endpoint="https://api.github.com/repos/$repo/releases/latest"
  [[ $tag == latest ]] || endpoint="https://api.github.com/repos/$repo/releases/tags/$tag"
  meta=$(mktemp "$TMP_WORK/release.XXXXXX")
  selection=$(mktemp "$TMP_WORK/asset.XXXXXX")
  download "$endpoint" "$meta"
  python3 - "$meta" "$pattern" > "$selection" <<'PY'
import fnmatch, json, re, sys
with open(sys.argv[1]) as f:
    release = json.load(f)
assets = [a for a in release.get('assets', []) if fnmatch.fnmatchcase(a['name'], sys.argv[2])]
if len(assets) != 1:
    raise SystemExit(f'Expected one release asset matching {sys.argv[2]!r}; found {len(assets)}')
a = assets[0]
digest = a.get('digest') or ''
if not re.fullmatch(r'sha256:[a-f0-9]{64}', digest):
    raise SystemExit(f'No SHA-256 digest published for {a["name"]}; refusing unverified install')
url = a['url']
if not url.startswith('https://api.github.com/repos/'):
    raise SystemExit('Unexpected release download URL')
print(url)
print(digest.split(':', 1)[1])
PY
  url=$(sed -n '1p' "$selection")
  digest=$(sed -n '2p' "$selection")
  # The asset API also works when a network gateway rejects github.com release URLs.
  download "$url" "$output" -H 'Accept: application/octet-stream'
  printf '%s  %s\n' "$digest" "$output" | sha256sum --check --status
}

install_tar_binary() {
  local repo=$1 pattern=$2 binary=$3 dir
  dir=$(mktemp -d "$TMP_WORK/binary.XXXXXX")
  release_asset "$repo" "$pattern" "$dir/archive.tar.gz"
  tar -xzf "$dir/archive.tar.gz" -C "$dir" --no-same-owner
  [[ -f "$dir/$binary" ]] || die "Archive did not contain $binary"
  install -m 0755 "$dir/$binary" "$LOCAL_BIN/$binary"
}

install_cli_tools() {
  log 'Installing editor and shell tools'
  if ! have nvim || ! version_at_least "$(nvim --version)" 0.12.0 || [[ $NVIM_VERSION != latest ]]; then
    local dir destination
    dir=$(mktemp -d "$TMP_WORK/nvim.XXXXXX")
    release_asset neovim/neovim "nvim-linux-$NVIM_ARCH.tar.gz" "$dir/nvim.tar.gz" "$NVIM_VERSION"
    tar -xzf "$dir/nvim.tar.gz" -C "$dir" --no-same-owner
    "$dir/nvim-linux-$NVIM_ARCH/bin/nvim" --version >/dev/null
    destination=$(mktemp -d "$HOME/.local/share/nvim-bootstrap.XXXXXX")
    cp -a "$dir/nvim-linux-$NVIM_ARCH/." "$destination/"
    backup_conflict "$LOCAL_BIN/nvim"
    ln -s "$destination/bin/nvim" "$LOCAL_BIN/nvim"
  fi
  version_at_least "$(nvim --version)" 0.12.0 || die 'Your Neovim config requires Neovim >= 0.12'
  # Older distro fzf packages do not implement the --fish integration your config uses.
  if ! have fzf || ! fzf --fish >/dev/null 2>&1; then
    install_tar_binary junegunn/fzf "fzf-*-linux_$ARCH.tar.gz" fzf
  fi
  if ! have eza; then
    local eza_target="$EZA_ARCH-unknown-linux-gnu"
    [[ $ARCH != amd64 ]] || eza_target=x86_64-unknown-linux-musl
    install_tar_binary eza-community/eza "eza_$eza_target.tar.gz" eza
  fi
  have lazygit || install_tar_binary jesseduffield/lazygit "lazygit_*_linux_$LAZYGIT_ARCH.tar.gz" lazygit
  if ! have tree-sitter || ! version_at_least "$(tree-sitter --version)" 0.26.1; then
    release_asset tree-sitter/tree-sitter "tree-sitter-linux-$TS_ARCH.gz" "$TMP_WORK/tree-sitter.gz"
    gzip -dc "$TMP_WORK/tree-sitter.gz" > "$TMP_WORK/tree-sitter"
    install -m 0755 "$TMP_WORK/tree-sitter" "$LOCAL_BIN/tree-sitter"
  fi
  if ! have starship; then
    local starship_arch=$EZA_ARCH
    install_tar_binary starship/starship "starship-$starship_arch-unknown-linux-musl.tar.gz" starship
  fi
  local tool
  for tool in nvim fzf eza lazygit tree-sitter starship; do "$tool" --version; done
}

install_gh_cli() {
  ((WITH_GH)) || return 0
  log 'Installing GitHub CLI'
  if ! have gh; then
    local dir
    dir=$(mktemp -d "$TMP_WORK/gh.XXXXXX")
    release_asset cli/cli "gh_*_linux_$ARCH.tar.gz" "$dir/gh.tar.gz"
    mkdir -p "$dir/package"
    tar -xzf "$dir/gh.tar.gz" -C "$dir/package" --strip-components=1 --no-same-owner
    [[ -f "$dir/package/bin/gh" ]] || die 'GitHub CLI archive did not contain bin/gh'
    install -m 0755 "$dir/package/bin/gh" "$LOCAL_BIN/gh"
  fi
  gh --version
}

install_mise_node() {
  ((WITH_NODE)) || return 0
  log "Installing mise and Node.js ($NODE_VERSION)"
  if ! have mise; then
    download https://mise.run "$TMP_WORK/mise-install.sh"
    MISE_INSTALL_PATH="$LOCAL_BIN/mise" sh "$TMP_WORK/mise-install.sh"
  fi
  mise --version
  # Work from HOME so a caller's project configuration cannot affect bootstrap.
  # --pin records the exact release resolved from lts or a major-version request.
  (
    cd "$HOME"
    mise use --global --pin --yes "node@$NODE_VERSION"
    mise reshim
    mise exec -- node --version
    mise exec -- npm --version
  )
  # conf.d is read before config.fish. Shims also work for non-interactive SSH
  # commands; the dotfiles add full mise activation for interactive Fish.
  local fish_setup="$CONFIG_DIR/fish/conf.d/10-server-bootstrap-mise.fish"
  cat > "$TMP_WORK/mise.fish" <<'FISH'
# Managed by bootstrap-server.sh: expose mise tools in every Fish session.
if test -x "$HOME/.local/bin/mise"
    "$HOME/.local/bin/mise" activate fish --shims | source
else if type -q mise
    mise activate fish --shims | source
end
FISH
  fish --no-execute "$TMP_WORK/mise.fish"
  if ! cmp -s "$TMP_WORK/mise.fish" "$fish_setup"; then
    backup_conflict "$fish_setup"
    mkdir -p "$(dirname "$fish_setup")"
    install -m 0644 "$TMP_WORK/mise.fish" "$fish_setup"
  fi
}

install_ai_tools() {
  if ((WITH_CLAUDE)); then
    log 'Installing Claude Code CLI'
    if ! have claude; then
      download https://claude.ai/install.sh "$TMP_WORK/claude-install.sh"
      bash "$TMP_WORK/claude-install.sh"
    fi
    claude --version
  fi
  if ((WITH_CODEX)); then
    log 'Installing OpenAI Codex CLI'
    if ! have codex; then
      download https://chatgpt.com/codex/install.sh "$TMP_WORK/codex-install.sh"
      CODEX_NON_INTERACTIVE=1 CODEX_INSTALL_DIR="$LOCAL_BIN" sh "$TMP_WORK/codex-install.sh"
    fi
    codex --version
  fi
}

backup_conflict() {
  local destination=$1
  if [[ -e "$destination" || -L "$destination" ]]; then
    local relative=${destination#"$HOME"/}
    [[ $relative != "$destination" ]] || die "Refusing to back up a path outside HOME: $destination"
    mkdir -p "$BACKUP_DIR/$(dirname "$relative")"
    mv "$destination" "$BACKUP_DIR/$relative"
    printf 'Backed up %s\n' "$destination"
  fi
}

link_config() {
  local source=$1 destination=$2
  [[ -e "$source" ]] || die "Missing source: $source"
  if [[ -L "$destination" && $(readlink "$destination") == "$source" ]]; then return 0; fi
  backup_conflict "$destination"
  mkdir -p "$(dirname "$destination")"
  ln -s "$source" "$destination"
}

configure_dotfiles() {
  log 'Linking dotfiles and setting missing Git defaults'
  link_config "$DOTFILES_DIR/vim/nvim" "$CONFIG_DIR/nvim"
  mkdir -p "$CONFIG_DIR/fish"
  link_config "$DOTFILES_DIR/fish/config.fish" "$CONFIG_DIR/fish/config.fish"
  link_config "$DOTFILES_DIR/starship2.toml" "$CONFIG_DIR/starship.toml"
  # The Mac rex/init.lua unconditionally loads /Users/shulhi/Dev/portside.
  # Linux server configuration is optional and deliberately separate.
  if [[ -f "$DOTFILES_DIR/rex/init.linux.lua" ]]; then
    mkdir -p "$CONFIG_DIR/rex"
    link_config "$DOTFILES_DIR/rex/init.linux.lua" "$CONFIG_DIR/rex/init.lua"
  fi
  configure_git_defaults
  fish --no-execute "$CONFIG_DIR/fish/config.fish"
}

configure_git_defaults() {
  git config --global --get user.name >/dev/null || git config --global user.name "$GIT_NAME"
  git config --global --get user.email >/dev/null || git config --global user.email "$GIT_EMAIL"
  git config --global --get core.editor >/dev/null || git config --global core.editor nvim
}

configure_github_ssh() {
  local key=$1 config_file="$HOME/.ssh/config" staged_config="$TMP_WORK/github-ssh-config"
  [[ -f $key ]] || die "GitHub SSH identity does not exist: $key"
  mkdir -p "$HOME/.ssh"
  python3 - "$config_file" "$key" > "$staged_config" <<'PY'
import pathlib, sys
config, identity = pathlib.Path(sys.argv[1]), sys.argv[2]
if '\n' in identity or '\r' in identity:
    raise SystemExit('Invalid newline in SSH identity path')
start = '# BEGIN server-bootstrap GitHub identity'
end = '# END server-bootstrap GitHub identity'
original = config.read_text() if config.exists() else ''
if start in original or end in original:
    if original.count(start) != 1 or original.count(end) != 1:
        raise SystemExit('Ambiguous managed GitHub SSH block; inspect ~/.ssh/config')
    before, rest = original.split(start, 1)
    managed, after = rest.split(end, 1)
    original = before + after.lstrip('\n')
identity = identity.replace('\\', '\\\\').replace('"', '\\"')
block = '\n'.join([
    start,
    'Host github.com',
    '    HostName github.com',
    '    User git',
    f'    IdentityFile "{identity}"',
    '    IdentitiesOnly yes',
    '# Resume defaults before the rest of the existing configuration.',
    'Host *',
    end,
    '',
])
sys.stdout.write(block + '\n' + original.lstrip('\n'))
PY
  ssh -F "$staged_config" -G github.com >/dev/null 2>&1
  if ! cmp -s "$staged_config" "$config_file"; then
    backup_conflict "$config_file"
    install -m 0600 "$staged_config" "$config_file"
  fi
}

configure_shippdf_git() {
  local config_file="$CONFIG_DIR/git/shippdf.gitconfig" staged_config="$TMP_WORK/shippdf.gitconfig"
  local key=$GITHUB_SSH_KEY ssh_command include_key
  mkdir -p "$SHIPPDF_ROOT" "$(dirname "$config_file")"
  if [[ -e "$config_file" ]]; then cp "$config_file" "$staged_config"; else : > "$staged_config"; fi
  git config --file "$staged_config" user.name "$SHIPPDF_GIT_NAME"
  git config --file "$staged_config" user.email "$SHIPPDF_GIT_EMAIL"
  git config --file "$staged_config" core.editor nvim
  if [[ $SHIPPDF_GIT_TRANSPORT == ssh ]]; then
    if [[ -z $key && -f $HOME/.ssh/id_ed25519_github ]]; then key=$HOME/.ssh/id_ed25519_github; fi
    if [[ -n $key ]]; then
      [[ $key != '~/'* ]] || key="$HOME/${key:2}"
      [[ $key == /* ]] || key="$PWD/$key"
      [[ -f $key ]] || die "GITHUB_SSH_KEY does not name an existing file: $key"
      configure_github_ssh "$key"
      ssh_command=$(python3 - "$key" <<'PY'
import shlex, sys
print('ssh -i ' + shlex.quote(sys.argv[1]) + ' -o IdentitiesOnly=yes')
PY
)
      git config --file "$staged_config" core.sshCommand "$ssh_command"
    fi
  fi
  if ! cmp -s "$staged_config" "$config_file"; then
    backup_conflict "$config_file"
    install -m 0600 "$staged_config" "$config_file"
  fi
  include_key="includeIf.gitdir:$SHIPPDF_ROOT/.path"
  if ! git config --global --get-all "$include_key" | grep -qxF -- "$config_file"; then
    git config --global --add "$include_key" "$config_file"
  fi
}

trust_github_host() {
  # GitHub's published Ed25519 host key, verified against its official docs.
  # A changed upstream host key requires an explicit update here, not blind trust.
  local host_key='github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl'
  printf '%s\n' "$host_key" > "$TMP_WORK/github-host-key"
  [[ $(ssh-keygen -lf "$TMP_WORK/github-host-key" | awk '{print $2}') == SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU ]] || die 'Invalid pinned GitHub host key'
  mkdir -p "$HOME/.ssh"
  if ! grep -qxF -- "$host_key" "$HOME/.ssh/known_hosts" 2>/dev/null; then
    printf '\n%s\n' "$host_key" >> "$HOME/.ssh/known_hosts"
    chmod 0600 "$HOME/.ssh/known_hosts"
  fi
}

clone_shippdf_repo() {
  local repo=$1 url=$2 destination="$SHIPPDF_ROOT/$1" origin actual_root expected_root
  if [[ -e "$destination" || -L "$destination" ]]; then
    [[ -d "$destination" && -e "$destination/.git" ]] || die "Destination exists but is not a Git checkout: $destination"
    actual_root=$(git -C "$destination" rev-parse --show-toplevel)
    expected_root=$(cd "$destination" && pwd -P)
    [[ $actual_root == "$expected_root" ]] || die "Destination is not an independent checkout: $destination"
    origin=$(git -C "$destination" remote get-url origin) || die "Existing checkout has no origin: $destination"
    if ! python3 - "$origin" "$repo" <<'PY'
import re, sys, urllib.parse
url, repo = sys.argv[1:]
if url.startswith(('https://', 'ssh://')):
    parsed = urllib.parse.urlsplit(url)
    host, path = parsed.hostname, parsed.path.lstrip('/')
else:
    match = re.fullmatch(r'(?:git@)?([^:]+):(.+)', url)
    host, path = match.groups() if match else ('', '')
if path.endswith('.git'):
    path = path[:-4]
sys.exit(0 if (host or '').lower() == 'github.com' and path.lower() == f'shippdf/{repo}'.lower() else 1)
PY
    then die "Existing checkout has an unexpected origin: $destination"; fi
    printf 'Keeping existing checkout: %s\n' "$destination"
    return 0
  fi
  log "Cloning ShipPDF/$repo"
  local -a git_command=(git)
  if [[ $SHIPPDF_GIT_TRANSPORT == ssh ]]; then
    local ssh_command
    ssh_command=$(git config --file "$CONFIG_DIR/git/shippdf.gitconfig" --get core.sshCommand || printf 'ssh')
    git_command+=(-c "core.sshCommand=$ssh_command -o BatchMode=yes -o ConnectTimeout=15")
  fi
  if ! GIT_TERMINAL_PROMPT=0 "${git_command[@]}" clone -- "$url" "$destination"; then
    die "Cannot clone ShipPDF/$repo. Authorize an SSH key or HTTPS credential for this private repository, then rerun (or use --skip-shippdf)."
  fi
}

setup_shippdf_repos() {
  ((WITH_SHIPPDF)) || return 0
  log 'Configuring ShipPDF Git settings and repositories'
  configure_git_defaults
  configure_shippdf_git
  [[ $SHIPPDF_GIT_TRANSPORT != ssh ]] || trust_github_host
  local repo url
  for repo in shippdf-marketing shippdf-app; do
    if [[ $SHIPPDF_GIT_TRANSPORT == ssh ]]; then url="git@github.com:ShipPDF/$repo.git";
    else url="https://github.com/ShipPDF/$repo.git"; fi
    clone_shippdf_repo "$repo" "$url"
  done
}

install_docker() {
  ((WITH_DOCKER)) || return 0
  log 'Installing Docker Engine, Compose, and Buildx'
  local package
  for package in docker.io docker-compose docker-compose-v2 docker-doc docker-buildx podman-docker containerd runc; do
    if [[ $(dpkg-query -W -f='${Status}' "$package" 2>/dev/null || true) == 'install ok installed' ]]; then
      die "Conflicting package '$package' is installed. Resolve it first, or use --skip-docker."
    fi
  done
  download "https://download.docker.com/linux/$DISTRO/gpg" "$TMP_WORK/docker.asc"
  sudo install -d -m 0755 /etc/apt/keyrings
  sudo install -m 0644 "$TMP_WORK/docker.asc" /etc/apt/keyrings/docker.asc
  cat > "$TMP_WORK/docker.sources" <<EOF
Types: deb
URIs: https://download.docker.com/linux/$DISTRO
Suites: $CODENAME
Components: stable
Architectures: $ARCH
Signed-By: /etc/apt/keyrings/docker.asc
EOF
  # Avoid rewriting an existing host's repository definitions or mixing keyrings.
  if [[ ! -e /etc/apt/sources.list.d/docker.sources && ! -e /etc/apt/sources.list.d/docker.list ]]; then
    sudo install -m 0644 "$TMP_WORK/docker.sources" /etc/apt/sources.list.d/docker.sources
  fi
  sudo apt-get update
  apt_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo systemctl enable --now docker.service
  if ((DOCKER_GROUP)); then sudo usermod -aG docker "$CURRENT_USER"; fi
  sudo docker info >/dev/null
  docker compose version
  docker buildx version
}

install_tailscale() {
  ((WITH_TAILSCALE)) || return 0
  log 'Installing Tailscale'
  if ! have tailscale; then
    download https://tailscale.com/install.sh "$TMP_WORK/tailscale-install.sh"
    sh "$TMP_WORK/tailscale-install.sh"
  fi
  sudo systemctl enable --now tailscaled.service
  tailscale version
}

install_rex() {
  ((WITH_REX)) || return 0
  log 'Installing Superlogical Rex (not the unrelated distro rex package)'
  download https://pkgs.superlogical.com/rex/install.sh "$TMP_WORK/rex-install.sh"
  local options=()
  [[ -z $REX_CHANNEL ]] || options=(--channel "$REX_CHANNEL")
  sh "$TMP_WORK/rex-install.sh" "${options[@]}"
  rex version
  # Current Rex packages ship a personal user socket. Older packages can still
  # start a personal server with `rex server start`; do not invent unit contents.
  if systemctl --user daemon-reload >/dev/null 2>&1 && systemctl --user cat rex.socket >/dev/null 2>&1; then
    sudo loginctl enable-linger "$CURRENT_USER"
    systemctl --user enable --now rex.socket
  else
    printf 'Personal socket unavailable. Start Rex with: rex server start\n'
  fi
}

restore_plugins() {
  ((WITH_PLUGINS)) || return 0
  log 'Restoring Neovim plugins and installing configured parsers'
  # Restore respects lazy-lock.json. Do not use Lazy sync, which updates it.
  timeout 600 nvim --headless '+Lazy! restore' +qa
  timeout 600 nvim --headless \
    "+lua local ok, err = pcall(function() local langs = {'elixir','heex','eex','lua','haskell','rescript'}; require('nvim-treesitter').install(langs):wait(300000); for _, lang in ipairs(langs) do vim.treesitter.language.add(lang) end end); if not ok then print(err); vim.cmd('cquit 1') end" +qa
}

set_login_shell() {
  ((CHANGE_SHELL)) || return 0
  local fish_path current_shell
  fish_path=$(command -v fish)
  grep -qxF "$fish_path" /etc/shells || printf '%s\n' "$fish_path" | sudo tee -a /etc/shells >/dev/null
  current_shell=$(getent passwd "$CURRENT_USER" | cut -d: -f7)
  [[ $current_shell == "$fish_path" ]] || sudo usermod --shell "$fish_path" "$CURRENT_USER"
}

main() {
  parse_args "$@"
  if ((DRY_RUN)); then print_plan; return 0; fi
  preflight
  TMP_WORK=$(mktemp -d)
  trap '[[ -z ${TMP_WORK:-} ]] || rm -rf -- "$TMP_WORK"' EXIT
  trap 'printf "\nBootstrap failed at line %s. Fix the reported issue, then rerun the script.\n" "$LINENO" >&2' ERR
  install_base
  prepare_dotfiles
  install_cli_tools
  install_gh_cli
  install_mise_node
  install_ai_tools
  configure_dotfiles
  install_docker
  install_tailscale
  install_rex
  restore_plugins
  set_login_shell
  setup_shippdf_repos
  log 'Bootstrap complete'
  printf 'Config backups, if any: %s\n' "$BACKUP_DIR"
  printf 'Reconnect to use your login shell and refreshed group membership.\n'
  ((WITH_TAILSCALE == 0)) || printf '\nJoin the server to your tailnet: sudo tailscale up\n'
  ((WITH_REX == 0)) || printf 'Rex remote access: see README-bootstrap.txt for the Tailscale or SSH setup.\n'
  if ((WITH_DOCKER && !DOCKER_GROUP)); then printf 'Use sudo docker, or rerun with --docker-group.\n'; fi
  ((WITH_CLAUDE == 0)) || printf 'Start Claude Code and sign in: claude\n'
  ((WITH_CODEX == 0)) || printf 'Start Codex CLI and sign in: codex\n'
  ((WITH_GH == 0)) || printf 'Authenticate GitHub CLI when needed: gh auth login\n'
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then main "$@"; fi
