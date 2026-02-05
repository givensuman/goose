#!/usr/bin/bash

# shellcheck disable=SC1091
source "$(dirname "$0")/00-functions.sh"

echo "::group:: ===$(basename "$0")==="

set -euox pipefail
trap 'log_error "Verification failed at line $LINENO"' ERR

log_info "Starting post-build verification..."

# Track failures
verification_failures=0

# Function to check and report
check_item() {
  local description=$1
  shift

  if "$@"; then
    log_info "✓ ${description}"
    return 0
  else
    log_error "✗ ${description}"
    ((verification_failures++))
    return 1
  fi
}

# Verify critical packages
log_info "Verifying critical package installations..."

critical_packages=(
  "cosmic-desktop"
  "cosmic-greeter"
  "ghostty"
  "git"
  "fastfetch"
  "docker-ce"
  "podman"
  "distrobox"
)

for pkg in "${critical_packages[@]}"; do
  check_item "Package installed: ${pkg}" package_installed "${pkg}"
done

# Verify important binaries exist
log_info "Verifying critical binaries..."

critical_binaries=(
  "/usr/bin/cosmic-comp"
  "/usr/bin/ghostty"
  "/usr/bin/docker"
  "/usr/bin/podman"
  "/usr/bin/distrobox"
  "/usr/bin/git"
  "/usr/bin/fastfetch"
)

for binary in "${critical_binaries[@]}"; do
  check_item "Binary exists: ${binary}" test -x "${binary}"
done

# Verify systemd services are properly configured
log_info "Verifying systemd service configuration..."

enabled_services=(
  "cosmic-greeter.service"
  "docker.service"
  "containerd.service"
  "libvirtd.service"
)

for service in "${enabled_services[@]}"; do
  if systemctl cat -- "${service}" &>/dev/null; then
    if systemctl is-enabled "${service}" &>/dev/null; then
      log_info "✓ Service enabled: ${service}"
    else
      log_error "✗ Service not enabled: ${service}"
      ((verification_failures++))
    fi
  else
    log_warn "? Service not found: ${service} (may not be critical)"
  fi
done

# Verify GDM is disabled (we use cosmic-greeter)
if systemctl cat -- gdm.service &>/dev/null; then
  if ! systemctl is-enabled gdm.service &>/dev/null; then
    log_info "✓ GDM service disabled (correct)"
  else
    log_error "✗ GDM service is enabled (should be disabled)"
    ((verification_failures++))
  fi
fi

# Verify important files and directories
log_info "Verifying filesystem structure..."

important_paths=(
  "/usr/share/ghostty/config"
  "/usr/share/goose-linux/just/goose.just"
  "/usr/share/flatpak/overrides/global"
  "/usr/share/distrobox/distrobox.ini"
  "/usr/share/ublue-os/justfile"
  "/usr/share/cosmic"
)

for path in "${important_paths[@]}"; do
  check_item "Path exists: ${path}" test -e "${path}"
done

# Verify flatpak configuration
log_info "Verifying flatpak configuration..."

if [ -f "/usr/share/flatpak/overrides/global" ]; then
  log_info "Flatpak global overrides present"
else
  log_warn "Flatpak global overrides missing"
fi

# Check if COSMIC configuration files are present
log_info "Verifying COSMIC desktop configuration..."

cosmic_config_count=$(find /usr/share/cosmic -type f 2>/dev/null | wc -l)
if [ "${cosmic_config_count}" -gt 0 ]; then
  log_info "Found ${cosmic_config_count} COSMIC configuration files"
else
  log_error "No COSMIC configuration files found"
  ((verification_failures++))
fi

# Verify ostree commit succeeded
log_info "Verifying ostree state..."
if ostree --version >/dev/null 2>&1; then
  log_info "ostree is available"
else
  log_warn "ostree not available (may be expected in some build contexts)"
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

# Check for unexpected large files in temp
log_info "Checking for leftover temporary files..."
if [ -d "/tmp" ]; then
  tmp_size=$(du -sh /tmp 2>/dev/null | cut -f1 || echo "0")
  log_info "  /tmp directory size: ${tmp_size}"
fi

# Verify no broken symlinks in critical paths
log_info "Checking for broken symlinks..."
broken_symlinks=$(find /usr/bin /usr/lib -xtype l 2>/dev/null | wc -l || echo "0")
if [ "${broken_symlinks}" -eq 0 ]; then
  log_info "No broken symlinks found in /usr/bin and /usr/lib"
else
  log_warn "Found ${broken_symlinks} broken symlink(s)"
fi

# Summary
echo ""
log_info "===== Verification Summary ====="
if [ ${verification_failures} -eq 0 ]; then
  log_info "🎉 All steps passed!"
  echo "::endgroup::"
  exit 0
else
  log_error "${verification_failures} verification(s) failed"
  log_error "Build may be incomplete or misconfigured"
  echo "::endgroup::"
  exit 1
fi
