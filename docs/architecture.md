# Goose Architecture

## Overview

Goose is a reference architecture for building custom immutable Linux operating system images using bootable containers (bootc). It demonstrates how to compose a production-quality OS from upstream Fedora components, independent of downstream distributions.

## Design Goals

1. **Immutable by design** — System updates are atomic container image pulls, not mutable package manager operations. Rollback is always one boot entry away.
2. **No downstream dependency** — Builds directly from `quay.io/fedora/fedora-bootc:stable`, not from derivative distributions like Universal Blue.
3. **Performance-oriented** — Uses the CachyOS kernel for scheduler, CPU governor, and memory management optimizations.
4. **Declarative user package management** — Nix provides reproducible, atomic user-space package management that complements the immutable OS pattern.
5. **Modular and composable** — Each build step is an independent script with documented dependencies. Users include or exclude what they need.
6. **Secure supply chain** — All images are cosign-signed. Secure Boot is supported via enrolled MOK keys.

## Why bootc + Fedora Atomic

bootc (bootable containers) treats the entire OS as an OCI container image. This means:

- **Atomic updates**: `bootc upgrade` pulls a new container image and creates a new ostree deployment. The old deployment remains intact for rollback.
- **Container-native workflow**: Build, tag, sign, and push OS images using the same tooling as application containers (Buildah, Podman, Skopeo).
- **Familiar CI/CD**: Standard GitHub Actions workflows build and publish OS images. Same patterns as any containerized application.
- **ostree foundation**: Git-like versioning of the root filesystem, with deduplication and delta updates.

Fedora Atomic provides:
- Official, well-maintained bootc base images
- Tight integration with the Fedora ecosystem (RPM, Flatpak, systemd)
- Regular updates aligned with Fedora releases

## Kernel Selection: CachyOS

CachyOS provides a performance-tuned Linux kernel based on the Arch Linux kernel with additional patches:

- **BORE scheduler**: Optimized for desktop interactivity and scheduling fairness
- **Auto-Optimization**: CPU-specific optimizations (x86-64-v3, v4)
- **LRU v2**: Improved memory reclaim under pressure
- **Multi-generational LRU**: Better page cache management
- **Additional patches**: Various performance and hardware enablement patches

The kernel is swapped in at build time via `dnf swap`, replacing the stock Fedora kernel. Matching development headers are installed for DKMS module compatibility.

## Package Management Strategy

Goose uses a layered approach to package management:

| Layer | Tool | Scope | Why |
|---|---|---|---|
| System | dnf5 / RPM | Core OS packages | Boot integration, kernel modules, system libraries |
| User | Nix | Development tools, CLI utilities | Declarative, atomic, reproducible, no root needed |
| Desktop | Flatpak | GUI applications | Sandboxed, distribution-agnostic, automatic updates |

Nix replaces Homebrew (used in the previous Universal Blue-based iteration) for several reasons:

- **Declarative**: Nix configurations are pure expressions, enabling reproducible environments
- **Atomic**: Nix operations don't mutate global state — they create new store paths and switch atomically
- **Immutable-friendly**: Nix's `/nix/store` pattern complements ostree's immutable design
- **Signals depth**: Demonstrates understanding of advanced package management concepts

## Build Process

The build process is defined in `Containerfile` and executed by a series of shell scripts in `build_files/`:

1. **validate** — Verify the build environment has sufficient resources and access
2. **kernel** — Add CachyOS repo, swap kernel, install matching headers
3. **packages** — Install minimal core packages (git, podman, dev tooling)
4. **nix** — Install Determinate Systems Nix, configure ostree persistence
5. **flatpaks** — Register Flathub remote
6. **systemd** — Enable infrastructure systemd services
7. **automount** — Add udev rules for removable media mounting
8. **update-services** — Create systemd timers for automatic bootc+flatpak updates
9. **opt-relocate** — Move /var/opt into the immutable layer
10. **verify** — Check all components are installed and functional
11. **cleanup** — Strip build-time dependencies, clean caches, commit ostree

## Update and Rollback Model

Goose uses bootc's native update mechanism:

1. **Periodic check**: A systemd timer (`bootc-auto-update.timer`) runs daily
2. **Atomic upgrade**: `bootc upgrade` pulls the latest image from GHCR
3. **Staged deployment**: The new image is deployed as a new ostree deployment
4. **Rollback**: At boot, the previous deployment is available in the bootloader menu

This is the same model used by Fedora Atomic, Silverblue, and Universal Blue — no custom update infrastructure needed.

## Security

- **Image signing**: All pushed images are signed with cosign using a hardware-backed key stored in GitHub secrets
- **Secure Boot**: Images support Secure Boot via enrollment of the Universal Blue MOK key (standard practice)
- **Supply chain**: Builds are fully from source; all packages come from signed Fedora and CachyOS repositories
- **Minimal attack surface**: The minimal package set reduces the number of potential vulnerabilities

## Comparison

| Aspect | Universal Blue | Goose | Vanilla Fedora |
|---|---|---|---|
| Base | ublue-os/base-main | fedora-bootc:stable | Workstation/Server |
| Kernel | Stock Fedora | CachyOS | Stock Fedora |
| User packages | Homebrew | Nix | system RPM |
| Desktop apps | Included (KDE/GNOME/COSMIC) | Optional (via Flatpak) | Full desktop |
| Size | Large (opinionated) | Minimal (modular) | Medium |
| Portability | ublue-dependent | Standalone | Universal |
