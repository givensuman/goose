#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="
set -euo pipefail

systemctl enable flatpak-preinstall.service
systemctl --global enable chezmoi-init.service
systemctl --global enable chezmoi-update.timer

echo "::endgroup::"