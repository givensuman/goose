#!/usr/bin/bash

source "$(dirname "$0")/00-functions.sh"

echo "::group:: $(basename "$0")"

set -euo pipefail
trap 'log_error "Script failed at line $LINENO"' ERR

log_info "Adding CachyOS repository..."
dnf5 -y install --nogpgcheck dnf-plugins-core
dnf5 config-manager addrepo --from-repofile="https://mirror.cachyos.org/cachyos-fedora.repo"
rpm --import https://mirror.cachyos.org/cachyos-gpg.asc

log_info "Swapping stock kernel for CachyOS kernel..."
dnf5 -y swap kernel kernel-cachyos

log_info "Installing matching devel headers..."
dnf5 -y install kernel-cachyos-devel-matched

log_info "Verifying CachyOS kernel is default..."
if ! grubby --default-kernel | grep -q cachyos; then
  log_warn "CachyOS kernel may not be the default boot entry"
fi

log_info "CachyOS kernel swap completed successfully"
echo "::endgroup::"
