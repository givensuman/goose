#!/bin/bash

# shellcheck disable=SC1091
source "$(dirname "$0")/00-functions.sh"

echo "::group:: ===$(basename "$0")==="

set -euox pipefail
trap 'log_error "Script failed at line $LINENO"' ERR

shopt -s nullglob

log_info "Starting cleanup process..."

# Report initial sizes
log_info "Initial disk usage:"
du -sh /var 2>/dev/null | awk '{print "  /var: " $1}' || true
du -sh /tmp 2>/dev/null | awk '{print "  /tmp: " $1}' || true

# Disable COPRs and non-essential repos
log_info "Disabling COPR repositories..."
dnf5 -y copr disable ublue-os/staging || true
dnf5 -y copr disable ublue-os/packages || true

log_info "Disabling non-essential repositories..."
disable_repo negativo17-fedora-multimedia || true
disable_repo _copr_ublue-os-akmods || true
disable_repo fedora-cisco-openh264 || true
disable_repo terra || true
disable_repo docker-ce || true
disable_repo rpmfusion-nonfree-nvidia-driver || true
disable_repo rpmfusion-nonfree-steam || true

# Disable RPM Fusion repos via file editing (fallback)
log_info "Disabling RPM Fusion repositories..."
for repo in /etc/yum.repos.d/rpmfusion-*; do
  if [ -f "$repo" ]; then
    sed -i 's@enabled=1@enabled=0@g' "$repo"
    log_info "Disabled: $(basename "$repo")"
  fi
done

# Disable specific repos by editing repo files
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
  if [ -f "/etc/yum.repos.d/${repo}.repo" ]; then
    sed -i 's@enabled=1@enabled=0@g' "/etc/yum.repos.d/${repo}.repo"
    log_info "Disabled: ${repo}.repo"
  fi
done

# Disable all COPR repos
for repo in /etc/yum.repos.d/_copr*.repo; do
  if [ -f "$repo" ]; then
    sed -i 's@enabled=1@enabled=0@g' "$repo"
    log_info "Disabled: $(basename "$repo")"
  fi
done

# Clean up temporary files and caches
log_info "Removing temporary files..."
rm -rf /tmp/* || true
rm -rf /var/tmp/* || true

log_info "Removing log files..."
rm -rf /var/log/* || true

log_info "Cleaning dnf cache..."
rm -rf /var/lib/dnf5/* || true
rm -rf /var/cache/dnf5/* || true

# Clean package manager cache
log_info "Running dnf5 clean all..."
dnf5 clean all

# Clean /var directory while preserving essential files
log_info "Cleaning /var directory (preserving cache directories)..."
find /var/* -maxdepth 0 -type d \! -name cache -exec rm -rf {} \; 2>/dev/null || true

log_info "Cleaning /var/cache (preserving libdnf5 and rpm-ostree)..."
find /var/cache/* -maxdepth 0 -type d \! -name libdnf5 \! -name rpm-ostree -exec rm -rf {} \; 2>/dev/null || true

# Cleanup extra kernel modules directories
log_info "Cleaning up old kernel modules..."
KERNEL_VERSION="$(dnf5 repoquery --installed --queryformat='%{evr}.%{arch}' kernel)"
log_info "Current kernel version: ${KERNEL_VERSION}"

for dir in /usr/lib/modules/*; do
  [ ! -d "$dir" ] && continue

  dirname=$(basename "$dir")
  if [[ "$dirname" != "$KERNEL_VERSION" ]]; then
    log_info "Removing old kernel modules: ${dirname}"
    rm -rf "$dir"
  fi
done

# Restore and setup directories with proper permissions
log_info "Restoring system directories..."
mkdir -p /tmp
mkdir -p /var/tmp
chmod -R 1777 /var/tmp

# Report final sizes
log_info "Final disk usage:"
du -sh /var 2>/dev/null | awk '{print "  /var: " $1}' || true
du -sh /tmp 2>/dev/null | awk '{print "  /tmp: " $1}' || true

# Commit and lint container
log_info "Committing ostree container..."
if command_exists ostree; then
  ostree container commit
  log_info "ostree container committed"
else
  log_warn "ostree command not found, skipping commit"
fi

log_info "Running bootc container lint..."
if command_exists bootc; then
  bootc container lint || log_warn "bootc lint reported issues (non-fatal)"
else
  log_warn "bootc command not found, skipping lint"
fi

log_info "Cleanup completed successfully"

echo "::endgroup::"
