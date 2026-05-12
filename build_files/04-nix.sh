#!/usr/bin/bash
# https://gist.github.com/queeup/1666bc0a5558464817494037d612f094

# shellcheck disable=SC1091
source "$(dirname "$0")/00-functions.sh"

echo "::group:: ===$(basename "$0")==="

set -euox pipefail
trap 'log_error "Script failed at line $LINENO"' ERR

log_info "Setting up nix..."

log_info "Enabling transient root..."
tee /etc/ostree/prepare-root.conf <<'EOL'
[composefs]
enabled = yes
[root]
transient = true
EOL

rpm-ostree initramfs-etc --reboot --track=/etc/ostree/prepare-root.conf

log_info "Installing nix"
curl -sSfL https://artifacts.nixos.org/nix-installer | \
    sh -s -- install ostree --explain --add-channel --persistence=/var/lib/nix

log_info "Add nix unstable channel"
nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
nix-channel --update

log_info "Fix sudo"
echo "Defaults  secure_path = /nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin:$(sudo printenv PATH)" | sudo tee /etc/sudoers.d/nix-sudo-env

log_info "Nix setup completed successfully"
