#!/usr/bin/bash

source "$(dirname "$0")/00-functions.sh"

echo "::group:: $(basename "$0")"

set -euo pipefail
trap 'log_error "Script failed at line $LINENO"' ERR

log_info "Adding Flathub Flatpak repository..."
flatpak remote-add --system --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

log_info "Flatpak remote configured"
echo "::endgroup::"
