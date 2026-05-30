#!/usr/bin/bash

# shellcheck disable=SC1091
source "$(dirname "$0")/00-functions.sh"

echo "::group:: $(basename "$0")"

set -eou pipefail
trap 'log_error "Script failed at line $LINENO"' ERR

safe_mkdir /etc/yum.repos.d
install_packages dnf-plugins-core

log_info "Enabling 'docker-ce' repository"
add_repo docker-ce https://download.docker.com/linux/fedora/docker-ce.repo
enable_repo docker-ce || log_error "Failed to enable 'docker-ce' repository" && exit 1

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
  containerd.io
  docker-buildx-plugin
  docker-ce
  docker-ce-cli
  docker-compose-plugin
  podlet
  podman-compose
  podman-remote
  qemu-kvm     # KVM virtualization
  libvirt      # Virtualization management
  virt-manager # Virtual machine manager GUI
  virt-viewer  # ""
  virt-install # ""
)

log_info "Installing packages..."
install_packages "${core_packages[@]}"
install_packages "${utility_packages[@]}"

log_info "Enabling services..."
enable_service containerd.service
enable_service docker.service
enable_service podman.socket
enable_service podman-auto-update.timer
enable_service libvirtd.service

echo "::endgroup::"
