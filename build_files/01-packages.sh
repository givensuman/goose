#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

mkdir -p /etc/yum.repos.d
dnf5 -y install dnf-plugins-core

# Setup additional repos temporarily
dnf5 config-manager addrepo --from-repofile=https://github.com/terrapkg/subatomic-repos/raw/main/terra.repo
dnf5 config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo

dnf5 config-manager setopt terra.enabled=1 || true
dnf5 config-manager setopt docker-ce.enabled=1 || true

dnf5 -y group install development-tools
dnf5 -y group install development-libraries

packages=(
  # System packages
  git
  p7zip
  p7zip-plugins
  vlc
  vlc-plugin-bittorrent
  vlc-plugin-ffmpeg
  vlc-plugin-pause-click
  wl-clipboard
  util-linux
  wayland-protocols-devel

  # Container/Atomic utilities
  docker-buildx-plugin
  docker-ce
  docker-ce-cli
  docker-compose-plugin
  containerd.io
  podlet
  podman-compose
  podman-remote
  qemu-kvm
  libvirt
  virt-manager
  virt-viewer
  virt-install
)

dnf5 -y install "${packages[@]}" || {
  echo "Failed to install packages"
  exit 1
}

if rpm -q docker-ce >/dev/null; then
  systemctl enable containerd.service || true
  systemctl enable docker.service || true
else
  echo "[DEBUG] docker-ce package missing"
fi

if rpm -q libvirt >/dev/null; then
  systemctl enable libvirtd.service || true
else
  echo "[DEBUG] libvirtd package missing"
fi

echo "::endgroup::"
