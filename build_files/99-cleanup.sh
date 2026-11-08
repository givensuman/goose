#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="
set -euo pipefail

dnf5 clean all

# /tmp, /var/cache and /var/log are build mounts; /var must otherwise be empty for bootc lint
rm -rf /tmp/* || true
find /var -mindepth 1 -maxdepth 1 ! -name cache ! -name log -exec rm -rf {} + || true

echo "::endgroup::"
