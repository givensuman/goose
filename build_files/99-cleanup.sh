#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="
set -eou pipefail

shopt -s extglob

dnf5 clean all

rm -rf /tmp/* || true
rm -rf /var/!(cache) || true
rm -rf /var/cache/!(rpm-ostree) || true