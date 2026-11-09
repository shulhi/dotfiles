#!/usr/bin/env bash
set -Eeuo pipefail
umask 077
# Keep the existing upstream unit's upload/listen overrides when migrating.
if [[ -f $HOME/.config/portside/server.env ]]; then
  source "$HOME/.config/portside/server.env"
fi
ip=$(/usr/bin/tailscale ip -4)
exec "$HOME/portside-server" serve \
  --listen "${PORTSIDE_LISTEN:-$ip:9417}" \
  --tailscale-bin /usr/bin/tailscale \
  --upload-dir "${PORTSIDE_UPLOAD_DIR:-$HOME/PortsideUploads}"
