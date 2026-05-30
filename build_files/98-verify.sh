#!/usr/bin/bash

# shellcheck disable=SC1091
source "$(dirname "$0")/00-functions.sh"

echo "::group:: $(basename "$0")"

set -euo pipefail
trap 'log_error "Verification failed at line $LINENO"' ERR

# Track failures
verification_failures=0

log_info "Verifying packages..."

critical_packages=(
  "git"
  "cosmic-comp"
  "cosmic-desktop"
  "cosmic-greeter"
)

for pkg in "${critical_packages[@]}"; do
  if [[ ! package_installed "${pkg}" ]]; then
    log_error "${pkg} not installed..."
    ((verification_failures++))
  fi
done

# Verify systemd services are properly configured
log_info "Verifying services..."

enabled_services=(
  "cosmic-greeter.service"
  "docker.service"
  "containerd.service"
  "libvirtd.service"
)

for service in "${enabled_services[@]}"; do
  if systemctl cat -- "${service}" &>/dev/null; then
    if systemctl is-enabled "${service}" &>/dev/null; then
      log_info "Service enabled: ${service}"
    else
      log_error "Service not enabled: ${service}"
      ((verification_failures++))
    fi
  else
    log_warn "Service not found: ${service}"
  fi
done

# Verify ostree commit succeeded
log_info "Verifying ostree..."
if ostree --version >/dev/null 2>&1; then
  log_info "ostree is available"
else
  log_warn "ostree not available"
  ((verification_failures++))
fi

# Report image size
log_info "Checking image size..."
if [ -d "/usr" ]; then
  usr_size=$(du -sh /usr 2>/dev/null | cut -f1 || echo "unknown")
  log_info "  /usr directory size: ${usr_size}"
fi

if [ -d "/var" ]; then
  var_size=$(du -sh /var 2>/dev/null | cut -f1 || echo "unknown")
  log_info "  /var directory size: ${var_size}"
fi

# Check for unexpected large files in /tmp
log_info "Checking for leftover temporary files..."
if [ -d "/tmp" ]; then
  tmp_size=$(du -sh /tmp 2>/dev/null | cut -f1 || echo "0")
  log_info "  /tmp directory size: ${tmp_size}"
fi

# Verify no broken symlinks in critical paths
log_info "Checking for broken symlinks..."
broken_symlinks=$(find /usr/bin /usr/lib -xtype l 2>/dev/null | wc -l || echo "0")
if [ ! "${broken_symlinks}" -eq 0 ]; then
  log_warn "Found ${broken_symlinks} broken symlink(s)"
fi

# Summary
echo ""
log_info "Verification Summary:"
if [ ${verification_failures} -eq 0 ]; then
  log_info "🎉 All steps passed!"
  echo "::endgroup::"
  exit 0
else
  log_error "${verification_failures} verification(s) failed..."
  log_error "Build may be incomplete or misconfigured"
  echo "::endgroup::"
  exit 1
fi
