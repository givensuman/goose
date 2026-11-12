# goose

A custom Fedora atomic image built on [`ublue-os/base-main`](https://github.com/ublue-os/main) with the COSMIC desktop.

## Install

Rebase an existing bootc/rpm-ostree system:

```bash
sudo bootc switch ghcr.io/givensuman/goose:stable
systemctl reboot
```

Images are signed with [cosign](cosign.pub).

## Dotfiles

Dotfiles are managed with chezmoi and applied automatically on first login by a user service. To apply manually:

```bash
chezmoi init --apply https://github.com/givensuman/goose
```

## Development

```bash
just build-full   # build the full image from scratch (slow, tests CI changes)
just build        # build the thin local layer on the published image
just switch       # build the local layer and switch the running system to it
```
