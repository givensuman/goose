#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="
set -euo pipefail

dnf5 install -y @cosmic-desktop-environment

systemctl enable cosmic-greeter.service

DESKTOP_PACKAGES=(
  wl-clipboard
  rsms-inter-fonts
  jetbrains-mono-fonts
)

dnf5 install -y "${DESKTOP_PACKAGES[@]}"

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

# Not all of these are guaranteed to be installed on every base
for pkg in "${EXCLUDED_PACKAGES[@]}"; do
  if rpm -q "${pkg}" >/dev/null 2>&1; then
    dnf5 remove -y "${pkg}"
  fi
done

echo "::endgroup::"
