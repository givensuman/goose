#!/usr/bin/bash

# shellcheck disable=SC1091
source "$(dirname "$0")/00-functions.sh"

echo "::group:: ===$(basename "$0")==="

set -euox pipefail
trap 'log_error "Script failed at line $LINENO"' ERR

log_info "Configuring Flatpak repositories..."

# Remove any existing flatpak remotes to start clean
log_info "Cleaning existing Flatpak remotes..."
flatpak remote-delete flathub --force || true
flatpak remote-delete cosmic --force || true

# Setup flatpak remotes
log_info "Adding Flathub repository..."
flatpak remote-add --system --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

log_info "Adding COSMIC repository..."
flatpak remote-add --system --if-not-exists cosmic https://apt.pop-os.org/cosmic/cosmic.flatpakrepo

# Install Universal Blue flatpak management
log_info "Installing ublue-os-flatpak..."
install_packages ublue-os-flatpak

# Remove Firefox RPM in favor of Flatpak version
log_info "Removing Firefox RPM packages..."
if package_installed firefox; then
  dnf5 -y remove firefox
  log_info "Removed firefox package"
fi

if package_installed firefox-langpacks; then
  dnf5 -y remove firefox-langpacks
  log_info "Removed firefox-langpacks package"
fi

log_info "Flatpak configuration completed successfully"

echo "::endgroup::"
