#!/usr/bin/bash

# Load shared functions
# shellcheck source=build_files/00-functions.sh
source "$(dirname "$0")/00-functions.sh"

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

# Trap errors
trap 'log_error "Script failed at line $LINENO"' ERR

log_info "Installing packages..."

# Ensure required directories exist
safe_mkdir /etc/yum.repos.d

# Install dnf plugins
install_packages dnf-plugins-core

# Setup additional repos temporarily
log_info "Adding temporary repositories..."
add_repo terra https://github.com/terrapkg/subatomic-repos/raw/main/terra.repo
add_repo docker-ce https://download.docker.com/linux/fedora/docker-ce.repo

enable_repo terra || true
enable_repo docker-ce || true

# Core system utilities
# These are essential tools for system management and basic functionality
core_packages=(
  git                    # Version control system
  fastfetch              # System information display
  p7zip                  # Archive compression tool
  p7zip-plugins          # Additional archive format support
  vlc                    # Media player
  vlc-plugin-bittorrent  # VLC torrent streaming
  vlc-plugin-ffmpeg      # VLC codec support
  vlc-plugin-pause-click # VLC pause on click
  wl-clipboard           # Wayland clipboard utilities
  util-linux             # Essential system utilities
)

# Development tools
# Compilers, build tools, and development libraries
dev_packages=(
  "@development-tools"    # GCC, make, autoconf, etc.
  wayland-protocols-devel # Wayland development headers
)

# Container and virtualization
# Tools for running containers and virtual machines
container_packages=(
  docker-buildx-plugin  # Docker build extensions
  docker-ce             # Docker Community Edition engine
  docker-ce-cli         # Docker command-line interface
  docker-compose-plugin # Docker Compose V2
  containerd.io         # Container runtime
  podlet                # Generate Podman quadlets from existing containers
  podman-compose        # Docker Compose for Podman
  podman-remote         # Remote Podman client
  qemu-kvm              # KVM virtualization
  libvirt               # Virtualization management
  virt-manager          # Virtual machine manager GUI
  virt-viewer           # Virtual machine display viewer
  virt-install          # CLI tool for VM provisioning
)

# Optional packages (commented out by default)
# Uncomment these if you want them in your build:
#
# optional_packages=(
#   # Gaming
#   # steam              # Steam gaming platform
#   # lutris             # Game management platform
#
#   # Communication
#   # discord            # Voice and text chat (recommend flatpak)
#   # slack              # Team communication (recommend flatpak)
#
#   # Development IDEs
#   # code               # VS Code (recommend flatpak)
#
#   # Media editing
#   # gimp               # Image editor
#   # inkscape           # Vector graphics editor
#   # kdenlive           # Video editor
# )

# Install all package categories
log_info "Installing core system utilities..."
install_packages "${core_packages[@]}"

log_info "Installing development tools..."
install_packages "${dev_packages[@]}"

log_info "Installing container and virtualization packages..."
install_packages "${container_packages[@]}"

# Install optional packages if defined
# if [ ${#optional_packages[@]} -gt 0 ]; then
#     log_info "Installing optional packages..."
#     install_packages "${optional_packages[@]}"
# fi

# Enable container services
log_info "Configuring container services..."
if package_installed docker-ce; then
  enable_service containerd.service
  enable_service docker.service
else
  log_warn "docker-ce package not installed, skipping service enablement"
fi

# Enable virtualization services
log_info "Configuring virtualization services..."
if package_installed libvirt; then
  enable_service libvirtd.service
else
  log_warn "libvirt package not installed, skipping service enablement"
fi

log_info "Package installation completed successfully"

echo "::endgroup::"
