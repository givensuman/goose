#!/usr/bin/bash

source "$(dirname "$0")/00-functions.sh"

echo "::group:: $(basename "$0")"

set -euo pipefail
trap 'log_error "Script failed at line $LINENO"' ERR

log_info "Relocating /var/opt directories to /usr/lib/opt..."
for dir in /var/opt/*/; do
  [ -d "$dir" ] || continue
  dirname=$(basename "$dir")
  log_info "Moving /var/opt/${dirname} to /usr/lib/opt/${dirname}"
  safe_mkdir "/usr/lib/opt"
  mv "$dir" "/usr/lib/opt/$dirname"
  echo "L+ /var/opt/$dirname - - - - /usr/lib/opt/$dirname" >>/usr/lib/tmpfiles.d/opt-fix.conf
done

echo "::endgroup::"
