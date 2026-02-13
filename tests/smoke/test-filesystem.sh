#!/usr/bin/bash
# Smoke test: Verify expected files and directories exist
# This test checks the filesystem structure matches expectations

set -euo pipefail

echo "========================================"
echo "Testing filesystem structure..."
echo "========================================"

# Expected files and directories
expected_paths=(
  "/usr/share/ghostty/config"
  "/usr/share/goose-linux/just/goose.just"
  "/usr/share/flatpak/overrides/global"
  "/usr/share/flatpak/overrides/com.discordapp.Discord"
  "/usr/share/flatpak/overrides/com.valvesoftware.Steam"
  "/usr/share/distrobox/distrobox.ini"
  "/usr/bin/docker"
  "/usr/bin/podman"
  "/usr/bin/distrobox"
  "/usr/bin/ghostty"
  "/usr/bin/goose-firstboot-welcome"
  "/etc/profile.d/flatpak-scaling.sh"
)

failed=0
passed=0

for path in "${expected_paths[@]}"; do
  if [ -e "$path" ]; then
    echo "✓ $path"
    ((passed++))
  else
    echo "✗ $path - NOT FOUND"
    ((failed++))
  fi
done

echo ""
echo "========================================"
echo "Results: $passed passed, $failed failed"
echo "========================================"

if [ $failed -gt 0 ]; then
  echo "❌ Filesystem test FAILED"
  exit 1
else
  echo "✅ Filesystem test PASSED"
  exit 0
fi
