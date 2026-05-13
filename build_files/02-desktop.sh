#!/bin/bash

# shellcheck disable=SC1091
source "$(dirname "$0")/00-functions.sh"

echo "::group:: ===$(basename "$0")==="

set -euox pipefail
trap 'log_error "Script failed at line $LINENO"' ERR

log_info "Setting up desktop environment..."

dnf5 -y install \
  @cosmic-desktop \
  --exclude cosmic-edit,cosmic-player,cosmic-reader,cosmic-store

# Replacements
#   cosmic-edit   -> org.gnome.TextEditor
#   cosmic-player -> org.gnome.Showtime
#   cosmic-reader -> org.gnome.Papers
#   cosmic-store  -> io.github.kolunmi.Bazaar

# Desktop environment packages
desktop_packages=(
  ghostty
  gdisk              # GPT disk partitioning tool
  gnome-disk-utility # Disk management utility
)

log_info "Installing desktop packages..."
install_packages "${desktop_packages[@]}"

# Enable COSMIC greeter
enable_service cosmic-greeter.service

log_info "Desktop setup completed successfully"

echo "::endgroup::"
