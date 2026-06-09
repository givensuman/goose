![goose logo](./assets/goose.png)

## goose: Reference Architecture for bootc-based Linux Images

![build-os](https://img.shields.io/github/actions/workflow/status/givensuman/goose/build-os.yml?labelColor=purple)
![build-iso](https://img.shields.io/github/actions/workflow/status/givensuman/goose/build_iso.yml?label=build%20iso&labelColor=blue)

## About

Goose is a reference architecture for building custom, immutable Linux operating system images using [bootc](https://github.com/containers/bootc) (bootable containers). It demonstrates how to assemble a production-quality OS image from raw Fedora components, independent of downstream distributions.

Built on [Fedora Atomic Desktops](https://fedoraproject.org/atomic-desktops/) technology, Goose is a container-native OS that is immutable by design — system updates are atomic container image pulls, not mutable package manager operations.

## Architecture

```
fedora-bootc:stable
  -> CachyOS kernel (performance-tuned)
  -> Minimal core packages (git, podman, dev tooling)
  -> Nix package manager (Determinate Systems)
  -> Flatpak runtime
  -> System services (auto-update, media mount, dconf)
  -> Cosign-signed container image
  -> GHCR distribution
```

### Key Components

| Layer | Technology | Purpose |
|---|---|---|
| Base OS | fedora-bootc:stable | Immutable, atomic OS from upstream Fedora |
| Kernel | CachyOS | Performance-tuned Linux kernel with scheduler optimizations |
| Package Manager | Nix | Declarative, atomic user-space package management |
| Containers | Podman | OCI-compatible container runtime with Docker compatibility |
| Desktop Apps | Flatpak | Sandboxed, distribution-agnostic application runtime |
| Image Security | Cosign | Container image signing and verification |
| Updates | bootc + systemd timers | Atomic upgrades with rollback support |
| Auto-mount | udev + udisks2 | Automatic removable media mounting |

## Quick Start

### Prerequisites

- A Fedora Atomic Desktop installation (Silverblue, Kinoite, etc.)
- `bootc` CLI
- Root access

### Build Locally

```bash
just build
```

### Deploy

```bash
sudo bootc switch --enforce-container-sigpolicy ghcr.io/givensuman/goose:stable
```

### Customize

Each build script in `build_files/` is independently includable. To customize:

1. Fork the repository
2. Modify or remove scripts in `build_files/` (see dependency graph in `docs/building.md`)
3. Update your CI/CD registry in `.github/workflows/`
4. Build and push

## Build Pipeline

```
Containerfile
  -> build_files/00-validate.sh       # Validate build environment
  -> build_files/01-kernel.sh         # Swap to CachyOS kernel
  -> build_files/02-packages.sh       # Install core packages
  -> build_files/03-nix.sh            # Install Nix
  -> build_files/04-flatpaks.sh       # Register Flatpak remotes
  -> build_files/05-systemd.sh        # Enable system services
  -> build_files/06-automount.sh      # Configure udev auto-mount
  -> build_files/07-update-services.sh # Setup update timers
  -> build_files/08-opt-relocate.sh   # Immutable OS path fixes
  -> build_files/98-verify.sh         # Verify build integrity
  -> build_files/99-cleanup.sh        # Optimize image size
  -> CI: cosign sign + push to GHCR
```

## Security

- **Image Signing**: All images are signed with cosign. Verify with:
  ```bash
  cosign verify --key https://github.com/givensuman/goose/raw/main/cosign.pub ghcr.io/givensuman/goose:stable
  ```
- **Secure Boot**: Supported via enrolled MOK key
- **Supply Chain**: Builds are reproducible from source; all dependencies pinned

## Documentation

- [Architecture](docs/architecture.md) — Design decisions and rationale
- [Building](docs/building.md) — Build and customization guide
- [ADRs](docs/decisions/) — Architecture Decision Records

## License

[Apache-2.0](./LICENSE)
