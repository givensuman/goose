host := "gandalf"
user := "given"
flake := "."

# Show this help
default:
    @just --list

# Build, activate, and symlink configuration files
[group('util')]
rebuild: switch symlink-configs

# Move to world directory
[group('util')]
cd:
  cd $HOME/world

# Build and activate new system configuration
[group('nix-wrapper')]
switch args='':
    sudo nixos-rebuild --flake '{{ flake }}#{{ host }}' switch {{ args }}

# Build as a dry-run
[group('nix-wrapper')]
build args='':
    sudo nixos-rebuild --flake '{{ flake }}#{{ host }}' build {{ args }}

# Build and activate, with rollback on failure
[group('nix-wrapper')]
test args='':
    sudo nixos-rebuild --flake '{{ flake }}#{{ host }}' test {{ args }}

# Switch to previous generation
[group('nix-wrapper')]
rollback:
    sudo /run/current-system/bin/switch-to-configuration switch

# Build documentation
[group('nix-wrapper')]
docs:
    nixos-rebuild --flake '{{ flake }}#{{ host }}' build --build-llvm-tools

# Update flake inputs
[group('nix-wrapper')]
update:
    nix flake update {{ flake }}

# Clean nix store
[group('nix-wrapper')]
clean:
    @sudo nix-collect-garbage -d

# Show current generations
[group('nix-wrapper')]
generations:
    @nix-env -p /nix/var/nix/profiles/system --list-generations

# Symlink dotfiles configs to ~/.config
[group('scripts')]
symlink-configs:
    bash ./scripts/symlink-configs.sh
