#!/usr/bin/bash

source "$(dirname "$0")/00-functions.sh"

echo "::group:: $(basename "$0")"

set -euo pipefail
trap 'log_error "Script failed at line $LINENO"' ERR

log_info "Enabling infrastructure services..."

services_to_enable=(
  dconf-update.service
  flatpak-preinstall.service
)

for service in "${services_to_enable[@]}"; do
  enable_service "${service}"
done

echo "::endgroup::"
