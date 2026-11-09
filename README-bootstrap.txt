SERVER BOOTSTRAP

Target: Ubuntu 24.04 or newer, or Debian 13 or newer; x86-64 or ARM64.
Requires a normal user with sudo access and a running systemd installation.
Run the script on the NEW SERVER, not on your Mac.
The upstream tree-sitter CLI binary requires glibc 2.39+, so Debian 12 is excluded.

QUICK START

On your Mac, from the directory containing bootstrap-server.sh:

    scp bootstrap-server.sh you@server:~/bootstrap-server.sh
    ssh you@server

On the server, as the account you want to configure:

    bash ~/bootstrap-server.sh --dry-run
    bash ~/bootstrap-server.sh

Do not prefix the script with sudo. It uses sudo only where needed. If the server
only has a root login, create a normal user and grant it sudo access first.

AFTER INSTALLATION

1. Join the server to your existing Tailscale network:

    sudo tailscale up

   Follow the sign-in URL, then check: tailscale status
   Existing Tailscale identity and preferences are preserved on repeat runs.

2. Reconnect to start Fish and refresh any group membership changes.

3. The bootstrap adds your account to the docker group by default, so Docker
   works without sudo after a fresh login. To skip group setup:

    bash ~/bootstrap-server.sh --no-docker-group

   Docker group membership provides root-equivalent access. Existing terminal
   processes retain their old groups. In an existing Rex terminal, run:

    newgrp docker

   A new SSH login also picks up the new membership. --no-docker-group skips
   adding membership; it does not remove an existing membership.

4. Configure Rex remote access using one of the options below.

5. Claude Code and Codex CLI are installed for your account by default:

    claude --version
    codex --version

   Start claude or codex to sign in on the server. Credentials from your Mac
   are not copied. Both use their official standalone installers and do not
   require Node.js/npm. Their commands are available through ~/.local/bin.
   Existing installations are kept on repeat bootstrap runs. To skip either:

    bash ~/bootstrap-server.sh --skip-claude --skip-codex

6. Node.js and npm are installed through mise for your account. The default is
   the current LTS release; its exact resolved version is saved in your global
   mise configuration. Select another major or exact version with:

    NODE_VERSION=22 bash ~/bootstrap-server.sh
    NODE_VERSION=22.14.0 bash ~/bootstrap-server.sh

   Repeat runs resolve NODE_VERSION again, so lts/major requests can pick up newer
   releases. Existing mise installations are kept. Use --skip-node to omit both
   mise and Node.js setup. Node.js is not installed with apt or a system-wide npm.
   Your Fish dotfiles already activate mise interactively. A managed Fish conf.d
   file adds mise shims for non-interactive SSH commands too. Verify with:

    node --version
    npm --version
    mise current node

7. ShipPDF repositories are cloned by default into:

    ~/Dev/codemorehq/shippdf/shippdf-marketing
    ~/Dev/codemorehq/shippdf/shippdf-app

   These private repositories use git@github.com:ShipPDF/<repo>.git by default.
   Authorize the server's SSH key with access to both repositories before running
   bootstrap. If ~/.ssh/id_ed25519_github exists, the bootstrap selects it for
   ShipPDF Git commands and configures Host github.com in ~/.ssh/config with
   User git, that IdentityFile, and IdentitiesOnly yes. It preserves unrelated
   SSH settings and backs up changed files. Otherwise it uses your normal SSH
   config/agent. Set
   GITHUB_SSH_KEY to use another existing key. The bootstrap does not generate,
   copy, or register private keys. GitHub's published Ed25519 host key is pinned
   in the script and added to known_hosts; unknown keys are not blindly accepted.

   For a Git credential helper configured for HTTPS instead:

    SHIPPDF_GIT_TRANSPORT=https bash ~/bootstrap-server.sh

   Setup stops with a clear error if private repository authentication is not
   ready. Use --skip-shippdf to complete machine setup without these repositories.

   Git configuration for all checkouts beneath ~/Dev/codemorehq/shippdf/ comes
   from ~/.config/git/shippdf.gitconfig through a conditional global include.
   It sets your author name/email, Neovim editor, and the existing SSH key when
   selected. Defaults use Shulhi Sapli and your GitHub noreply address. Override
   with SHIPPDF_GIT_NAME / SHIPPDF_GIT_EMAIL for a different work identity.
   Existing signing settings are preserved; SSH/GPG signing is not enabled or
   copied from your Mac automatically.

   Existing matching checkouts are reused without pull/reset/clean or changing
   their origin URL. Local work and branches remain intact. An occupied path
   that is not the expected repository stops setup for manual inspection.

8. GitHub CLI (gh) is installed by default in ~/.local/bin from its official
   binary release, verified against the published SHA-256 digest. Existing gh
   installations are kept. Use --skip-gh to omit this step.

    gh --version
    gh auth login

   GitHub CLI API authentication is separate from Git's SSH key authentication.
   Authenticate for the account/organization permissions you need. Tokens and
   credentials from your Mac are not copied by bootstrap.

REX REMOTE ACCESS

The script installs Superlogical Rex through its official installer. It does not
use the unrelated Debian/Ubuntu package with the same name from the distro repo.
When available, it enables the packaged personal user socket and enables linger
for your account so its user services survive logout. With an older Rex package,
the script prints a manual personal-server start command instead.

For a simple personal Rex connection using built-in Tailscale:

    rex server status

If no server is running yet:

    rex server start --tailscale --tailscale-hostname "$(hostname -s)-rex"

If a personal server is already running, the --tailscale option cannot modify it.
Before creating sessions, stop it and restart it with the options above:

    rex server stop
    rex server start --tailscale --tailscale-hostname "$(hostname -s)-rex"

Stopping Rex ends its sessions, so only do this when there is nothing to preserve.
Read the sign-in URL with rex server status. The tailnet needs MagicDNS and HTTPS
certificates enabled. Add the resulting https://<name>.<tailnet>.ts.net address
in the Rex app on your Mac. Rex's built-in Tailscale creates a separate device
from the host's regular tailscaled connection. These manually supplied server
options are not configured as a persistent service by this bootstrap script;
restart with those options after a reboot, or use the documented service setup.

For using the host's existing Tailscale identity instead, the official remote
access guide covers Tailscale Serve, a tailnet listener, and SSH forwarding:

    https://www.superlogical.com/rex/docs/linux/remote-access

The bootstrap itself leaves Rex listening locally. It does not add anonymous
listeners, alter firewall rules, or turn on Tailscale SSH.

YOUR CONFIGURATION

Observed on your Mac:

    ~/.config/nvim             -> ~/.dotfiles/vim/nvim
    ~/.config/fish/config.fish -> ~/.dotfiles/fish/config.fish
    ~/.config/starship.toml    -> ~/.dotfiles/starship2.toml
    ~/.config/rex             -> ~/.dotfiles/rex

The script reproduces the first three links. Neovim currently uses newer native
LSP APIs and nvim-treesitter's main branch; the script requires Neovim >= 0.12
and tree-sitter CLI >= 0.26.1. It installs upstream releases as needed instead
of relying on older distro Neovim/fzf packages. GitHub binary assets must have
a published SHA-256 digest and are verified before extraction.

Your Fish aliases/integration also need eza, fzf, and ripgrep. The installer adds
those, plus fd, lazygit, and a C compiler for Neovim parsers. It generates the
en_US.UTF-8 locale expected by your Fish configuration. It restores plugins with
Lazy restore using your lazy-lock.json, then installs your configured parsers.

Your Mac Rex config unconditionally loads a local Portside integration from
/Users/shulhi/Dev/portside and references Mac application paths. The server does
not load that file. If you later add ~/.dotfiles/rex/init.linux.lua, the script
links that file as ~/.config/rex/init.lua. Your Mac client shortcuts remain in
the config on your Mac.

Git name/email are filled only if missing, using your current author identity.
SSH signing keys, credentials, history, and Tailscale state are not transferred.
Node.js/npm are managed through mise. Other language toolchains and LSP servers
(OCaml, Elixir, Haskell, Rust, TypeScript, ReScript) are project-specific and not
installed. Install what you need through your usual language manager or :Mason.
Terminal fonts belong on your Mac client.

DOTFILES TRANSFER

Default clone URL: https://github.com/shulhi/dotfiles.git
An existing ~/.dotfiles directory is used as-is: no git pull/reset/clean.

At inspection time your local master was TWO COMMITS AHEAD of origin/master,
and rex/init.lua also had an uncommitted change. A fresh GitHub clone will not
contain changes that have not been pushed. Review and push the commits before
bootstrapping if you want GitHub to be the source of truth, or transfer the
checkout/configs to ~/.dotfiles on the server before running the script.

For a private repository, authenticate Git first or pre-clone it over SSH:

    git clone git@github.com:shulhi/dotfiles.git ~/.dotfiles
    bash ~/bootstrap-server.sh

Alternatively:

    DOTFILES_REPO=git@github.com:shulhi/dotfiles.git bash ~/bootstrap-server.sh

SSH authentication must already work; the script does not copy private keys.

OPTIONS AND REPEAT RUNS

    bash ~/bootstrap-server.sh --help
    bash ~/bootstrap-server.sh --skip-docker --skip-rex
    bash ~/bootstrap-server.sh --skip-plugins --no-chsh
    NVIM_VERSION=v0.12.6 bash ~/bootstrap-server.sh
    REX_CHANNEL=snapshot bash ~/bootstrap-server.sh

Existing working CLI tools are kept, except an explicitly requested Neovim tag
is installed again. Distro packages may be upgraded when apt install runs.
Docker uses its official apt repository. Tailscale uses its official installer
when missing. Starship uses its verified upstream binary release. Rex uses its
official installer on each run,
which may update Rex; set REX_CHANNEL to retain a specific nondefault channel.
This is a bootstrap, not a frozen lockfile for every system package.

Conflicting managed config files/directories are moved, never deleted, under:

    ~/.local/state/server-bootstrap/backups/<timestamp>-<pid>/

To restore a config, remove its new symlink and move the corresponding saved
file/directory back into place. Existing matching symlinks are left alone.
If Docker's conflicting distro packages are already installed, the script stops
with their names so you can resolve them or rerun with --skip-docker.

Official installation references:
    https://neovim.io/doc/install/
    https://github.com/nvim-treesitter/nvim-treesitter
    https://starship.rs/guide/
    https://docs.docker.com/engine/install/ubuntu/
    https://docs.docker.com/engine/install/debian/
    https://tailscale.com/docs/install/linux
    https://www.superlogical.com/rex/docs/linux/installation
    https://code.claude.com/docs/en/setup
    https://learn.chatgpt.com/docs/codex/cli
    https://mise.jdx.dev/getting-started
    https://mise.jdx.dev/installing-mise.html
    https://github.com/cli/cli/blob/trunk/docs/install_linux.md

VALIDATION

Passed Bash syntax checks, ShellCheck, and a disposable Ubuntu 24.04 ARM64 test:
real binary downloads and SHA-256 verification; Fish configuration; original
file backups; repeated config linking; preservation of existing Git identity;
Neovim plugin restoration and parser installation; and repeat CLI installation.
Docker, Compose, Buildx, Tailscale, and Superlogical Rex installed successfully
from their vendor sources. Service operations were explicitly stubbed because
the test container does not run systemd. Live daemon startup, Tailscale login,
and remote Rex connections still need the actual server. Debian and x86-64
were not run through the same container test.

The Claude Code / Codex additions were also installed and tested as shulhi on
shipyard (Ubuntu 26.04 x86-64): Claude Code 2.1.319 and Codex CLI 0.167.0.
Both resolved through ~/.local/bin, and repeating the AI CLI install step made
no downloads. Account sign-in remains a separate interactive step.

The mise / Node.js addition was verified on shipyard: mise 2026.11.4 selected
Node.js 26.13.0 (LTS) with npm 11.20.0. Repeating the step preserved both the
pinned global mise config and Fish setup. Node/npm worked in fresh interactive
Fish sessions and non-interactive SSH commands; the dotfiles stayed clean.

The ShipPDF setup was verified on shipyard: both private repositories cloned
successfully on main using the existing id_ed25519_github key. Git author and
SSH settings resolved from the ShipPDF-only include. A second run preserved
both clean checkouts and produced no Git configuration changes. Local safety
checks also confirmed that existing local work is preserved and mismatched
origins or non-repository destination folders are refused.

GitHub CLI 2.103.3 was installed and verified for shulhi on shipyard; repeating
the install step did not download it again. API authentication uses gh auth login.
The bootstrap also manages the GitHub host entry in ~/.ssh/config when an
existing GitHub identity is selected. Direct GitHub SSH authentication and
both ShipPDF repository reads succeeded without an explicit -i argument.
SSH configuration tests verified preservation of unrelated host settings and
stable output on repeat runs.
