#!/usr/bin/bash

source "$(dirname "$0")/00-functions.sh"

echo "::group:: $(basename "$0")"

set -euo pipefail
trap 'log_error "Script failed at line $LINENO"' ERR

log_info "Installing udisks2 for media auto-mount..."
install_packages udisks2

log_info "Configuring udev rules for removable media..."
safe_mkdir /etc/udev/rules.d
cat >/etc/udev/rules.d/99-media-automount.rules <<'UDEV'
ACTION=="add", SUBSYSTEM=="block", KERNEL=="sd[a-z][0-9]", ENV{ID_FS_TYPE}!="", RUN+="/usr/bin/systemd-mount --no-block --collect $devnode /run/media/%k"
ACTION=="remove", SUBSYSTEM=="block", KERNEL=="sd[a-z][0-9]", RUN+="/usr/bin/systemd-umount /run/media/%k"
UDEV

log_info "Enabling udisks2 service..."
enable_service udisks2.service

echo "::endgroup::"
