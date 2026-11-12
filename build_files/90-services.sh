#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="
set -euo pipefail

systemctl enable flatpak-preinstall.service
systemctl --global enable chezmoi-init.service
systemctl --global enable chezmoi-update.timer

# thermald only supports Intel CPUs
systemctl disable thermald.service || true

echo "::endgroup::"
