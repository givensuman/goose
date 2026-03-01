#!/bin/bash
set -euo pipefail

systemctl enable libvirtd

# Restore SELinux contexts for libvirt directories
restorecon -Rv /var/log/libvirt /var/lib/libvirt 2>/dev/null || true

echo "libvirtd setup completed successfully"
