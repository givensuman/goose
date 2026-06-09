#!//usr/bin/env bash
set -euo pipefail

echo "::group::01-kernel"

echo "INFO: Adding CachyOS repository..."
sudo dnf copr enable bieszczaders/kernel-cachyos
rpm --import https://mirror.cachyos.org/cachyos-gpg.asc

echo "INFO: Swapping stock kernel for CachyOS..."
dnf5 -y install kernel-cachyos kernel-cachyos-devel-matched

cat >/etc/kernel/postinst.d/99-default <<'EOF'
#!/bin/sh

set -e

grubby --set-default=/boot/$(ls /boot | grep vmlinuz.*cachy | sort -V | tail -1)
EOF
chown root:root /etc/kernel/postinst.d/99-default
chmod u+rx /etc/kernel/postinst.d/99-default

echo "::endgroup::"
