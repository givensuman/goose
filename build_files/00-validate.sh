#!/usr/bin/bash

# shellcheck disable=SC1091
source "$(dirname "$0")/00-functions.sh"

echo "::group:: ===$(basename "$0")==="

set -euox pipefail
trap 'log_error "Validation failed at line $LINENO"' ERR

log_info "Starting pre-build validation..."

# Check we're running in a container
if ! in_container; then
  log_warn "Not running in a container - this is unexpected for image builds"
fi

# Check required commands are available
log_info "Checking required commands..."
require_commands dnf5 rpm ostree systemctl || {
  log_error "Required commands missing"
  exit 1
}

# Check if dnf5 is functional
log_info "Checking dnf5 functionality..."
if ! dnf5 --version >/dev/null 2>&1; then
  log_error "dnf5 is not functioning correctly"
  exit 1
fi

# Check if we can access package repos (basic connectivity test)
log_info "Checking repository access..."
if ! dnf5 repolist >/dev/null 2>&1; then
  log_warn "Could not list repositories - network or repo configuration issue"
  log_info "Attempting to refresh metadata..."
  dnf5 makecache || log_warn "Cache refresh failed, continuing anyway..."
fi

# Verify system_files directory structure exists
log_info "Checking system_files structure..."
for dir in /etc /usr/lib /usr/share; do
  if [ -d "/system_files${dir}" ] || [ -d "system_files${dir}" ]; then
    log_info "Found system_files${dir}"
  fi
done

# Check available disk space
log_info "Checking disk space..."
available_space=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
if [ "${available_space}" -lt 5 ]; then
  log_warn "Low disk space: ${available_space}GB available (recommended: 5GB+)"
else
  log_info "Disk space OK: ${available_space}GB available"
fi

# Check available memory
log_info "Checking available memory..."
available_mem=$(free -g | awk 'NR==2 {print $7}')
if [ "${available_mem}" -lt 1 ]; then
  log_warn "Low memory: ${available_mem}GB available (recommended: 2GB+)"
else
  log_info "Memory OK: ${available_mem}GB available"
fi

# Verify no stale lockfiles
log_info "Checking for stale lockfiles..."
if [ -f "/var/lib/dnf/locks" ]; then
  log_warn "Found DNF lockfile, removing..."
  rm -f /var/lib/dnf/locks
fi

# Verify base system state
log_info "Checking base system..."
if ! rpm -q filesystem >/dev/null 2>&1; then
  log_error "Base filesystem package not found"
  exit 1
fi

log_info "Pre-build validation completed successfully"

echo "::endgroup::"
