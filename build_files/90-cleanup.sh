#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

echo "::group::90-cleanup"

echo "INFO: Cleaning dnf cache..."
dnf5 clean all

echo "INFO: Removing repo files..."
for f in /etc/yum.repos.d/*.repo; do
  case "$(basename "$f")" in
    fedora.repo | fedora-updates.repo | fedora-cisco-openh264.repo) ;;
    *) rm -f "$f" ;;
  esac
done

echo "INFO: Stripping /var..."
rm -rf /var/log/* /var/tmp/* /tmp/*
# find /var/cache \
#   \( -name libdnf5 -o -name rpm-ostree \) -prune -o \
#   -type d -exec rm -rf {} +
mkdir -p /var/tmp /tmp
chmod 1777 /var/tmp /tmp

echo "INFO: Pruning old kernels..."
mapfile -t kernels < <(find /usr/lib/modules/ -maxdepth 1 -mindepth 1 -printf '%P\n' 2>/dev/null | sort -V)
if [ ${#kernels[@]} -gt 2 ]; then
  for k in "${kernels[@]::${#kernels[@]}-2}"; do
    rm -rf "/usr/lib/modules/$k"
  done
fi

echo "INFO: Committing ostree and linting..."
ostree container commit
bootc container lint

echo "::endgroup::"
