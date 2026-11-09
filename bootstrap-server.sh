#!/usr/bin/env bash
# First-run entry point. Desired server state lives in server/mise.toml.
set -Eeuo pipefail
repo=${DOTFILES_REPO:-https://github.com/shulhi/dotfiles.git}
dotfiles=$HOME/.dotfiles
minimum_mise=2026.11.4
case "${1:-}" in
  -h|--help)
    cat <<'EOF'
Usage: bash bootstrap-server.sh [mise bootstrap options]

Ubuntu 24.04+ / Debian 13+, glibc 2.39+, amd64 or arm64, systemd, normal sudo user.
Installs mise if necessary, reuses/clones ~/.dotfiles, then runs:
  mise -C ~/.dotfiles/server bootstrap --yes

  --dry-run            Preview without installing or changing files
  --only packages      Apply one mise bootstrap part
  --skip task          Skip native AI CLI installation and Neovim plugin restore
  --update             Refresh apt metadata and fast-forward declared repos
  --upgrade            Upgrade declared packages/tools within their version pins

Versions, packages, repos, files, and services: ~/.dotfiles/server/mise.toml
Native task examples:
  mise -C ~/.dotfiles/server run portside
  mise -C ~/.dotfiles/server run verify
Old per-tool --skip-* flags were replaced by mise config and native part filters.
EOF
    exit 0 ;;
esac
dry_run=0
for arg in "$@"; do [[ $arg != --dry-run && $arg != -n ]] || dry_run=1; done
if ((dry_run)) && [[ $(uname -s) != Linux ]]; then
  printf 'Linux server preview: inspect server/mise.toml for declared packages, tools, repositories, dotfiles, and services.\n'
  printf 'For a live state comparison, run this command on the Ubuntu/Debian server.\n'
  exit 0
fi
[[ $(uname -s) == Linux && $EUID != 0 ]] || { printf 'Run on Linux as the normal sudo user.\n' >&2; exit 1; }
source /etc/os-release
case "$ID" in
  ubuntu) (( ${VERSION_ID%%.*} >= 24 )) ;;
  debian) (( ${VERSION_ID%%.*} >= 13 )) ;;
  *) false ;;
esac || { printf 'Ubuntu 24.04+ or Debian 13+ is required.\n' >&2; exit 1; }
[[ $(uname -m) == x86_64 || $(uname -m) == aarch64 ]] || { printf 'Unsupported architecture.\n' >&2; exit 1; }
[[ -d /run/systemd/system ]] || { printf 'A running systemd host is required.\n' >&2; exit 1; }
[[ $HOME == "$(getent passwd "$(id -un)" | cut -d: -f6)" ]] || { printf 'HOME does not match this account.\n' >&2; exit 1; }
dpkg --compare-versions "$(getconf GNU_LIBC_VERSION | awk '{print $2}')" ge 2.39
export PATH="$HOME/.local/bin:$PATH"
if (( !dry_run )); then
  sudo -v
  # Only the prerequisites needed to read/apply the declarative configuration.
  sudo apt-get update
  sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates curl git gnupg xz-utils
  if ! command -v mise >/dev/null || ! dpkg --compare-versions "$(mise --version | awk 'NR == 1 {print $1}')" ge "$minimum_mise"; then
    installer=$(mktemp)
    trap 'rm -f -- "$installer"' EXIT
    curl --proto '=https' --tlsv1.2 --fail --show-error --silent --location https://mise.run -o "$installer"
    MISE_INSTALL_PATH="$HOME/.local/bin/mise" sh "$installer"
  fi
  [[ -e $dotfiles ]] || git clone -- "$repo" "$dotfiles"
fi
[[ -f $dotfiles/server/mise.toml ]] || { printf 'Missing ~/.dotfiles/server/mise.toml; clone/update your dotfiles first.\n' >&2; exit 1; }
command -v mise >/dev/null || { printf 'Install mise before a live dry run.\n' >&2; exit 1; }
# Trust only this explicitly selected setup for this process; previews save no trust state.
export MISE_TRUSTED_CONFIG_PATHS="$dotfiles/server"
mise_args=()
[[ $ID != debian ]] || mise_args=(-E debian)
exec mise -C "$dotfiles/server" "${mise_args[@]}" bootstrap --yes "$@"
