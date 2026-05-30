#!/usr/bin/bash

# shellcheck disable=SC1091
source "$(dirname "$0")/00-functions.sh"

echo "::group:: $(basename "$0")"

set -euo pipefail
trap 'log_error "Validation failed at line $LINENO"' ERR

# Check we're running in a container
if ! in_container; then
  log_warn "Not running in a container"
fi

# Check if we can access package repos
if ! dnf5 repolist >/dev/null 2>&1; then
  log_error "Could not access repositories..."
  exit 1
fi

# Verify system_files directory was mounted
find system_files/ -mindepth 1 | while read -r file; do
  expected_path="/${file#system_files/}"

  if [ ! -f "$expected_path" ] && [ ! -d "$expected_path" ]; then
    log_error "$expected_path was not mounted..."
    exit 1
  fi
done

# Check available disk space
available_space=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
if [ "${available_space}" -lt 5 ]; then
  log_warn "Low disk space: ${available_space}GB available..."
  log_warn "GitHub Actions expects >5GB"
fi

# Check available memory
log_info "Checking available memory..."
available_mem=$(free -g | awk 'NR==2 {print $7}')
if [ "${available_mem}" -lt 1 ]; then
  log_warn "Low memory: ${available_mem}GB available..."
  log_warn "GitHub Actions expects >2GB"
fi

# Verify no stale lockfiles
if [ -f "/var/lib/dnf/locks" ]; then
  log_warn "Found stale lockfile..."
  rm -f /var/lib/dnf/locks
fi

# Verify filesystem exists
if ! rpm -q filesystem >/dev/null 2>&1; then
  log_error "Filesystem not initialized..."
  exit 1
fi

echo "::endgroup::"
