#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="
set -euo pipefail

dnf5 swap -y \
  @gnome-desktop \
  @cosmic-desktop-environment \
  --allowerasing

# dnf copr enable che/nerd-fonts

DESKTOP_PACKAGES=(
  wl-clipboard
  rsms-inter-fonts
  jetbrains-mono-fonts
  # nerd-fonts
)

dnf5 install -y ${DESKTOP_PACKAGES[@]}

EXCLUDED_PACKAGES=(
  cosmic-store
  cosmic-edit
  cosmic-player
  cosmic-reader
  # Prefer flatpak version ~>
  # /etc/flatpak/preinstall.d
  firefox
  firefox-langpacks
)

dnf5 remove -y ${EXCLUDED_PACKAGES[@]}

echo "::endgroup::"