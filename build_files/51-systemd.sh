#!/usr/bin/bash

# shellcheck disable=SC1091
source "$(dirname "$0")/00-functions.sh"

echo "::group:: $(basename "$0")"

set -euo pipefail
trap 'log_error "Script failed at line $LINENO"' ERR

log_info "Enabling services..."
log_info "See system_files/usr/lib/systemd/system"

services_to_enable=(
  dconf-update.service       # Update dconf database
  flatpak-preinstall.service # Pre-install flatpak applications
  libvirtd-setup.service     # Setup libvirt networking
  ublue-fix-hostname.service # Replace hostname
)

for service in "${services_to_enable[@]}"; do
  enable_service "${service}"
done

echo "::endgroup::"
