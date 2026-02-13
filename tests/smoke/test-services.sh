#!/usr/bin/bash
# Smoke test: Verify critical services are configured correctly
# This test checks that required services are enabled and disabled appropriately

set -euo pipefail

echo "========================================"
echo "Testing service configurations..."
echo "========================================"

# Services that should be enabled
enabled_services=(
  "cosmic-greeter.service"
  "docker.service"
  "containerd.service"
  "libvirtd.service"
  "goose-firstboot.service"
)

# Services that should be disabled
disabled_services=(
  "gdm.service"
)

failed=0
passed=0

echo "Checking enabled services..."
for svc in "${enabled_services[@]}"; do
  if systemctl is-enabled "$svc" &>/dev/null; then
    echo "✓ $svc is enabled"
    ((passed++))
  else
    echo "✗ $svc - NOT ENABLED"
    ((failed++))
  fi
done

echo ""
echo "Checking disabled services..."
for svc in "${disabled_services[@]}"; do
  if systemctl is-enabled "$svc" &>/dev/null; then
    echo "✗ $svc - SHOULD BE DISABLED"
    ((failed++))
  else
    echo "✓ $svc is disabled"
    ((passed++))
  fi
done

echo ""
echo "========================================"
echo "Results: $passed passed, $failed failed"
echo "========================================"

if [ $failed -gt 0 ]; then
  echo "❌ Service test FAILED"
  exit 1
else
  echo "✅ Service test PASSED"
  exit 0
fi
