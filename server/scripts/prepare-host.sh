#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
[[ $(uname -s) == Linux && $EUID != 0 ]] || die 'Run as a normal sudo user on Linux'
source /etc/os-release
case "$ID" in
  ubuntu) (( ${VERSION_ID%%.*} >= 24 )) || die 'Ubuntu 24.04+ is required' ;;
  debian) (( ${VERSION_ID%%.*} >= 13 )) || die 'Debian 13+ is required' ;;
  *) die 'Only Ubuntu and Debian are supported' ;;
esac
dpkg --compare-versions "$(getconf GNU_LIBC_VERSION | awk '{print $2}')" ge 2.39 || die 'glibc 2.39+ is required'
for package in docker.io docker-compose docker-compose-v2 docker-doc docker-buildx podman-docker containerd runc; do
  [[ $(dpkg-query -W -f='${Status}' "$package" 2>/dev/null || true) != 'install ok installed' ]] ||
    die "Resolve conflicting package first: $package"
done
sudo -v
# Adopt ONLY the old bootstrap/vendor source definitions. mise writes its own
# fingerprint-checked, inline-key sources; two Signed-By definitions conflict.
for item in docker.sources docker.list tailscale.list rex.sources; do
  path=/etc/apt/sources.list.d/$item
  [[ -e $path ]] || continue
  case "$item" in
    docker.*) expected=https://download.docker.com/linux/ ;;
    tailscale.list) expected=https://pkgs.tailscale.com/stable/ ;;
    rex.sources) expected=https://pkgs.superlogical.com/rex/apt ;;
  esac
  # Refuse unexpected sources rather than hiding an administrator's changes.
  python3 - "$path" "$expected" <<'PY'
import pathlib, re, sys
text = pathlib.Path(sys.argv[1]).read_text()
urls = re.findall(r'https?://[^\s]+', '\n'.join(line for line in text.splitlines() if not line.lstrip().startswith('#')))
if not urls or any(not u.startswith(sys.argv[2]) for u in urls):
    raise SystemExit(f'Refusing to adopt unexpected apt source: {sys.argv[1]}')
PY
  sudo install -d -m 0700 "$BACKUP_DIR/apt"
  sudo cp -a -- "$path" "$BACKUP_DIR/apt/$item"
  sudo rm -- "$path"
  printf 'Saved old apt source: %s\n' "$BACKUP_DIR/apt/$item"
done
