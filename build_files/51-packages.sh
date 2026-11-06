#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="
set -euo pipefail

dnf5 -y install dnf-utils dnf-plugins-core

dnf5 install -y \
  "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
  "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

dnf5 install -y --nogpgcheck \
  --repofrompath "terra,https://repos.fyralabs.com/terra\$releasever" \
  terra-release

dnf copr enable awood/bat-extras

CLI_PACKAGES=(
    fish
    neovim
    mise
    chezmoi
    bat
    bat-extras
    bottom
    eza
    fzf
    fd
    lazygit
    opencode
    ripgrep
    zoxide
)

GUI_PACKAGES=(
  ghostty
)

packages=(
  ${CLI_PACKAGES[@]}
  ${GUI_PACKSGES[@]}
)

dnf5 install -y ${packages[@]}

echo "::endgroup::"