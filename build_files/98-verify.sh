#!/usr/bin/bash

source "$(dirname "$0")/00-functions.sh"

echo "::group:: $(basename "$0")"

set -euo pipefail
trap 'log_error "Verification failed at line $LINENO"' ERR

verification_failures=0

log_info "Verifying packages..."
critical_packages=(
  "git"
  "kernel-cachyos"
)

for pkg in "${critical_packages[@]}"; do
  if ! package_installed "${pkg}"; then
    log_error "${pkg} not installed..."
    verification_failures=$((verification_failures + 1))
  fi
done

log_info "Verifying Nix..."
if command -v nix &>/dev/null; then
  log_info "Nix is available"
else
  log_warn "Nix not found"
  verification_failures=$((verification_failures + 1))
fi

log_info "Verifying Podman..."
if command -v podman &>/dev/null; then
  log_info "Podman is available"
else
  log_warn "Podman not found"
  verification_failures=$((verification_failures + 1))
fi

log_info "Verifying Flatpak..."
if command -v flatpak &>/dev/null; then
  flatpak_remotes=$(flatpak remote-list --system 2>/dev/null | wc -l)
  log_info "Flatpak remotes configured: ${flatpak_remotes}"
else
  log_warn "Flatpak not found"
  verification_failures=$((verification_failures + 1))
fi

log_info "Verifying ostree..."
if ostree --version >/dev/null 2>&1; then
  log_info "ostree is available"
else
  log_warn "ostree not available"
  verification_failures=$((verification_failures + 1))
fi

log_info "Checking image size..."
if [ -d "/usr" ]; then
  usr_size=$(du -sh /usr 2>/dev/null | cut -f1 || echo "unknown")
  log_info "  /usr directory size: ${usr_size}"
fi
if [ -d "/var" ]; then
  var_size=$(du -sh /var 2>/dev/null | cut -f1 || echo "unknown")
  log_info "  /var directory size: ${var_size}"
fi

log_info "Checking for leftover temporary files..."
if [ -d "/tmp" ]; then
  tmp_size=$(du -sh /tmp 2>/dev/null | cut -f1 || echo "0")
  log_info "  /tmp directory size: ${tmp_size}"
fi

log_info "Checking for broken symlinks..."
broken_symlinks=0
for dir in /usr/bin /usr/lib; do
  if [ -d "$dir" ]; then
    count=$(find "$dir" -type l ! -exec test -e {} \; -print 2>/dev/null | wc -l)
    broken_symlinks=$((broken_symlinks + count))
  fi
done
if [ "${broken_symlinks}" -ne 0 ]; then
  log_warn "Found ${broken_symlinks} broken symlink(s)"
fi

echo ""
log_info "Verification Summary:"
if [ ${verification_failures} -eq 0 ]; then
  log_info "All steps passed!"
  echo "::endgroup::"
  exit 0
else
  log_error "${verification_failures} verification(s) failed..."
  log_error "Build may be incomplete or misconfigured"
  echo "::endgroup::"
  exit 1
fi
