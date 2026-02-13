# goose-linux Test Suite

This directory contains tests for goose-linux to ensure system integrity and proper configuration.

## Test Types

### Smoke Tests (`smoke/`)

Basic verification tests that run quickly and check essential system state:

- **test-packages.sh**: Verifies all critical packages are installed
- **test-services.sh**: Checks systemd services are properly configured
- **test-filesystem.sh**: Validates expected files and directories exist

## Running Tests

### Run All Tests

```bash
./tests/run-tests.sh
```

### Run Specific Test

```bash
./tests/smoke/test-packages.sh
```

### Run in CI

Tests are automatically run in GitHub Actions for each pull request.

## Test Requirements

Tests should:
- Exit with code 0 on success, non-zero on failure
- Provide clear output indicating what passed/failed
- Be executable (`chmod +x`)
- Be self-contained and not modify the system

## Adding New Tests

1. Create a new test script in the appropriate directory
2. Make it executable: `chmod +x your-test.sh`
3. Follow the naming convention: `test-*.sh`
4. Add proper error handling and clear output
5. Update this README if adding a new test category

## Test Output Format

Tests should output:
```
========================================
Testing [description]...
========================================
✓ item1 - passed
✗ item2 - failed reason
...
========================================
Results: X passed, Y failed
========================================
✅ Test PASSED / ❌ Test FAILED
```

## CI Integration

Tests run automatically via `.github/workflows/pr-check.yml` on:
- Pull requests to main
- Manual workflow dispatch

## Future Test Categories

Planned test additions:
- Integration tests (test actual functionality)
- Performance tests (measure boot time, memory usage)
- Security tests (check for common misconfigurations)
