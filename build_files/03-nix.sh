#!/usr/bin/env bash
set -euo pipefail

echo "::group::03-nix"

# Disable until ostree installation bug is resolved
# https://github.com/NixOS/nix-installer/issues/155

# echo "INFO: Installing Nix via Determinate Systems installer..."
# curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
# | sh -s -- install ostree \
#   --no-confirm \
#   --prefer-upstream-nix \
#   --no-start-daemon \
#   --init none
#
# echo "INFO: Configuring Nix for ostree persistence..."
# mkdir -p /usr/lib/tmpfiles.d
# echo "L+ /nix - - - - /usr/lib/nix" >/usr/lib/tmpfiles.d/nix-persist.conf
#
# echo "INFO: Enabling Nix daemon..."
# systemctl enable nix-daemon.socket
# systemctl enable nix-daemon.service
#
# command -v nix && echo "INFO: Nix installation verified"

echo "INFO: Setting up first-boot Nix installer service..."

# Create persistent /nix symlink target
mkdir -p /var/nix
cat >/usr/lib/tmpfiles.d/nix-persist.conf <<'EOF'
L+ /nix - - - - /var/nix
EOF

mkdir -p /usr/libexec
cat >/usr/libexec/nix-install.sh <<'INSTALLEOF'
#!/usr/bin/env bash
set -euo pipefail

readonly LOG_FILE="/var/log/nix-install.log"
readonly DONE_FILE="/var/lib/nix-install.done"
readonly FAILED_FILE="/var/lib/nix-install.failed"
readonly INSTALL_URL="https://install.determinate.systems/nix"
readonly MAX_RETRIES=3

log() {
    local msg="[$(date -Iseconds)] $*"
    echo "$msg"
    logger -t nix-install "$msg"
}

fail() {
    local reason="$1"
    log "ERROR: $reason"
    printf '%s\tInstallation failed: %s\n' "$(date -Iseconds)" "$reason" >"$FAILED_FILE"
    exit 1
}

nix_is_functional() {
    local nix_bin="/nix/var/nix/profiles/default/bin/nix"
    if [[ -x "$nix_bin" ]] && "$nix_bin" --version >/dev/null 2>&1; then
        return 0
    fi
    if command -v nix >/dev/null 2>&1 && nix --version >/dev/null 2>&1; then
        return 0
    fi
    return 1
}

cleanup_nix() {
    log "INFO: Cleaning up partial /nix state before retry..."
    local nix_state="/var/nix"
    rm -rf "${nix_state:?}"
    mkdir -p "$nix_state"
    if [[ -L /nix ]] && [[ ! -e /nix ]]; then
        rm -f /nix
    fi
}

wait_for_network() {
    log "INFO: Waiting for network connectivity to $INSTALL_URL..."
    local max_attempts=30
    local attempt
    for ((attempt=1; attempt<=max_attempts; attempt++)); do
        if curl -fsSL --max-time 10 -o /dev/null "$INSTALL_URL"; then
            log "INFO: Network connectivity confirmed on attempt $attempt."
            return 0
        fi
        log "WARN: Network not ready (attempt $attempt of $max_attempts); retrying in 10s..."
        sleep 10
    done
    fail "Network connectivity to $INSTALL_URL not available after $max_attempts attempts"
}

install_nix() {
    log "INFO: Downloading and running Determinate Systems Nix installer..."
    curl --proto '=https' --tlsv1.2 -sSf -L "$INSTALL_URL" \
        | sh -s -- install \
            --no-confirm \
            --prefer-upstream-nix \
            --init none
}

run_installer_with_retry() {
    local attempt
    for ((attempt=1; attempt<=MAX_RETRIES; attempt++)); do
        log "INFO: Nix installation attempt $attempt of $MAX_RETRIES..."
        if install_nix; then
            log "INFO: Nix installer completed on attempt $attempt."
            return 0
        fi
        log "WARN: Nix installer failed on attempt $attempt."
        cleanup_nix
        if [[ $attempt -lt $MAX_RETRIES ]]; then
            local backoff=$((2 ** attempt))
            log "INFO: Retrying in $backoff seconds..."
            sleep "$backoff"
        fi
    done
    fail "Nix installer failed after $MAX_RETRIES attempts"
}

verify_nix() {
    log "INFO: Verifying Nix installation..."
    local nix_bin
    nix_bin="$(command -v nix)" || fail "nix command not found in PATH"
    if ! "$nix_bin" --version; then
        fail "nix --version failed after installation"
    fi
    local max_attempts=10
    local attempt
    for ((attempt=1; attempt<=max_attempts; attempt++)); do
        if "$nix_bin" store ping; then
            log "INFO: Nix store ping succeeded."
            return 0
        fi
        log "WARN: nix store ping failed (attempt $attempt of $max_attempts); retrying in 2s..."
        sleep 2
    done
    fail "nix store ping failed after $max_attempts attempts"
}

# Ensure log directory exists and redirect all output to log file.
mkdir -p "$(dirname "$LOG_FILE")"
exec &> "$LOG_FILE"

# Idempotency: skip if previously completed and Nix is functional.
if [[ -f "$DONE_FILE" ]] && nix_is_functional; then
    log "INFO: Nix is already installed and functional; skipping first-boot installer."
    exit 0
fi

# Remove stale success marker so a broken-but-marked install can be retried.
rm -f "$DONE_FILE"

wait_for_network
run_installer_with_retry

# Make the Nix CLI and environment available for verification.
export PATH="/nix/var/nix/profiles/default/bin${PATH:+:$PATH}"
if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
    # shellcheck source=/dev/null
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

log "INFO: Enabling and starting Nix daemon..."
systemctl enable nix-daemon.socket
systemctl enable nix-daemon.service
systemctl start nix-daemon.socket || fail "Failed to start nix-daemon.socket"
systemctl start nix-daemon.service || fail "Failed to start nix-daemon.service"

verify_nix

rm -f "$FAILED_FILE"
touch "$DONE_FILE"
log "INFO: Disabling nix-install.service..."
systemctl disable nix-install.service
log "INFO: Nix first-boot installer completed successfully."
INSTALLEOF
chmod +x /usr/libexec/nix-install.sh

# Create one-shot systemd service
cat >/etc/systemd/system/nix-install.service <<'SERVICEEOF'
[Unit]
Description=Install Nix on first boot
Documentation=https://github.com/DeterminateSystems/nix-installer
After=network-online.target
After=systemd-tmpfiles-setup.service
After=local-fs.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/libexec/nix-install.sh
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
SERVICEEOF

echo "INFO: Enabling first-boot Nix installer..."
systemctl enable nix-install.service

echo "::endgroup::"
