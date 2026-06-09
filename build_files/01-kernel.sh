#!/usr/bin/bash
set -euo pipefail

echo "::group::01-kernel"

echo "INFO: Adding CachyOS repository..."
dnf5 -y install --nogpgcheck dnf-plugins-core
dnf5 config-manager addrepo --from-repofile="https://mirror.cachyos.org/cachyos-fedora.repo"
rpm --import https://mirror.cachyos.org/cachyos-gpg.asc

echo "INFO: Swapping stock kernel for CachyOS..."
dnf5 -y swap kernel kernel-cachyos

echo "INFO: Installing matching devel headers..."
dnf5 -y install kernel-cachyos-devel-matched

grubby --default-kernel | grep -q cachyos && echo "INFO: CachyOS kernel is default"

echo "::endgroup::"
