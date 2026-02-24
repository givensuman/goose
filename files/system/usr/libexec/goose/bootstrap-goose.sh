#!/usr/bin/env bash
# bootstrap-goose.sh
# Bootstrap this repository into /etc/goose so the OS can be rebuilt locally.
# Run via: ujust bootstrap-goose
#
# The repository URL defaults to the upstream Goose repo but can be overridden
# with the GOOSE_REPO environment variable, useful when working with a fork:
#   GOOSE_REPO=https://github.com/myfork/goose ujust bootstrap-goose
set -euo pipefail

GOOSE_DIR="/etc/goose"
# Detect repo URL from os-release metadata, fall back to the upstream default.
# BlueBuild may embed IMAGE_URL in os-release; otherwise use the hardcoded URL.
_os_image_url=$(grep -oP '(?<=^IMAGE_URL=).+' /usr/lib/os-release 2>/dev/null | tr -d '"' || true)
REPO_URL="${GOOSE_REPO:-${_os_image_url:-https://github.com/givensuman/goose}}"
# If the detected URL is a container registry reference, fall back to the default
if [[ "${REPO_URL}" == ghcr.io/* ]]; then
    REPO_URL="https://github.com/givensuman/goose"
fi

if [[ "${EUID}" -ne 0 ]]; then
    echo "ERROR: This script must be run as root (e.g. with sudo)." >&2
    exit 1
fi

echo "==> Bootstrapping Goose build environment to ${GOOSE_DIR}"

if [[ -d "${GOOSE_DIR}/.git" ]]; then
    echo "    Repository already present at ${GOOSE_DIR}. Pulling latest changes..."
    git -C "${GOOSE_DIR}" pull --ff-only
    echo "==> Done. ${GOOSE_DIR} is up to date."
    exit 0
fi

if [[ -d "${GOOSE_DIR}" && -n "$(ls -A "${GOOSE_DIR}" 2>/dev/null)" ]]; then
    echo "ERROR: ${GOOSE_DIR} exists and is not empty. Remove or move it first." >&2
    exit 1
fi

echo "    Cloning ${REPO_URL} → ${GOOSE_DIR}..."
git clone --filter=blob:none "${REPO_URL}" "${GOOSE_DIR}"

echo "==> Bootstrap complete."
echo ""
echo "    You can now rebuild locally from ${GOOSE_DIR} with:"
echo "      ujust rebuild"
echo ""
echo "    To push local changes back to the remote:"
echo "      cd ${GOOSE_DIR} && git push"
