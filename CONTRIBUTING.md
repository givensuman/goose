# Contributing to goose-linux

Thank you for your interest in contributing to goose-linux! This document provides guidelines and information for contributors.

## Getting Started

### Prerequisites

- A Linux system (preferably Fedora) or access to one
- Podman or Docker installed
- Git
- Just command runner (`cargo install just` or via your package manager)

### Fork and Clone

1. Fork this repository on GitHub
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR-USERNAME/goose-linux.git
   cd goose-linux
   ```
3. Add upstream remote:
   ```bash
   git remote add upstream https://github.com/givensuman/goose-linux.git
   ```

## Development Workflow

### Local Build

Build the container image locally:

```bash
just build localhost/goose-linux test
```

This will create a container image tagged as `localhost/goose-linux:test`.

### Testing in a VM

Test your changes in a virtual machine:

```bash
# Build and run QCOW2 VM
just rebuild-qcow2 localhost/goose-linux test
just run-vm-qcow2 localhost/goose-linux test

# Or use ISO
just rebuild-iso localhost/goose-linux test
just run-vm-iso localhost/goose-linux test
```

### Quick Testing with systemd-vmspawn

For faster iteration:

```bash
just spawn-vm 1 qcow2 6G
```

## Build Script Conventions

Build scripts in `build_files/` follow these conventions:

### Naming Convention

- `00-09`: Validation and setup scripts
- `10-49`: Package installation and core configuration
- `50-89`: Universal Blue integration and systemd configuration
- `90-99`: Cleanup and finalization

Format: `NN-description.sh` where NN is the execution order.

### Script Structure

All build scripts should follow this pattern:

```bash
#!/usr/bin/bash

# Load shared functions
# shellcheck source=build_files/00-functions.sh
source "$(dirname "$0")/00-functions.sh"

echo "::group:: ===$(basename "$0")==="

set -euox pipefail

# Trap errors
trap 'log_error "Script failed at line $LINENO"' ERR

# Your script logic here...

echo "::endgroup::"
```

### Required Elements

1. **Shebang**: `#!/usr/bin/bash` or `#!/bin/bash`
2. **Source functions**: Load `00-functions.sh` for shared utilities
3. **Logging group**: Use `echo "::group:: ..."` and `echo "::endgroup::"` for CI output grouping
4. **Error handling**: Use `set -euox pipefail` for strict error handling
5. **Trap handler**: Catch errors with `trap` for better debugging
6. **Use shared functions**: Prefer functions from `00-functions.sh` over direct commands

### Shared Functions

Use these functions from `00-functions.sh`:

- `install_packages "${packages[@]}"` - Install packages with retry logic
- `enable_service "service.name"` - Safely enable systemd service
- `disable_service "service.name"` - Safely disable systemd service
- `package_installed "package-name"` - Check if package is installed
- `log_info "message"` - Log informational message
- `log_warn "message"` - Log warning message
- `log_error "message"` - Log error message

## Testing Checklist

Before submitting a pull request, ensure:

- [ ] **Build succeeds locally**
  ```bash
  just build localhost/goose-linux test
  ```

- [ ] **Shell scripts pass linting**
  ```bash
  just lint
  ```

- [ ] **Just syntax is valid**
  ```bash
  just check
  ```

- [ ] **Smoke tests pass** (if applicable)
  ```bash
  for test in tests/smoke/*.sh; do bash "$test"; done
  ```

- [ ] **ISO builds** (if changing system packages)
  ```bash
  just build-iso localhost/goose-linux test
  ```

- [ ] **Test in VM** (for significant changes)
  ```bash
  just run-vm-qcow2 localhost/goose-linux test
  ```

- [ ] **Documentation updated** (if adding features or changing behavior)

## Pull Request Guidelines

### Before Submitting

1. **Sync with upstream**:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Run all checks** (see Testing Checklist above)

3. **Write clear commit messages**:
   - Use present tense ("Add feature" not "Added feature")
   - First line should be 50 characters or less
   - Reference issues and PRs when relevant

### PR Description

Your pull request should include:

1. **Clear title** - Summarize the change in one line
2. **Description** - Explain what and why (not how - code shows how)
3. **Related issues** - Link to issues this PR addresses
4. **Type of change** - Bug fix, feature, docs, etc.
5. **Testing done** - What tests did you run?
6. **Screenshots** - If UI changes, include before/after

### PR Template

When you open a PR, fill out the provided template completely.

## Code Review Process

1. **Automated checks** must pass:
   - Build succeeds
   - Shellcheck passes
   - Just syntax valid

2. **At least one approval** from a maintainer is required

3. **Address feedback** promptly and professionally

4. **Squash commits** may be requested before merge

## System Files

Files in `system_files/` are overlaid onto the system at build time:

```
system_files/
├── etc/           → /etc/           (system configuration)
├── usr/lib/       → /usr/lib/       (systemd units, dracut configs)
└── usr/share/     → /usr/share/     (application configs, assets)
```

### Adding System Files

1. **Place files in correct location** under `system_files/`
2. **Match target filesystem structure** exactly
3. **Set correct permissions** (scripts should be executable)
4. **Document purpose** in commit message or comments

### Configuration Files

- Use comments to explain non-obvious settings
- Include references to documentation when applicable
- Test that configurations work on clean install

## Common Tasks

### Adding a Package

Edit `build_files/01-packages.sh` and add to appropriate category:

```bash
core_packages=(
  existing-package
  new-package      # Brief description of why we need this
)
```

### Adding a Systemd Service

1. Create service file in `system_files/usr/lib/systemd/system/`
2. Enable it in `build_files/51-systemd.sh`:
   ```bash
   enable_service "my-service.service"
   ```

### Adding a Flatpak Preinstall

Create or edit files in `system_files/usr/share/flatpak/preinstall.d/`:

```ini
# Category comment
[Flatpak Preinstall org.example.App]
Branch=stable
IsRuntime=false
```

### Adding a Just Recipe

Edit `system_files/usr/share/goose-linux/just/goose.just`:

```just
# Brief description of what this does
my-recipe:
    #!/usr/bin/env bash
    set -euo pipefail
    
    echo "Doing something useful..."
```

## Getting Help

- **Questions?** Open a [Discussion](https://github.com/givensuman/goose-linux/discussions)
- **Bug reports?** Open an [Issue](https://github.com/givensuman/goose-linux/issues)
- **Feature ideas?** Open an issue with the "enhancement" label

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on what is best for the community
- Show empathy towards others

## License

By contributing to goose-linux, you agree that your contributions will be licensed under the Apache License 2.0.

## Recognition

Contributors will be recognized in release notes and the project README. Thank you for helping make goose-linux better!
