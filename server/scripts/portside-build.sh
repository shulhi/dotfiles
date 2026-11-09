#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
repo=$HOME/Dev/portside
[[ -f $repo/server/Cargo.lock ]] || die "Missing Portside checkout: $repo"
mise exec -- cargo build --release --locked --manifest-path "$repo/server/Cargo.toml"
if ! cmp -s "$repo/server/target/release/portside-server" "$HOME/portside-server"; then
  install -m 0755 "$repo/server/target/release/portside-server" "$HOME/.portside-server.new"
  mv -f "$HOME/.portside-server.new" "$HOME/portside-server"
  # Existing mise service only: the first bootstrap starts it after this hook.
  if systemctl --user is-active --quiet dev.mise.portside.service; then
    systemctl --user restart dev.mise.portside.service
  fi
fi
