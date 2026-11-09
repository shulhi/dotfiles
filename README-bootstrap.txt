SERVER SETUP WITH MISE

Run as shulhi on Ubuntu 24.04+ or Debian 13+ (glibc 2.39+, x86-64/ARM64),
with sudo and a running systemd user manager. The server account and SSH login
must already exist. The script does not create users, copy private keys, or
grant sudo. On shipyard, shulhi already has permanent passwordless sudo.

QUICK START

    git clone https://github.com/shulhi/dotfiles.git ~/.dotfiles
    bash ~/.dotfiles/bootstrap-server.sh --dry-run
    bash ~/.dotfiles/bootstrap-server.sh

For a minimal machine without Git, copy bootstrap-server.sh to it first. The
entry script installs only the prerequisites/mise, clones missing dotfiles,
then hands off to mise. Existing dotfiles checkouts are reused, never reset.
Debian automatically selects server/mise.debian.toml for the vendor apt URLs.

The desired state is in ~/.dotfiles/server/mise.toml:
  * apt packages, official Docker/Tailscale/Rex sources and signing fingerprints;
  * Docker group membership for shulhi; Fish as the login shell;
  * mise-managed, pinned Node.js, Rust, Neovim, fzf, eza, lazygit, tree-sitter,
    Starship, and GitHub CLI;
  * Neovim/Fish/Starship dotfile links and global mise tool selection;
  * the two ShipPDF repositories and Portside checkout;
  * system Docker/Tailscale services, Rex's personal socket and --tailscale
    drop-in, and a persistent user Portside service.

Small shell helpers cover the operations that need custom logic: adopting the
old vendor apt files, Git/SSH configuration, native Claude/Codex installers,
Neovim plugin restore, and compiling Portside. The former monolithic installer
is replaced; no hidden copy of it remains in the setup.

PREVIEW, APPLY, AND VERIFY

    bash ~/.dotfiles/bootstrap-server.sh --dry-run
    bash ~/.dotfiles/bootstrap-server.sh
    mise -C ~/.dotfiles/server bootstrap plan
    mise -C ~/.dotfiles/server bootstrap status
    mise -C ~/.dotfiles/server run verify

On Debian, use mise -E debian -C ~/.dotfiles/server for direct mise commands.
The entry script chooses this automatically.

The entry script explicitly trusts only this setup for that process.
For direct mise commands, first review and trust the files yourself:

    mise trust ~/.dotfiles/server/mise.toml
    # Debian only:
    mise trust ~/.dotfiles/server/mise.debian.toml

Mise's resource plan covers packages, accounts, files and services. Its complete
--dry-run also previews repos, dotfiles, tools, hooks and tasks. Hooks are only
printed in a dry run. A Mac preview points you to the Linux configuration;
compare against actual machine state by running the preview on the server.

Old per-tool --skip-* switches were replaced by declarations and mise filters:

    bash ~/.dotfiles/bootstrap-server.sh --only packages
    bash ~/.dotfiles/bootstrap-server.sh --skip task
    mise -C ~/.dotfiles/server run portside

--skip task omits native Claude/Codex setup and Neovim plugin restoration.
SKIP_CLAUDE=1 or SKIP_CODEX=1 can omit either native installer individually.
--only/--skip use mise's bootstrap PART names, not individual tool names.
Applying a single part does not imply its prerequisites or hooks have run.

Versions are pinned in [vars] in server/mise.toml. Edit them there; the generated
global tool profile makes those same versions available outside this directory.
Review the plan and rerun setup after changes. For intentional repository updates:

    bash ~/.dotfiles/bootstrap-server.sh --update

Without --update, existing repos retain their current commits. Dirty checkouts,
wrong origins, or conflicting destinations stop mise instead of discarding work.
--upgrade upgrades packages/tools within the declared pins; it does not change
the pinned versions. System apt packages are not frozen to exact release versions.

GIT, GITHUB, AND SHIPPDF

Repositories live at:
    ~/Dev/codemorehq/shippdf/shippdf-marketing
    ~/Dev/codemorehq/shippdf/shippdf-app
    ~/Dev/portside

ShipPDF's private repositories require an authorized GitHub credential before
the repos step. The bootstrap uses ~/.ssh/id_ed25519_github when present, or an
existing key selected by GITHUB_SSH_KEY=/absolute/path. It writes the managed
github.com SSH identity block while preserving unrelated host configuration.
It does not generate, upload, or copy private keys. GitHub's published Ed25519
host key is pinned; unexpected host-key changes require an explicit update.

Missing global Git defaults are filled with Shulhi Sapli,
913103+shulhi@users.noreply.github.com, and nvim. A conditional include sets the
ShipPDF author and chosen SSH identity only under ~/Dev/codemorehq/shippdf/.
Use GIT_NAME/GIT_EMAIL or SHIPPDF_GIT_NAME/SHIPPDF_GIT_EMAIL to override them.
Existing signing configuration is retained; Mac-specific 1Password signing
programs are not copied to Linux.

Git SSH access and gh API login are separate. Authenticate native tools as needed:
    gh auth login
    claude
    codex

DOCKER AND FISH

shulhi is declared a member of docker. This grants root-equivalent access.
Reconnect after first setup to refresh groups, or use newgrp docker in an
existing terminal. Existing supplementary groups are preserved.

Fish reads mise shims in non-interactive sessions and activates mise
interactively through the Fish dotfiles. Verify from a fresh SSH session:
    node --version
    npm --version
    gh --version
    docker info

TAILSCALE, REX, AND PORTSIDE

The host tailscaled service is installed, enabled, and started. Join interactively:
    sudo tailscale up

Use the same account as your Mac/phone and an untagged host device. Existing
Tailscale identity is retained. Rex's embedded Tailscale node is separate and
does not replace the host Tailscale client Portside needs.

Rex's user drop-in runs:
    /usr/bin/rex server run --log-format text --tailscale --tailscale-hostname <hostname>-rex

The personal Rex socket is enabled. Existing running Rex sessions are left
running during migration. For first-time remote setup:
    systemctl --user enable --now rex.service
    journalctl --user -u rex.service -f

Authorize the embedded node from the URL in its log when required. Do not stop
or restart Rex casually while it owns active terminals.

Only Portside's Rust SERVER is built with cargo build --release --locked.
Its checkout is ~/Dev/portside; the executable is ~/portside-server.
Mise manages the persistent user service dev.mise.portside.service:
    systemctl --user status dev.mise.portside
    journalctl --user -u dev.mise.portside -n 30 --no-pager
    mise -C ~/.dotfiles/server run portside

The service resolves the host Tailscale IPv4 address at startup and listens on
port 9417. It retries after failures. If initial host login takes a while:
    systemctl --user reset-failed dev.mise.portside
    systemctl --user restart dev.mise.portside

Portside itself enforces the connecting device's Tailscale owner identity.
No Tailscale Serve/Funnel or public listener is configured. In the Portside
client, enter shipyard.taildaac1.ts.net and port 9417 (for shipyard), or the new
host's Tailscale IPv4/MagicDNS name. The default target policy allows loopback
ports 1024-65535, excluding its listener. Tailnet ACLs/grants also apply.

Uploads go to ~/PortsideUploads. Existing PORTSIDE_LISTEN/PORTSIDE_UPLOAD_DIR
overrides in ~/.config/portside/server.env are retained. This file is sourced as
the service user; keep it private and do not put untrusted shell code there.
Remove PORTSIDE_LISTEN to resolve the Tailscale IP dynamically on each start.

Lingering is enabled for shulhi so Portside and Rex can survive logout and boot.
Migration disables the old portside.service after the build, handing its listener
to mise. Its old unit is retained so it can be restored manually if needed.

BACKUPS AND MIGRATION

Old standalone tool binaries are moved from ~/.local/bin to:
    ~/.local/state/server-bootstrap/backups/<timestamp>-<pid>/

They no longer shadow mise's selected versions. Native Claude/Codex remain in
~/.local/bin. Existing Neovim data and plugin directories are retained.

The three old vendor apt definitions are backed up before mise adopts them:
docker.sources/docker.list, tailscale.list, and rex.sources. Unexpected source
URLs stop the migration. mise writes mise-*.sources with fingerprint-checked
inline signing keys, avoiding conflicting Signed-By definitions.
Conflicting managed dotfile links/configs are also backed up before deployment.

The sudo policy and authorized_keys are not managed by this configuration.
Dropping a declaration leaves the installed resource in place; use explicit
mise removal state only when you intend to remove it.

VALIDATION AND REFERENCES

The full mise bootstrap passed on shipyard (Ubuntu 26.04 x86-64), including
native AI CLI checks and pinned Neovim plugin/parser restoration. A second run
with --skip task preserved configuration hashes and both Portside/Rex process
IDs. mise bootstrap plan reported 31 unchanged resources, zero changes and no
unknown state. Fresh Fish SSH sessions selected mise shims for the managed
tools, and Docker worked without sudo. Lock metadata covers Linux x86-64 and
ARM64; Debian and ARM64 were not runtime-tested during this migration.

Portside 0.3.0 was built on shipyard with Rust 1.99.1. Authenticated /v1/info
and a real Mac -> Tailscale -> Portside WebSocket -> loopback HTTP forwarding
check passed. Its existing client_half_close_preserves_the_response test fails
repeatedly on this host while waiting for the final WebSocket close; response
bytes and EOF are received first. Other unit, CLI, tunnel, and upload tests pass.
The setup migration does not modify Portside source code to mask that failure.

    https://mise.jdx.dev/bootstrap.html
    https://mise.jdx.dev/bootstrap/packages/apt.html
    https://mise.jdx.dev/bootstrap/services.html
    https://mise.jdx.dev/bootstrap/repos.html
    https://github.com/shulhi/portside/tree/main/server
