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

# Remove non-essential repo files from the image
# These are not needed at runtime and would just bloat the image
log_info "Removing COPR repository files..."
rm -f /etc/yum.repos.d/_copr_ublue-os-*.repo /etc/yum.repos.d/_copr_*.repo 2>/dev/null || true

log_info "Removing non-essential repository files..."
repos_to_remove=(
  terra
  fedora-cisco-openh264
  fedora-updates
  fedora-updates-archive
  fedora-updates-testing
  google-chrome
  negativo17-fedora-multimedia
  negativo17-fedora-nvidia
  nvidia-container-toolkit
  rpmfusion-nonfree-nvidia-driver
  rpmfusion-nonfree-steam
)

for repo in "${repos_to_remove[@]}"; do
  rm -f "/etc/yum.repos.d/${repo}.repo" 2>/dev/null || true
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

# Remove all /var/cache contents - cache mounts persist across builds
log_info "Removing /var/cache..."
rm -rf /var/cache/* 2>/dev/null || true

log_info "Ensuring /var/tmp exists with correct permissions..."
mkdir -p /var/tmp
chmod 1777 /var/tmp

# Cleanup old kernel modules - keep the 2 most recent
log_info "Cleaning up old kernel modules..."
kernels=($(ls -1 /usr/lib/modules/ 2>/dev/null | sort -V || true))
if [ ${#kernels[@]} -le 2 ]; then
  log_info "Only ${#kernels[@]} kernel(s) found, no cleanup needed"
else
  # Keep the 2 newest, remove the rest
  keep=("${kernels[@]: -2}")
  for dir in /usr/lib/modules/*/; do
    [ -d "$dir" ] || continue
    dirname=$(basename "$dir")
    keep_it=false
    for k in "${keep[@]}"; do
      if [ "$dirname" = "$k" ]; then
        keep_it=true
        break
      fi
    done
    if [ "$keep_it" = false ]; then
      log_info "Removing old kernel modules: ${dirname}"
      rm -rf "$dir"
    fi
  done
fi

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
