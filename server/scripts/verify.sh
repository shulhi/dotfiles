#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
for tool in nvim fzf eza lazygit tree-sitter starship gh op node npm rustc cargo; do
  "$tool" --version
done
fish --no-execute "$CONFIG_DIR/fish/config.fish"
sudo docker info >/dev/null
docker compose version
docker buildx version
rex version
systemctl is-active docker tailscaled
systemctl --user is-active rex.socket dev.mise.portside.service
printf '\nTailscale host state: '
tailscale status --json | python3 -c 'import json,sys; s=json.load(sys.stdin); print(s["BackendState"]); print("Host addresses:", ", ".join(s.get("TailscaleIPs") or []))'
printf 'Native CLI sign-in remains interactive: claude, codex, gh auth login.\n'
printf 'If Tailscale needs login, run sudo tailscale up; Portside will retry automatically.\n'
