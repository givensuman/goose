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

exec &> /var/log/nix-install.log

echo "INFO: Installing Nix via Determinate Systems installer..."
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
  | sh -s -- install \
    --no-confirm \
    --prefer-upstream-nix \
    --init none

echo "INFO: Enabling Nix daemon..."
systemctl enable nix-daemon.socket
systemctl enable nix-daemon.service

touch /var/lib/nix-install.done
systemctl disable nix-install.service

command -v nix && echo "INFO: Nix installation verified"

echo "INFO: Nix first-boot installer completed"
INSTALLEOF
chmod +x /usr/libexec/nix-install.sh

# Create one-shot systemd service
cat >/etc/systemd/system/nix-install.service <<'SERVICEEOF'
[Unit]
Description=Install Nix on first boot
Documentation=https://github.com/DeterminateSystems/nix-installer
ConditionPathExists=!/var/lib/nix-install.done
After=network-online.target
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
