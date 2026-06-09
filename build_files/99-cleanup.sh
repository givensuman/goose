#!/bin/bash

source "$(dirname "$0")/00-functions.sh"

echo "::group:: $(basename "$0")"

set -euo pipefail
trap 'log_error "Script failed at line $LINENO"' ERR

shopt -s nullglob

log_info "Initial disk usage:"
du -sh /var 2>/dev/null | awk '{print "  /var: " $1}' || true
du -sh /tmp 2>/dev/null | awk '{print "  /tmp: " $1}' || true

log_info "Removing CachyOS repository files..."
rm -f /etc/yum.repos.d/cachyos*.repo 2>/dev/null || true

log_info "Removing non-essential repository files..."
repos_to_remove=(
  fedora-cisco-openh264
  fedora-updates
  fedora-updates-archive
  fedora-updates-testing
)

for repo in "${repos_to_remove[@]}"; do
  rm -f "/etc/yum.repos.d/${repo}.repo" 2>/dev/null || true
done

log_info "Removing temporary files..."
rm -rf /tmp/* || true

log_info "Cleaning dnf cache..."
dnf5 clean all

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

log_info "Cleaning /var/lib (preserving flatpak)..."
for libdir in /var/lib/*/; do
  [ -d "$libdir" ] || continue
  dirname=$(basename "$libdir")
  if [ "$dirname" != "flatpak" ]; then
    rm -rf "$libdir"
  fi
done

log_info "Cleaning /var/log..."
rm -rf /var/log/* 2>/dev/null || true

log_info "Removing /var/cache..."
rm -rf /var/cache/* 2>/dev/null || true

log_info "Ensuring /var/tmp exists..."
mkdir -p /var/tmp
chmod 1777 /var/tmp

log_info "Cleaning up old kernel modules..."
mapfile -t kernels < <(find /usr/lib/modules/ -maxdepth 1 -mindepth 1 -printf '%P\n' 2>/dev/null | sort -V)
if [ ${#kernels[@]} -gt 2 ]; then
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
      log_info "Removing old kernel: ${dirname}"
      rm -rf "$dir"
    fi
  done
fi

log_info "Restoring /tmp..."
mkdir -p /tmp

log_info "Final disk usage:"
du -sh /var 2>/dev/null | awk '{print "  /var: " $1}' || true
du -sh /tmp 2>/dev/null | awk '{print "  /tmp: " $1}' || true

log_info "Committing ostree container..."
ostree container commit

log_info "Running bootc container lint..."
bootc container lint || log_warn "bootc lint reported issues..."

echo "::endgroup::"
