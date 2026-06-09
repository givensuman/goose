#!/usr/bin/bash

source "$(dirname "$0")/00-functions.sh"

echo "::group:: $(basename "$0")"

set -euo pipefail
trap 'log_error "Script failed at line $LINENO"' ERR

log_info "Installing Nix via Determinate Systems installer..."
curl -fsSL https://determinate.systems/nix-installer | sh -s -- --no-confirm

log_info "Configuring Nix for ostree persistence..."
safe_mkdir /usr/lib/tmpfiles.d
echo "L+ /nix - - - - /usr/lib/nix" >/usr/lib/tmpfiles.d/nix-persist.conf

log_info "Enabling Nix daemon..."
enable_service nix-daemon.socket
enable_service nix-daemon.service

if command -v nix &>/dev/null; then
  log_info "Nix installation verified"
else
  log_error "Nix not found after installation"
  exit 1
fi

echo "::endgroup::"
