# goose

A custom Fedora atomic image built on [`ublue-os/base-main`](https://github.com/ublue-os/main) with the COSMIC desktop.

## Install

Rebase an existing bootc/rpm-ostree system:

```bash
sudo bootc switch ghcr.io/givensuman/goose:stable
systemctl reboot
```

Images are signed with [cosign](cosign.pub).

## goosex

A minimal sibling image: `ublue-os/base-main` plus Nix, with no desktop or personalization. goose is built on top of it.

```bash
sudo bootc switch ghcr.io/givensuman/goosex:stable
```

## Nix

Both images ship Nix (flakes enabled), `nix-daemon`, `direnv` and [nix-direnv](https://github.com/nix-community/nix-direnv). The store lives in `/var/lib/nix`, bind-mounted at `/nix`, so it survives upgrades.

```bash
nix run nixpkgs#hello
echo 'use flake' > .envrc && direnv allow
```

goose's dotfiles hook direnv into fish and load nix-direnv. On goosex, bash/zsh are hooked automatically; add this to `~/.config/direnv/direnvrc` for the cached `use flake`:

```bash
source /usr/share/nix-direnv/direnvrc
```

## Dotfiles

Dotfiles are managed with chezmoi and applied automatically on first login by a user service. To apply manually:

```bash
chezmoi init --apply https://github.com/givensuman/goose
```

## Secrets

Secrets are encrypted with [age](https://github.com/FiloSottile/age) using a passphrase, so only ciphertext is committed.

```bash
chezmoi add --encrypt ~/.config/gh/hosts.yml   # encrypt and track a file
just secrets                                   # decrypt and apply on a new machine
```

The unattended first-boot service skips encrypted files, so run `just secrets` once after first login.

## Development

```bash
just build-full         # build goose from scratch (slow, tests CI changes)
just build-full goosex  # build only the Nix layer
just build        # build the thin local layer on the published image
just switch       # build the local layer and switch the running system to it
```
