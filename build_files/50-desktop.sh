#!/usr/bin/env bash

set -euo pipefail

dnf5 -y install dnf-utils

dnf install \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
dnf install \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
dnf install \
  --nogpgcheck \
  --repofrompath \
  'terra,https://repos.fyralabs.com/terra$releasever' \
  terra-release

dnf5 swap \
  @gnome-desktop \
  @cosmic-desktop-environment \
  --allowerasing

DESKTOP_PACKAGES=(
  wl-clipboard
  rsms-inter-fonts
  jetbrains-mono-fonts
  nerdfontssymbolsonly-nerd-fonts
)

dnf5 install -y ${DESKTOP_PACKAGES[@]}

EXCLUDED_PACKAGES=(
  cosmic-store
  cosmic-edit
  cosmic-player
  cosmic-reader

  firefox
  firefox-langpacks
)

dnf5 remove -y ${EXCLUDED_PACKAGES[@]}