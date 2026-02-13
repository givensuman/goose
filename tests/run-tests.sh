#!/usr/bin/bash
# Run all smoke tests
# This script runs all smoke tests and reports overall results

set -euo pipefail

echo "Running goose-linux smoke tests..."
echo ""

# Track results
total_tests=0
passed_tests=0
failed_tests=0

# Find all test scripts
test_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for test in "$test_dir"/smoke/test-*.sh; do
  if [ ! -x "$test" ]; then
    echo "⚠️ Skipping non-executable test: $(basename "$test")"
    continue
  fi

  ((total_tests++))

  test_name=$(basename "$test" .sh)
  echo "Running $test_name..."

  if "$test"; then
    ((passed_tests++))
  else
    ((failed_tests++))
  fi

  echo ""
done

# Summary
echo "========================================"
echo "Test Summary"
echo "========================================"
echo "Total:  $total_tests"
echo "Passed: $passed_tests"
echo "Failed: $failed_tests"
echo "========================================"

if [ $failed_tests -gt 0 ]; then
  exit 1
else
  echo "🎉 All tests passed!"
  exit 0
fi
