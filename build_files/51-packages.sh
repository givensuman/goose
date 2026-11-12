#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="
set -euo pipefail

dnf5 -y install dnf-plugins-core

dnf5 install -y \
  "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
  "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

dnf5 install -y --nogpgcheck \
  --repofrompath "terra,https://repos.fyralabs.com/terra\$releasever" \
  terra-release

dnf5 -y copr enable awood/bat-extras

CLI_PACKAGES=(
  age
  neovim
  mise
  chezmoi
  bat
  bat-extras
  bottom
  eza
  fd-find
  fish
  lazygit
  opencode
  ripgrep
  zoxide
)

GUI_PACKAGES=(
  ghostty
)

dnf5 install -y "${CLI_PACKAGES[@]}" "${GUI_PACKAGES[@]}"

# Third-party repos are only needed at build time
dnf5 -y copr disable awood/bat-extras

echo "::endgroup::"
