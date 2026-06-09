#!/usr/bin/env bash
set -euo pipefail

echo "::group::02-packages"

echo "INFO: Installing core packages..."
dnf5 -y install \
  git \
  podman-docker \
  podman-compose \
  util-linux \
  udisks2 \
  flatpak \
  "@development-tools" \
  "@hardware-support"

echo "INFO: Adding Flathub remote..."
flatpak remote-add --system --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "INFO: Enabling podman socket..."
systemctl enable podman.socket

echo "INFO: Enabling udisks2..."
systemctl enable udisks2.service

echo "INFO: Setting up udev media automount..."
mkdir -p /etc/udev/rules.d
cat >/etc/udev/rules.d/99-media-automount.rules <<'EOF'
ACTION=="add", SUBSYSTEM=="block", KERNEL=="sd[a-z][0-9]", ENV{ID_FS_TYPE}!="", RUN+="/usr/bin/systemd-mount --no-block --collect $devnode /run/media/%k"
ACTION=="remove", SUBSYSTEM=="block", KERNEL=="sd[a-z][0-9]", RUN+="/usr/bin/systemd-umount /run/media/%k"
EOF

echo "INFO: Relocating /var/opt to immutable layer..."
mkdir -p /usr/lib/opt
for dir in /var/opt/*/; do
  [ -d "$dir" ] || continue
  d=$(basename "$dir")
  mv "$dir" "/usr/lib/opt/$d"
  echo "L+ /var/opt/$d - - - - /usr/lib/opt/$d" >>/usr/lib/tmpfiles.d/opt-fix.conf
done

echo "::endgroup::"
