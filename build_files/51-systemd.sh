#!/usr/bin/bash

# Load shared functions
# shellcheck source=build_files/00-functions.sh
source "$(dirname "$0")/00-functions.sh"

echo "::group:: ===$(basename "$0")==="

set -euox pipefail

# Trap errors
trap 'log_error "Script failed at line $LINENO"' ERR

log_info "Enabling systemd services..."

# System services to enable
# These services handle various system initialization and management tasks
services_to_enable=(
  dconf-update.service       # Update dconf database
  flatpak-preinstall.service # Pre-install flatpak applications
  libvirtd-setup.service     # Setup libvirt networking
  ublue-fix-hostname.service # Fix hostname issues
)

for service in "${services_to_enable[@]}"; do
  enable_service "${service}"
done

log_info "Systemd services configuration completed successfully"

echo "::endgroup::"
