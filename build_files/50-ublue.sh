#!/usr/bin/bash

# Load shared functions
# shellcheck source=build_files/00-functions.sh
source "$(dirname "$0")/00-functions.sh"

echo "::group:: ===$(basename "$0")==="

set -euox pipefail

# Trap errors
trap 'log_error "Script failed at line $LINENO"' ERR

log_info "Configuring Universal Blue packages and services..."

# Enable Universal Blue COPR repositories
log_info "Enabling Universal Blue COPR repositories..."
dnf5 -y copr enable ublue-os/packages
dnf5 -y copr enable ublue-os/staging

# Install Universal Blue packages
ublue_packages=(
  ublue-os-media-automount-udev # Automatic media mounting
  ublue-os-update-services      # Update management services
  ublue-brew                    # Homebrew integration
)

log_info "Installing Universal Blue packages..."
install_packages "${ublue_packages[@]}"

# Remove default toolbox in favor of distrobox
log_info "Removing default toolbox..."
if package_installed toolbox; then
  dnf5 -y remove toolbox
  log_info "Removed toolbox package"
fi

# Enable podman services for user sessions
log_info "Enabling Podman user services..."
systemctl --global enable podman.socket || true
systemctl --global enable podman-auto-update.timer || true

# Download bash-prexec for shell integration
log_info "Downloading bash-prexec..."
download_file \
  https://raw.githubusercontent.com/ublue-os/bash-preexec/master/bash-preexec.sh \
  /usr/share/bash-prexec

# Enable appropriate update timer
log_info "Configuring system update services..."
if systemctl cat -- uupd.timer &>/dev/null; then
  enable_service uupd.timer
else
  enable_service rpm-ostreed-automatic.timer
  enable_service flatpak-system-update.timer
fi

# Move directories from /var/opt to /usr/lib/opt
# This ensures they're in the immutable system tree
log_info "Relocating /var/opt directories..."
for dir in /var/opt/*/; do
  [ -d "$dir" ] || continue
  dirname=$(basename "$dir")

  log_info "Moving /var/opt/${dirname} to /usr/lib/opt/${dirname}"
  safe_mkdir "/usr/lib/opt"
  mv "$dir" "/usr/lib/opt/$dirname"

  # Create tmpfiles.d entry for symlink
  echo "L+ /var/opt/$dirname - - - - /usr/lib/opt/$dirname" >>/usr/lib/tmpfiles.d/goose-opt-fix.conf
done

# Move configuration overrides if they exist
log_info "Applying configuration overrides..."
if [ -f "/sysctl.conf" ]; then
  safe_mkdir /etc/default
  safe_mkdir /etc/systemd
  safe_mkdir /etc/udev

  [ -d /default ] && mv /default/* /etc/default/ 2>/dev/null || true
  [ -d /systemd ] && mv /systemd/* /etc/systemd/ 2>/dev/null || true
  [ -d /udev ] && mv /udev/* /etc/udev/ 2>/dev/null || true
  [ -f /sysctl.conf ] && mv /sysctl.conf /etc/ || true

  log_info "Configuration overrides applied"
fi

# Import goose-linux Justfile
log_info "Importing goose-linux Justfile..."
if [ -f /usr/share/ublue-os/justfile ]; then
  if ! grep -q "goose-linux/just/goose.just" /usr/share/ublue-os/justfile; then
    echo "import \"/usr/share/goose-linux/just/goose.just\"" >>/usr/share/ublue-os/justfile
    log_info "Justfile import added"
  else
    log_info "Justfile import already present"
  fi
else
  log_warn "ublue-os justfile not found"
fi

log_info "Universal Blue configuration completed successfully"

echo "::endgroup::"
