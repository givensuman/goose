# Goose Linux — Reference Architecture Design

**Date:** 2026-06-09
**Status:** Draft
**Goal:** Transform a personal Universal Blue desktop image into a recruiter-impressive reference architecture for building custom bootc images, with zero personal desktop functionality.

---

## 1. Architecture Overview

The project builds a Fedora-based immutable OS container image using `bootc` (bootable containers). Unlike the previous iteration, which depended on Universal Blue as the base and layered personal desktop preferences on top, this version starts from raw `fedora-bootc:stable` and demonstrates how to build a custom bootc image from the ground up.

**Build Pipeline:**
`fedora-bootc:stable` -> CachyOS kernel swap -> minimal packages -> Nix integration -> Flatpak support -> system services -> image verification -> cleanup -> CI sign+push

**Key Design Decisions:**
- **fedora-bootc:stable > ublue base** -- Shows understanding of bootc/ostree internals; removes dependency on downstream distro
- **CachyOS kernel** -- Demonstrates kernel engineering; provides a performance-tuned Linux kernel in an immutable context
- **Nix > Homebrew** -- Shows package management depth; Nix's declarative model complements the immutable OS pattern
- **Modular build scripts** -- Each script is independently includable/excludable with documented dependencies
- **Cosign signing retained** -- Demonstrates supply-chain security practices and was explicitly requested

---

## 2. File System Layout

```
goose/
├── Containerfile                    # Build from fedora-bootc
├── README.md                        # Reference architecture docs
├── Justfile                         # Dev tooling: build, lint, format
├── LICENSE                          # Apache 2.0
├── .github/workflows/
│   ├── build-os.yml                 # Main CI: build, sign, push image
│   ├── build_iso.yml                # ISO generation
│   └── pr-check.yml                 # Lint + build validation
├── .pre-commit-config.yaml
├── .shellcheckrc
├── .editorconfig
├── asset/
│   └── goose.png
├── build_files/
│   ├── 00-functions.sh              # Shared utilities
│   ├── 00-validate.sh               # Build env validation
│   ├── 01-kernel.sh                 # CachyOS kernel swap
│   ├── 02-packages.sh               # Minimal core packages
│   ├── 03-nix.sh                    # Nix installer (Determinate Systems)
│   ├── 04-flatpaks.sh               # Flatpak remote setup
│   ├── 05-systemd.sh                # Enable infrastructure services
│   ├── 06-automount.sh              # udev auto-mount rules
│   ├── 07-update-services.sh        # Automatic update timers
│   ├── 08-opt-relocate.sh           # /var/opt -> /usr/lib/opt
│   ├── 98-verify.sh                 # Build verification
│   └── 99-cleanup.sh                # Image cleanup
├── system_files/
│   ├── etc/
│   │   └── containers/
│   ├── usr/
│   │   ├── lib/
│   │   │   ├── dracut/
│   │   │   ├── systemd/
│   │   │   └── sysctl.d/
│   │   ├── libexec/
│   │   └── share/
│   │       └── flatpak/
│   └── var/
│       └── lib/
├── disk_config/
│   ├── disk.toml
│   └── iso.toml
└── docs/
    ├── architecture.md              # Full design doc
    ├── building.md                  # Quick start guide
    └── decisions/
        ├── ADR-001-kernel-choice.md
        ├── ADR-002-nix-over-homebrew.md
        └── ADR-003-base-image-choice.md
```

---

## 3. Build Script Specifications

### 3.1 `00-functions.sh`

**Status:** Unchanged from current. Provides shared utilities:
- `log_info`, `log_warn`, `log_error` -- structured logging
- `install_packages` -- dnf5 install with retry + exponential backoff (3 attempts)
- `enable_service`, `disable_service` -- safe systemd service management
- `package_installed` -- rpm query helper
- `add_repo`, `enable_repo`, `disable_repo` -- dnf5 repo management
- `require_commands`, `command_exists` -- dependency checking
- `safe_mkdir` -- idempotent directory creation
- `download_file` -- curl with retry logic
- `in_container` -- container detection

### 3.2 `00-validate.sh`

**Status:** Updated.

Validates the build environment:
1. Check running in a container (warning if not)
2. Verify repo access (dnf5 repolist)
3. Check available disk space (>5GB for GitHub Actions)
4. Check available memory (>2GB)
5. Verify no stale dnf lockfiles
6. Verify filesystem package is installed

### 3.3 `01-kernel.sh`

**Status:** NEW.

Swaps stock Fedora kernel for CachyOS kernel:
1. Add CachyOS repository: `cachyos-https://mirror.cachyos.org/cachyos-fedora.repo`
2. Import CachyOS GPG key
3. `dnf5 -y swap kernel kernel-cachyos` -- replaces stock kernel in-place
4. Install `kernel-cachyos-devel-matched` for DKMS/module compatibility
5. Verify boot entry references CachyOS kernel
6. Pin kernel version in ostree

### 3.4 `02-packages.sh`

**Status:** Rewritten.

Minimal core packages only -- ~15 packages, no desktop opinion:
- `git`, `util-linux`, `dnf-plugins-core`, `wl-clipboard`, `wayland-protocols-devel`
- `@development-tools`, `@hardware-support`
- `podlet`, `podman-compose`, `podman-docker`, `podman-remote`
- `strace`, `htop`, `iotop` (diagnostics)
- Enable `podman.socket`

### 3.5 `03-nix.sh`

**Status:** NEW.

Integrates Nix via Determinate Systems installer:
1. Install with: `curl -fsSL https://determinate.systems/nix-installer | sh -s -- --no-confirm`
2. Add `trusted-users = root` to `/etc/nix/nix.conf`
3. Create tmpfiles.d entry for `/nix` to persist across ostree updates
4. Enable `nix-daemon.socket` and `nix-daemon.service`
5. Verify `nix` is functional post-install

### 3.6 `04-flatpaks.sh`

**Status:** Stripped down.

No personal apps. Just the remote registration:
1. `flatpak remote-add --system flathub https://flathub.org/repo/flathub.flatpakrepo`

### 3.7 `05-systemd.sh`

**Status:** Rewritten.

Enables infrastructure services only:
- `podman.socket` -- container runtime socket
- `nix-daemon` -- Nix daemon
- `dconf-update.service` -- update dconf database
- `flatpak-preinstall.service` -- flatpak preinstallation
- Removed: `set-hostname.service` (personal choice)

### 3.8 `06-automount.sh`

**Status:** NEW.

Replaces `ublue-os-media-automount-udev`:
1. Install `udisks2`
2. Write udev rule for automatic mounting of removable media
3. Enable `udisks2.service`

### 3.9 `07-update-services.sh`

**Status:** NEW.

Replaces `ublue-os-update-services`:
1. Create `bootc-auto-update.timer` -- periodic `bootc upgrade`
2. Create `flatpak-auto-update.timer` -- periodic flatpak updates
3. Enable both timers

### 3.10 `08-opt-relocate.sh`

**Status:** Same logic, renumbered from `50-ublue.sh`.

Moves `/var/opt/*` directories to `/usr/lib/opt/` with tmpfiles.d symlinks. This is a best practice for immutable OS images -- ensuring runtime state directories live in the immutable layer.

### 3.11 `98-verify.sh`

**Status:** Updated.

Verification checks:
1. Critical packages: `git`, `kernel-cachyos`, `nix`, `podman`
2. `nix` command is functional
3. `podman` can execute
4. `flatpak` remote is configured
5. `ostree` is available
6. Image size reporting (/usr, /var, /tmp)
7. Broken symlink detection
8. CachyOS kernel is the boot default

### 3.12 `99-cleanup.sh`

**Status:** Updated cleanup -- remove ublue traces, add CachyOS cleanup.

1. Remove CachyOS repo files (not needed at runtime)
2. Remove stock kernel remnants
3. Remove non-essential dnf repo files
4. Clean /tmp, /var/cache, /var/log
5. Keep 2 most recent kernel modules
6. Clean dnf caches
7. `ostree container commit`
8. `bootc container lint`

---

## 4. Containerfile

```dockerfile
FROM scratch AS ctx
COPY /build_files /build_files
COPY /system_files /system_files

FROM quay.io/fedora/fedora-bootc:stable AS goose

COPY --from=ctx /build_files /build_files
COPY --from=ctx /system_files /

RUN --mount=type=cache,dst=/var/cache/libdnf5 \
    --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    for script in /ctx/build_files/*.sh; do \
      bash "$script"; \
    done
```

---

## 5. System Files

### Kept
- `etc/containers/containers.conf.d/10-goose.conf` -- container runtime tweaks
- `etc/containers/registries.conf.d/10-goose.conf` -- registry configuration
- `usr/lib/dracut/dracut.conf.d/10-compression.conf` -- initramfs compression (zstd)
- `usr/lib/sysctl.d/80-inotify.conf` -- inotify limits (general best practice)
- `usr/lib/systemd/system/dconf-update.service` -- dconf update service
- `usr/lib/systemd/system/flatpak-preinstall.service` -- flatpak preinstallation
- `usr/libexec/flatpak-preinstall.sh` -- flatpak preinstall script
- `usr/share/flatpak/preinstall.d/firefox.preinstall` -- Firefox flatpak preinstall
- `usr/share/flatpak/preinstall.d/flatpak.preinstall` -- general flatpak preinstall
- `usr/share/flatpak/preinstall.d/gtk.preinstall` -- GTK theme preinstall
- `var/lib/flatpak/overrides/global` -- flatpak global overrides

### Removed
- `usr/lib/dracut/dracut.conf.d/90-ublue.conf` -- ublue-specific dracut config
- `usr/lib/systemd/system/set-hostname.service` -- personal service
- `usr/share/ublue-os/system-setup.hooks.d/10-framework.sh` -- ublue integration hook

---

## 6. Disk Configuration

Unchanged from current. Partition layouts are architecturally relevant:
- ESP: 512MiB vfat
- Boot: 1GiB (disk) / 2GiB (ISO) ext4
- Root: btrfs with subvolumes (@, @home, @var)

---

## 7. CI/CD Pipeline

### `build-os.yml` -- Updated
- Trigger: pushes to main/dev, PRs to main, daily schedule, manual dispatch
- Steps:
  1. Free disk space
  2. Checkout + just syntax check + shellcheck
  3. Generate tags (stable/dev, SHA, timestamp)
  4. Docker metadata (labels)
  5. Cache dnf/rpm-ostree packages
  6. Build image with Buildah (cache mounts)
  7. Lowercase registry name
  8. Login to GHCR
  9. Push to GHCR
  10. Cosign sign (using key from GitHub secrets)
  11. Cleanup

### `build_iso.yml` -- Updated
- Generates bootable ISO from the built image
- Trigger: PRs to main, manual dispatch

### `pr-check.yml` -- Updated
- Lint + just syntax + container build
- Status summary job

---

## 8. Justfile

Keep current dev-tooling commands:
- `just build` -- build container locally
- `just just_check` -- validate just syntax
- `just just_fix` -- fix just syntax
- `just repo_format` -- run shfmt
- `just repo_lint` -- run shellcheck
- `just fix` -- format + lint + clean

Remove ublue justfile integration (was in `50-ublue.sh`).

---

## 9. Documentation

### `docs/architecture.md`
- Overview and goals
- Why bootc + Fedora Atomic
- Kernel selection rationale (CachyOS)
- Package management strategy (Nix + RPM)
- Build process walkthrough
- Update and rollback model
- Security (cosign, secure boot)
- Comparison: ublue vs this approach vs NixOS

### `docs/building.md`
- Prerequisites
- Fork and clone
- Configure image registry
- Build locally with `just build`
- Deploy with `bootc switch`
- Customization guide (which scripts to modify)

### `docs/decisions/ADR-001-kernel-choice.md`
- Context: Need a performant kernel for a bootc-based immutable OS
- Decision: Use CachyOS kernel
- Rationale: Performance tuning, scheduler optimizations, active community
- Consequences: Additional repo dependency, kernel swap at build time

### `docs/decisions/ADR-002-nix-over-homebrew.md`
- Context: Need non-RPM package management for user-space tools
- Decision: Nix via Determinate Systems installer
- Rationale: Declarative, atomic, works with immutable OS, technical depth
- Consequences: Additional image size, build time for Nix installation

### `docs/decisions/ADR-003-base-image-choice.md`
- Context: Need an immutable OS base
- Decision: `quay.io/fedora/fedora-bootc:stable`
- Rationale: Official Fedora, bootc-native, no downstream dependency
- Consequences: Must implement kernel swap and ublue-like functionality ourselves

---

## 10. Deletion Manifest

The following are removed to depersonalize the repository:

| Path | Reason |
|---|---|
| `config_files/` (entire directory) | All personal dotfiles (fish, nvim, ghostty, COSMIC, wallpapers, bat, bottom, lazygit, gh, git, mise, distrobox, opencode) |
| `system_files/usr/lib/dracut/dracut.conf.d/90-ublue.conf` | ublue-specific |
| `system_files/usr/lib/systemd/system/set-hostname.service` | Personal choice |
| `system_files/usr/share/ublue-os/` | ublue integration hook |
| `build_files/50-ublue.sh` | Replaced by 01-08 individual scripts |
| `build_files/02-desktop.sh` | COSMIC/Ghostty/fonts -- personal |
| `build_files/03-flatpaks.sh` | Rewritten -- stripped personal app list |
| `build_files/51-systemd.sh` | Rewritten as 05-systemd.sh |
| `cosign.pub` | Key is kept in GitHub secrets for CI |

---

## 11. Success Signals

| Signal | Evidence |
|---|---|
| Linux systems engineering | Bootc, ostree, kernel swap, immutability patterns |
| Infrastructure-as-code | Container-native OS, CI/CD pipeline, image signing |
| Package management depth | Nix integration on bootc, RPM + Flatpak + Nix coexistence |
| Security awareness | Cosign signing, secure boot, supply-chain security |
| Clean engineering | Modular scripts, ADRs, linting, pre-commit hooks |
| Communication | Architecture docs, README, ADRs, building guide |
| No personal artifacts | Zero dotfiles, zero personal configs, generic brand |
