#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="
set -euo pipefail

systemctl enable flatpak-preinstall.service
systemctl enable chezmoi-init.service
systemctl enable chezmoi-update.service

echo "::endgroup::"