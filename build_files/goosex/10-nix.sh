#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="
set -euo pipefail

NIX_PACKAGES=(
  nix
  nix-daemon
  direnv
)

dnf5 install -y "${NIX_PACKAGES[@]}"

# /nix is immutable in the image; the real store lives on /var/lib/nix and is
# bind-mounted over it via `nix.mount`. Keep the packaged skeleton so tmpfiles
# can seed the writable store on first boot.
mkdir -p /usr/share/factory
cp -a /nix /usr/share/factory/nix

NIX_DIRENV_VERSION=3.2.0
NIX_DIRENV_SHA256=856e8d0b5247b9edc88d9377b8333a97a2363cc69abaa7760fb857609d597ebe
install -d /usr/share/nix-direnv
curl -fsSL -o /usr/share/nix-direnv/direnvrc \
  "https://raw.githubusercontent.com/nix-community/nix-direnv/${NIX_DIRENV_VERSION}/direnvrc"
echo "${NIX_DIRENV_SHA256}  /usr/share/nix-direnv/direnvrc" | sha256sum -c -

systemctl enable nix.mount nix-daemon.socket

echo "::endgroup::"
