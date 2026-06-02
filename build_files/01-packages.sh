#!/usr/bin/bash

# shellcheck disable=SC1091
source "$(dirname "$0")/00-functions.sh"

echo "::group:: $(basename "$0")"

set -euo pipefail
trap 'log_error "Script failed at line $LINENO"' ERR

safe_mkdir /etc/yum.repos.d
install_packages dnf-plugins-core

core_packages=(
  git
  util-linux
  wl-clipboard
  wayland-protocols-devel
  "@development-tools"
  "@fonts"
  "@hardware-support"
)

utility_packages=(
  podlet
  podman-compose
  podman-remote
  podman-docker
)

log_info "Installing packages..."
install_packages "${core_packages[@]}"
install_packages "${utility_packages[@]}"

log_info "Enabling services..."
enable_service podman.socket

echo "::endgroup::"
