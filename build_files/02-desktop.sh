#!/bin/bash

# shellcheck disable=SC1091
source "$(dirname "$0")/00-functions.sh"

echo "::group:: $(basename "$0")"

set -euo pipefail
trap 'log_error "Script failed at line $LINENO"' ERR

log_info "Enabling 'terra' repository"
add_repo terra https://github.com/terrapkg/subatomic-repos/raw/main/terra.repo
if ! enable_repo terra; then
  log_error "Failed to enable 'terra' repository"
  exit 1
fi

log_info "Installing COSMIC..."
dnf5 -y install \
  @cosmic-desktop \
  --exclude cosmic-edit,cosmic-player,cosmic-reader,cosmic-store

log_info "Removing Firefox RPM packages..."
if package_installed firefox; then
  dnf5 -y remove firefox
fi
if package_installed firefox-langpacks; then
  dnf5 -y remove firefox-langpacks
fi

# Replacements
#   cosmic-edit   -> org.gnome.TextEditor
#   cosmic-player -> org.gnome.Showtime
#   cosmic-reader -> org.gnome.Papers
#   cosmic-store  -> io.github.kolunmi.Bazaar
#   firefox       -> org.mozilla.Firefox

# Desktop environment packages
desktop_packages=(
  ghostty
  gdisk              # GPT disk partitioning tool
  gnome-disk-utility # Disk management utility
)

dnf5 -y copr enable che/nerd-fonts

font_packages=(
  jetbrains-mono-fonts
  rsms-inter-fonts
  nerd-fonts
)

log_info "Installing packages..."
install_packages "${desktop_packages[@]}"
install_packages "${font_packages[@]}"

log_info "Enabling services..."
enable_service cosmic-greeter.service

echo "::endgroup::"
