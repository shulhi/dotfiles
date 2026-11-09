#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
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

configure_git_defaults
configure_shippdf_git
trust_github_host
