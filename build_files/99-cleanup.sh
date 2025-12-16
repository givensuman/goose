#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -euox pipefail

shopt -s nullglob

# Disable COPRs and non-essential repos
dnf5 -y copr disable ublue-os/staging || true
dnf5 -y copr disable ublue-os/packages || true

dnf5 config-manager setopt negativo17-fedora-multimedia.enabled=0 || true
dnf5 config-manager setopt _copr_ublue-os-akmods.enabled=0 || true
dnf5 config-manager setopt fedora-cisco-openh264.enabled=0 || true

dnf5 config-manager setopt terra.enabled=0 || true
dnf5 config-manager setopt docker-ce.enabled=0 || true

dnf5 config-manager setopt rpmfusion-nonfree-nvidia-driver.enabled=0 || true
dnf5 config-manager setopt rpmfusion-nonfree-steam.enabled=0 || true

# Or, as fallback
for repo in /etc/yum.repos.d/rpmfusion-*; do
  sed -i 's@enabled=1@enabled=0@g' "$repo"
done

# To be safe...
repos=(
  docker-ce
  terra
  fedora-cisco-openh264
  fedora-updates
  fedora-updates-archive
  fedora-updates-testing
  google-chrome
  negativo17-fedora-multimedia
  negativo17-fedora-nvidia
  nvidia-container-toolkit
  rpm-fusion-nonfree-nvidia-driver
  rpm-fusion-nonfree-steam
)

for repo in "${repos[@]}"; do
  if [[ -f "/etc/yum.repos.d/${repo}.repo" ]]; then
    sed -i 's@enabled=1@enabled=0@g' "/etc/yum.repos.d/${repo}.repo"
  fi
done

for repo in /etc/yum.repos.d/_copr*.repo; do
  sed -i 's@enabled=1@enabled=0@g' "$repo"
done

# Clean up temporary files and caches
rm -rf /tmp/* || true
rm -rf /var/tmp/* || true
rm -rf /var/log/*
rm -rf /var/lib/dnf5/*
rm -rf /var/cache/dnf5/* || true

# Clean package manager cache
dnf5 clean all

# Clean /var directory while preserving essential files
find /var/* -maxdepth 0 -type d \! -name cache -exec rm -rf {} \;
find /var/cache/* -maxdepth 0 -type d \! -name libdnf5 \! -name rpm-ostree -exec rm -rf {} \;

# Cleanup extra directories in /usr/lib/modules
KERNEL_VERSION="$(dnf5 repoquery --installed --queryformat='%{evr}.%{arch}' kernel)"

for dir in /usr/lib/modules/*; do
  [ ! -d "$dir" ] && continue

  dirname=$(basename "$dir")
  if [[ "$dirname" != "$KERNEL_VERSION" ]]; then
    rm -rf "$dir"
  fi
done

# Restore and setup directories
mkdir -p /tmp
mkdir -p /var/tmp
chmod -R 1777 /var/tmp

# Disable COPRs and non-essential repos
dnf5 -y copr disable ublue-os/staging || true
dnf5 -y copr disable ublue-os/packages || true
dnf5 -y copr disable phracek/PyCharm || true

dnf5 config-manager setopt negativo17-fedora-multimedia.enabled=0 || true
dnf5 config-manager setopt _copr_ublue-os-akmods.enabled=0 || true
dnf5 config-manager setopt fedora-cisco-openh264.enabled=0 || true

dnf5 config-manager setopt terra.enabled=0 || true
dnf5 config-manager setopt docker-ce.enabled=0 || true

dnf5 config-manager setopt rpmfusion-nonfree-nvidia-driver.enabled=0 || true
dnf5 config-manager setopt rpmfusion-nonfree-steam.enabled=0 || true
# Or, as fallback
for i in /etc/yum.repos.d/rpmfusion-*; do
  sed -i 's@enabled=1@enabled=0@g' "$i"
done

# To be safe...
repos=(
  docker-ce
  terra
  fedora-cisco-openh264
  fedora-updates
  fedora-updates-archive
  fedora-updates-testing
  google-chrome
  negativo17-fedora-multimedia
  negativo17-fedora-nvidia
  nvidia-container-toolkit
  rpm-fusion-nonfree-nvidia-driver
  rpm-fusion-nonfree-steam
)

for repo in "${repos[@]}"; do
  if [[ -f "/etc/yum.repos.d/${repo}.repo" ]]; then
    sed -i 's@enabled=1@enabled=0@g' "/etc/yum.repos.d/${repo}.repo"
  fi
done

if ls /etc/yum.repos.d/_copr*.repo &>/dev/null; then
  coprs=()
  mapfile -t coprs <<<"$(find /etc/yum.repos.d/_copr*.repo)"
  for copr in "${coprs[@]}"; do
    sed -i 's@enabled=1@enabled=0@g' "$copr"
  done
fi

# Commit and lint container
ostree container commit
bootc container lint

echo "::endgroup::"
