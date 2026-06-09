#!/usr/bin/bash
set -euo pipefail

echo "::group::03-nix"

echo "INFO: Installing Nix via Determinate Systems installer..."
curl -fsSL https://determinate.systems/nix-installer | sh -s -- --no-confirm

echo "INFO: Configuring Nix for ostree persistence..."
mkdir -p /usr/lib/tmpfiles.d
echo "L+ /nix - - - - /usr/lib/nix" >/usr/lib/tmpfiles.d/nix-persist.conf

echo "INFO: Enabling Nix daemon..."
systemctl enable nix-daemon.socket
systemctl enable nix-daemon.service

command -v nix && echo "INFO: Nix installation verified"

echo "::endgroup::"
