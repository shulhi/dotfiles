#!/usr/bin/env bash
# Shared only by the small imperative setup helpers.
set -Eeuo pipefail
SERVER_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
DOTFILES_DIR=$(cd -- "$SERVER_DIR/.." && pwd)
CONFIG_DIR=$HOME/.config
LOCAL_BIN=$HOME/.local/bin
STATE_DIR=$HOME/.local/state/server-bootstrap
BACKUP_DIR=$STATE_DIR/backups/$(date -u +%Y%m%dT%H%M%SZ)-$$
CURRENT_USER=$(id -un)
GIT_NAME=${GIT_NAME:-Shulhi Sapli}
GIT_EMAIL=${GIT_EMAIL:-913103+shulhi@users.noreply.github.com}
SHIPPDF_ROOT=$HOME/Dev/codemorehq/shippdf
SHIPPDF_GIT_NAME=${SHIPPDF_GIT_NAME:-$GIT_NAME}
SHIPPDF_GIT_EMAIL=${SHIPPDF_GIT_EMAIL:-$GIT_EMAIL}
SHIPPDF_GIT_TRANSPORT=ssh
GITHUB_SSH_KEY=${GITHUB_SSH_KEY:-}
export PATH="$LOCAL_BIN:$PATH"
TMP_WORK=$(mktemp -d)
trap 'rm -rf -- "$TMP_WORK"' EXIT
mkdir -p "$LOCAL_BIN" "$STATE_DIR/backups" "$CONFIG_DIR"
log() { printf '\n==> %s\n' "$*"; }

die() { printf 'Error: %s\n' "$*" >&2; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

download() {
  local url=$1 destination=$2
  shift 2
  curl --proto '=https' --tlsv1.2 --fail --silent --show-error --location \
    --retry 3 --connect-timeout 15 --max-time 300 "$@" "$url" -o "$destination"
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
