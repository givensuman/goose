# -*- mode: justfile -*-

set shell := ["bash", "-c"]
set dotenv-load

hostname := `hostname`

default:
    @just --list

[group('util')]
_go-sudo:
    @sudo --validate

[group('util')]
_validate-hostname HOSTNAME:
    #!/usr/bin/env bash
    HOST_DIR="./hosts/{{ HOSTNAME }}"
    if [[ ! -d "$HOST_DIR" ]]; then
        echo "Error: No host configuration found for '{{ HOSTNAME }}'"
        echo "Available hosts:"
        for d in hosts/*/; do
            host=$(basename "$d")
            [[ -f "$d/stow_targets" ]] && printf "\t%s\n" "$host"
        done
        exit 1
    fi

# Rebuild everything
rebuild HOSTNAME=hostname: \
    (_validate-hostname HOSTNAME) \
    (_go-sudo) \
    (_nixos-switch HOSTNAME) \
    (_stow HOSTNAME)

# Run switch for system and home configurations
switch HOSTNAME=hostname: \
    (_validate-hostname HOSTNAME) \
    (_go-sudo) \
    (_nixos-switch HOSTNAME) \

# Run build for system and home configurations
build HOSTNAME=hostname: \
    (_validate-hostname HOSTNAME) \
    (_go-sudo) \
    (_nixos-build HOSTNAME) \

# Update Nix flake inputs
update: _go-sudo
    sudo nix flake update

# Upgrade current system
upgrade HOSTNAME=hostname: _go-sudo
    sudo nixos-rebuild --flake ".#{{ HOSTNAME }}" switch

# Upgrade current system safely, after reboot
upgrade-safely-requires-reboot HOSTNAME=hostname:
    sudo nixos-rebuild --flake ".#{{ HOSTNAME }}" boot

# Clean Nix store and remove old generations
autoremove: _go-sudo
    sudo nix-collect-garbage -d

generate-hardware-configuration HOSTNAME=hostname:
  nixos-generate-config --show-hardware-config > \
    ./hosts/{{ HOSTNAME }}/hardware-configuration.nix

[group('nixos')]
_nixos-switch HOSTNAME:
    sudo nixos-rebuild --flake ".#{{ HOSTNAME }}" switch

[group('nixos')]
_nixos-build HOSTNAME:
    nixos-rebuild --flake ".#{{ HOSTNAME }}" build

[group('nixos')]
_nixos-test HOSTNAME:
    sudo nixos-rebuild --flake ".#{{ HOSTNAME }}" test

[group('nixos')]
_nixos-rollback:
    sudo /run/current-system/bin/switch-to-configuration switch

[group('nixos')]
_nixos-generations:
    nix-env -p /nix/var/nix/profiles/system --list-generations

[group('stow')]
_stow HOSTNAME:
    #!/usr/bin/env bash
    target_file="./hosts/{{ HOSTNAME }}/stow_targets"
    if [[ -f "$target_file" ]]; then
        readarray -t pkgs < "$target_file"
        for pkg in "${pkgs[@]}"; do
            [[ -n "$pkg" ]] && stow -d ./stow -t "$HOME" -R "$pkg"
        done
    else
        echo "Warning: No stow_targets found at $target_file"
    fi

[group('stow')]
_stow-target TARGET:
    stow -d ./stow -t "$HOME" -R "{{ TARGET }}"
