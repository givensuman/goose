#!/usr/bin/bash

log_info() {
  echo "INFO: $*"
}

log_warn() {
  echo "WARNING: $*"
}

log_error() {
  echo "ERROR: $*" >&2
}

# Package installation with retry logic
install_packages() {
  local packages=("$@")
  local retries=3
  local delay=5
  local attempt=1

  if [ ${#packages[@]} -eq 0 ]; then
    log_warn "No packages specified for installation"
    return 0
  fi

  log_info "Installing ${#packages[@]} package(s): ${packages[*]}"

  while [ $attempt -le $retries ]; do
    log_info "Installation attempt $attempt of $retries"

    if dnf5 -y install "${packages[@]}"; then
      log_info "Successfully installed packages"
      return 0
    else
      log_warn "Installation failed, attempt $attempt of $retries"
      if [ $attempt -lt $retries ]; then
        log_info "Retrying in ${delay} seconds..."
        sleep $delay
        delay=$((delay * 2)) # Exponential backoff
      fi
    fi

    attempt=$((attempt + 1))
  done

  log_error "Failed to install packages after $retries attempts"
  return 1
}

# Enable systemd service safely
enable_service() {
  local service=$1

  if [ -z "$service" ]; then
    log_error "No service name provided to enable_service"
    return 1
  fi

  if systemctl cat -- "${service}" &>/dev/null; then
    log_info "Enabling service: ${service}"
    systemctl enable "${service}" || {
      log_warn "Failed to enable ${service}"
      return 1
    }
  else
    log_warn "Service ${service} not found, skipping enable"
    return 0
  fi
}

# Disable systemd service safely
disable_service() {
  local service=$1

  if [ -z "$service" ]; then
    log_error "No service name provided to disable_service"
    return 1
  fi

  if systemctl cat -- "${service}" &>/dev/null; then
    log_info "Disabling service: ${service}"
    systemctl disable "${service}" || {
      log_warn "Failed to disable ${service}"
      return 1
    }
  else
    log_warn "Service ${service} not found, already disabled or doesn't exist"
    return 0
  fi
}

# Check if package is installed
package_installed() {
  local package=$1

  if [ -z "$package" ]; then
    log_error "No package name provided to package_installed"
    return 1
  fi

  if rpm -q "${package}" >/dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

# Add repository with error handling
add_repo() {
  local repo_name=$1
  local repo_url=$2

  if [ -z "$repo_name" ] || [ -z "$repo_url" ]; then
    log_error "Repository name and URL required"
    return 1
  fi

  log_info "Adding repository: ${repo_name}"

  if dnf5 config-manager addrepo --from-repofile="${repo_url}"; then
    log_info "Successfully added repository: ${repo_name}"
    return 0
  else
    log_error "Failed to add repository: ${repo_name}"
    return 1
  fi
}

# Enable repository
enable_repo() {
  local repo_name=$1

  if [ -z "$repo_name" ]; then
    log_error "No repository name provided"
    return 1
  fi

  log_info "Enabling repository: ${repo_name}"
  dnf5 config-manager setopt "${repo_name}.enabled=1" || {
    log_warn "Failed to enable repository: ${repo_name}"
    return 1
  }
}

# Disable repository
disable_repo() {
  local repo_name=$1

  if [ -z "$repo_name" ]; then
    log_error "No repository name provided"
    return 1
  fi

  log_info "Disabling repository: ${repo_name}"
  dnf5 config-manager setopt "${repo_name}.enabled=0" || {
    log_warn "Failed to disable repository: ${repo_name}"
    return 1
  }
}

# Check if command exists
command_exists() {
  local cmd=$1

  if [ -z "$cmd" ]; then
    log_error "No command name provided"
    return 1
  fi

  if command -v "${cmd}" &>/dev/null; then
    return 0
  else
    return 1
  fi
}

# Verify required commands are available
require_commands() {
  local missing=()

  for cmd in "$@"; do
    if ! command_exists "${cmd}"; then
      missing+=("${cmd}")
    fi
  done

  if [ ${#missing[@]} -gt 0 ]; then
    log_error "Required commands not found: ${missing[*]}"
    return 1
  fi

  return 0
}

# Create directory safely
safe_mkdir() {
  local dir=$1

  if [ -z "$dir" ]; then
    log_error "No directory path provided"
    return 1
  fi

  if [ ! -d "$dir" ]; then
    log_info "Creating directory: ${dir}"
    mkdir -p "${dir}" || {
      log_error "Failed to create directory: ${dir}"
      return 1
    }
  fi

  return 0
}

# Download file with retry
download_file() {
  local url=$1
  local destination=$2
  local retries=3
  local attempt=1

  if [ -z "$url" ] || [ -z "$destination" ]; then
    log_error "URL and destination required"
    return 1
  fi

  while [ $attempt -le $retries ]; do
    log_info "Downloading ${url} (attempt ${attempt}/${retries})"

    if curl -Lo "${destination}" "${url}"; then
      log_info "Successfully downloaded to ${destination}"
      return 0
    else
      log_warn "Download failed, attempt ${attempt} of ${retries}"
      if [ $attempt -lt $retries ]; then
        sleep 5
      fi
    fi

    attempt=$((attempt + 1))
  done

  log_error "Failed to download ${url} after ${retries} attempts"
  return 1
}

# Check if running in container
in_container() {
  if [ -f /.dockerenv ] || [ -f /run/.containerenv ]; then
    return 0
  else
    return 1
  fi
}

# Export functions for use in subshells
export -f log_info log_warn log_error
export -f install_packages enable_service disable_service
export -f package_installed add_repo enable_repo disable_repo
export -f command_exists require_commands safe_mkdir download_file
export -f in_container
