#!/usr/bin/bash
# Smoke test: Verify critical packages are installed
# This test ensures all required packages from the build process are present

set -euo pipefail

echo "========================================"
echo "Testing package installations..."
echo "========================================"

# Required packages that must be installed
required_packages=(
  "cosmic-desktop"
  "cosmic-greeter"
  "ghostty"
  "docker-ce"
  "podman"
  "distrobox"
  "git"
  "fastfetch"
  "libvirt"
  "qemu-kvm"
)

failed=0
passed=0

for pkg in "${required_packages[@]}"; do
  if rpm -q "$pkg" >/dev/null 2>&1; then
    echo "✓ $pkg"
    ((passed++))
  else
    echo "✗ $pkg - NOT INSTALLED"
    ((failed++))
  fi
done

echo ""
echo "========================================"
echo "Results: $passed passed, $failed failed"
echo "========================================"

if [ $failed -gt 0 ]; then
  echo "❌ Package test FAILED"
  exit 1
else
  echo "✅ Package test PASSED"
  exit 0
fi
