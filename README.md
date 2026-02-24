# Goose &nbsp; [![bluebuild build badge](https://github.com/givensuman/goose/actions/workflows/build.yml/badge.svg)](https://github.com/givensuman/goose/actions/workflows/build.yml)

A highly stable custom atomic OS image built with [BlueBuild](https://blue-build.org/).

## Overview

| Feature | Choice |
|---|---|
| Base | `ghcr.io/ublue-os/base-main:42` |
| Desktop | [COSMIC](https://system76.com/cosmic) |
| Kernel | [Bazzite](https://github.com/bazzite-org/kernel-bazzite) |
| Terminal | [Ghostty](https://ghostty.org/) |
| App store | [Bazaar](https://github.com/ublue-os/bazaar) |
| Shell | [Fish](https://fishshell.com/) (system-wide default) |
| Dotfiles | [Chezmoi](https://www.chezmoi.io/) (sourced from this repo) |
| Extras | Terra repo, RPM Fusion free+nonfree, Framework Laptop akmods |

## Installation

> [!WARNING]
> [This is an experimental feature](https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable), try at your own discretion.

### Rebase from an existing Fedora Atomic installation

1. Rebase to the unsigned image first, to install the signing keys:
   ```bash
   rpm-ostree rebase ostree-unverified-registry:ghcr.io/givensuman/goose:latest
   systemctl reboot
   ```

2. Then rebase to the signed image:
   ```bash
   rpm-ostree rebase ostree-image-signed:docker://ghcr.io/givensuman/goose:latest
   systemctl reboot
   ```

## Local management with `ujust`

After installation, a set of `ujust` commands is available for managing the OS:

| Command | Description |
|---|---|
| `ujust bootstrap-goose` | Clone this repository to `/etc/goose` for local rebuilds |
| `ujust rebuild` | Rebuild the image locally from `/etc/goose` using the BlueBuild CLI |
| `ujust rebase` | Rebase to the latest published image from GHCR |
| `ujust update` | Apply pending rpm-ostree + Flatpak updates |

### Local development workflow

```bash
# 1. Bootstrap the source into /etc/goose
ujust bootstrap-goose

# 2. Edit the recipe or files in /etc/goose, then rebuild locally
ujust rebuild

# 3. Push your changes and let CI/CD build a new image
cd /etc/goose
git add .
git commit -m "my change"
git push   # triggers the GitHub Actions build
```

## Dotfiles with Chezmoi

Dotfiles are managed via [chezmoi](https://www.chezmoi.io/) and are sourced from the `home/` directory of this repository (configured via `.chezmoiroot`).

On first login, chezmoi will automatically initialise from `https://github.com/givensuman/goose` and apply your dotfiles.

To add a dotfile:

```bash
chezmoi add ~/.config/fish/config.fish
```

The file will be tracked in `home/` within this repository.

## Verification

Images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). Verify with:

```bash
cosign verify --key cosign.pub ghcr.io/givensuman/goose
```
