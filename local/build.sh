#!/usr/bin/env bash
# Day-to-day tweaks layered on top of the published image.
# Runs inside `Containerfile.local` during `just switch`.
# Put extra files under local/files/ (copied to /) and anything else here.
set -euo pipefail

# dnf5 install -y some-package
