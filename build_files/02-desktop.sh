#!/bin/bash

# shellcheck disable=SC1091
source "$(dirname "$0")/00-functions.sh"

echo "::group:: ===$(basename "$0")==="

set -euox pipefail
trap 'log_error "Script failed at line $LINENO"' ERR

log_info "Setting up COSMIC desktop environment..."

# Replace GNOME with COSMIC desktop
log_info "Swapping GNOME desktop for COSMIC desktop..."
dnf5 -y swap @gnome-desktop @cosmic-desktop

# Desktop environment packages
desktop_packages=(
  ghostty            # Terminal emulator
  rsms-inter-fonts   # Inter font family
  hack-nerd-fonts    # Hack Nerd Font for terminal
  gdisk              # GPT disk partitioning tool
  gnome-disk-utility # Disk management utility
)

log_info "Installing desktop packages..."
install_packages "${desktop_packages[@]}"

# Disable GDM
log_info "Configuring display manager..."
disable_service gdm.service

# Enable COSMIC greeter
enable_service cosmic-greeter.service

log_info "COSMIC desktop setup completed successfully"

echo "::endgroup::"
