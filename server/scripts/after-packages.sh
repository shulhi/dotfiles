#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
if ! locale -a | grep -qi '^en_US\.utf8$'; then
  sudo localedef -i en_US -f UTF-8 en_US.UTF-8
fi
sudo loginctl enable-linger "$CURRENT_USER"
systemctl --user daemon-reload
