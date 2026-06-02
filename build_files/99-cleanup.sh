#!/bin/bash

# shellcheck disable=SC1091
source "$(dirname "$0")/00-functions.sh"

echo "::group:: $(basename "$0")"

set -euo pipefail
trap 'log_error "Script failed at line $LINENO"' ERR

shopt -s nullglob

# Report initial sizes
log_info "Initial disk usage:"
du -sh /var 2>/dev/null | awk '{print "  /var: " $1}' || true
du -sh /tmp 2>/dev/null | awk '{print "  /tmp: " $1}' || true

# Disable COPRs and non-essential repos
log_info "Disabling COPR repositories..."
dnf5 -y copr disable ublue-os/staging || true
dnf5 -y copr disable ublue-os/packages || true

log_info "Disabling RPM repositories..."
disable_repo negativo17-fedora-multimedia || true
disable_repo _copr_ublue-os-akmods || true
disable_repo fedora-cisco-openh264 || true
disable_repo terra || true
disable_repo docker-ce || true
disable_repo rpmfusion-nonfree-nvidia-driver || true
disable_repo rpmfusion-nonfree-steam || true

# Disable specific repos by editing repo files
# directly as a fallback
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
  fi
done
for repo in /etc/yum.repos.d/_copr*.repo; do
  if [ -f "$repo" ]; then
    sed -i 's@enabled=1@enabled=0@g' "$repo"
  fi
done

# Clean up temporary files and caches
log_info "Removing temporary files..."
rm -rf /tmp/* || true

log_info "Cleaning dnf cache..."
dnf5 clean all

# Clean /var directory while preserving essential files
log_info "Cleaning /var directory..."
keep_dirs=("cache" "lib" "log")
for dir in /var/*/; do
  [ -d "$dir" ] || continue
  dirname=$(basename "$dir")
  keep=false
  for keep_dir in "${keep_dirs[@]}"; do
    if [ "$dirname" = "$keep_dir" ]; then
      keep=true
      break
    fi
  done
  if [ "$keep" = false ]; then
    log_info "Removing /var/${dirname}"
    rm -rf "$dir"
  fi
done

# Keep flatpak remote config in /var/lib
log_info "Cleaning /var/lib (preserving flatpak)..."
for libdir in /var/lib/*/; do
  [ -d "$libdir" ] || continue
  dirname=$(basename "$libdir")
  if [ "$dirname" != "flatpak" ]; then
    rm -rf "$libdir"
  fi
done

# Clean /var/log contents but keep the directory
log_info "Cleaning /var/log..."
rm -rf /var/log/* 2>/dev/null || true

# Selectively clean /var/cache
log_info "Cleaning /var/cache..."
for cachedir in /var/cache/*/; do
  [ -d "$cachedir" ] || continue
  dirname=$(basename "$cachedir")
  if [ "$dirname" != "libdnf5" ] && [ "$dirname" != "rpm-ostree" ]; then
    rm -rf "$cachedir"
  fi
done

log_info "Ensuring /var/tmp exists with correct permissions..."
mkdir -p /var/tmp
chmod 1777 /var/tmp

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

# Restore /tmp
log_info "Restoring /tmp..."
mkdir -p /tmp

# Report final sizes
log_info "Final disk usage:"
du -sh /var 2>/dev/null | awk '{print "  /var: " $1}' || true
du -sh /tmp 2>/dev/null | awk '{print "  /tmp: " $1}' || true

# Commit and lint container
log_info "Committing ostree container..."
ostree container commit

log_info "Running bootc container lint..."
bootc container lint || log_warn "bootc lint reported issues..."

echo "::endgroup::"
