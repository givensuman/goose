#!/usr/bin/bash

# shellcheck disable=SC1091
source "$(dirname "$0")/00-functions.sh"

echo "::group:: $(basename "$0")"

set -euo pipefail
trap 'log_error "Script failed at line $LINENO"' ERR

flatpak remote-delete flathub --force || log_warn "Flathub not registered yet..." && true
flatpak remote-delete cosmic --force || log_warn "Cosmic not registered yet..." && true

log_info "Adding Flatpak repositories..."
flatpak remote-add --system --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-add --system --if-not-exists cosmic https://apt.pop-os.org/cosmic/cosmic.flatpakrepo

echo "::endgroup::"
