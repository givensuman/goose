# Building Goose

## Prerequisites

- Linux with `buildah` and `podman` installed
- `just` command runner
- Optional: `cosign` for signature verification

## Build Locally

```bash
# Build with default tag
just build

# Build with custom tag
just build "my-tag"
```

The `just build` command runs:
```bash
buildah build --tag "goose:dev" .
```

## Fork and Customize

1. Fork the repository on GitHub
2. Update container registry references in `.github/workflows/build-os.yml`:
   - `IMAGE_REGISTRY` — set to your GHCR namespace
   - `IMAGE_NAME` — set to your desired image name
3. (Optional) Configure cosign signing:
   - Add `SIGNING_SECRET` to your repository's GitHub Secrets
   - The workflow uses this key to sign all pushed images
4. Push to `main` or `dev` branch — the CI pipeline will build and publish

## Customization Guide

Goose is designed to be modular. Each `build_files/*.sh` script is an independent layer:

### Adding a kernel
Modify `build_files/01-kernel.sh`. The pattern is:
1. Add a repository (if needed)
2. Swap the kernel with `dnf swap`
3. Install matching headers

### Adding system packages
Add packages to the `core_packages` array in `build_files/02-packages.sh`.

### Changing the package manager
Replace `build_files/03-nix.sh` with your preferred package manager. Common alternatives:
- Homebrew: install brew instead of nix
- pipx: Add to `build_files/02-packages.sh`

### Adding a desktop environment
Create a script like `build_files/09-desktop.sh`:
```bash
install_packages @kde-desktop
enable_service sddm
```

The glob-based execution in `Containerfile` will pick it up automatically.

### Removing layers
Delete or comment out the corresponding script in `build_files/`. For example, to remove Flatpak support, delete `build_files/04-flatpaks.sh`.

### Script dependency graph

```
00-validate.sh (no deps)
01-kernel.sh   (no deps)
02-packages.sh (needs kernel)
03-nix.sh      (no deps)
04-flatpaks.sh (no deps)
05-systemd.sh  (needs packages + flatpak)
06-automount.sh (no deps)
07-update-services.sh (needs bootc + flatpak)
08-opt-relocate.sh (no deps)
98-verify.sh  (needs all above)
99-cleanup.sh (needs all above, runs last)
```

## Deploy

### Fresh Install

1. Download an ISO from the latest [GitHub Actions build](https://github.com/givensuman/goose/actions/workflows/build_iso.yml)
2. Write to USB: `dd if=goose-stable.iso of=/dev/sdX bs=4M status=progress`
3. Boot from USB and install

### Rebase from Existing Fedora Atomic

```bash
# Switch to goose image
sudo bootc switch --enforce-container-sigpolicy ghcr.io/givensuman/goose:stable

# Reboot to apply
systemctl reboot
```

### Verify Image Signature

```bash
cosign verify --key https://github.com/givensuman/goose/raw/main/cosign.pub \
  ghcr.io/givensuman/goose:stable
```

## CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/build-os.yml`):

1. **Trigger**: Push to main/dev, PR to main, daily schedule, manual dispatch
2. **Lint**: shellcheck on all build scripts, validate just syntax
3. **Build**: Buildah multi-stage build with dnf cache mounts for speed
4. **Tag**: Generate tags (stable/dev, SHA, timestamp variants)
5. **Push**: Push to GitHub Container Registry
6. **Sign**: Cosign-sign the image with the repository signing key
7. **Cleanup**: Prune build artifacts

The ISO workflow (`.github/workflows/build_iso.yml`) generates a bootable ISO from the latest stable image.
