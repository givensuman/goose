#!/usr/bin/bash
set -euo pipefail
shopt -s nullglob

echo "::group::90-cleanup"

# dnf cleanup
echo "INFO: Cleaning dnf cache..."
dnf5 clean all

# remove dnf repos except fedora and fedora-cisco-openh264
echo "INFO: Removing non-essential repo files..."
for f in /etc/yum.repos.d/*.repo; do
  case "$(basename "$f")" in
    fedora.repo | fedora-updates.repo | fedora-cisco-openh264.repo) ;;
    *) rm -f "$f" ;;
  esac
done

# strip /var
echo "INFO: Stripping /var..."
rm -rf /var/log/* /var/cache/* /var/tmp/* /tmp/*
mkdir -p /var/tmp /tmp
chmod 1777 /var/tmp /tmp

# keep only latest 2 kernels
echo "INFO: Pruning old kernels..."
mapfile -t kernels < <(find /usr/lib/modules/ -maxdepth 1 -mindepth 1 -printf '%P\n' 2>/dev/null | sort -V)
if [ ${#kernels[@]} -gt 2 ]; then
  for k in "${kernels[@]::${#kernels[@]}-2}"; do
    rm -rf "/usr/lib/modules/$k"
  done
fi

echo "INFO: Verifying critical packages..."
fail=0
for pkg in git kernel-cachyos; do
  rpm -q "$pkg" >/dev/null 2>&1 || {
    echo "WARNING: $pkg not installed"
    ((fail++))
  }
done
for cmd in nix podman flatpak; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "WARNING: $cmd not found"
    ((fail++))
  }
done

[ "$fail" -eq 0 ] && echo "INFO: All checks passed" || echo "WARNING: $fail check(s) failed"

echo "INFO: Committing ostree and linting..."
ostree container commit
bootc container lint || echo "WARNING: bootc lint reported issues"

echo "::endgroup::"
