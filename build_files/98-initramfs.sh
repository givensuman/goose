#!/usr/bin/bash

# shellcheck disable=SC1091
source "$(dirname "$0")/00-functions.sh"

echo "::group:: ===$(basename "$0")==="

set -euox pipefail
trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG
trap 'log_error "Script failed at line $LINENO"' ERR

log_info "Generating initramfs..."

# Disable extended attributes during dracut
export DRACUT_NO_XATTR=1

# Get installed kernel version
KERNEL_VERSION="$(dnf5 repoquery --installed --queryformat='%{evr}.%{arch}' kernel)"
log_info "Building initramfs for kernel ${KERNEL_VERSION}"

# Build initramfs with dracut
/usr/bin/dracut \
  --no-hostonly \
  --kver "$KERNEL_VERSION" \
  --reproducible \
  --zstd \
  -v \
  --add ostree \
  -f "/usr/lib/modules/$KERNEL_VERSION/initramfs.img"

# Set secure permissions on initramfs
chmod 0600 "/usr/lib/modules/$KERNEL_VERSION/initramfs.img"

log_info "Initramfs generation completed successfully"

echo "::endgroup::"
