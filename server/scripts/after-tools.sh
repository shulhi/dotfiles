#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
mise reshim
# mise now owns these tools. Preserve old standalone binaries so ~/.local/bin
# cannot shadow the selected mise versions in non-interactive Fish sessions.
for tool in nvim fzf eza lazygit tree-sitter starship gh; do
  [[ ! -e $LOCAL_BIN/$tool && ! -L $LOCAL_BIN/$tool ]] || backup_conflict "$LOCAL_BIN/$tool"
done
if ! command -v fd >/dev/null && command -v fdfind >/dev/null; then
  ln -s "$(command -v fdfind)" "$LOCAL_BIN/fd"
fi
bash "$SERVER_DIR/scripts/portside-build.sh"
# Hand off the old, upstream unit to mise without two listeners fighting.
if systemctl --user is-enabled --quiet portside.service 2>/dev/null ||
   systemctl --user is-active --quiet portside.service; then
  systemctl --user disable --now portside.service
fi
systemctl --user daemon-reload
