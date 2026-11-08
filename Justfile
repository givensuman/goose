remote := "ghcr.io/givensuman/goose"
local := "localhost/goose-local"
tag := "latest"

[private]
default:
    @just --list

# Rebase onto the published image (the base for everything else)
rebase tag=tag:
    sudo bootc switch {{ remote }}:{{ tag }}

# Build the local layer (Containerfile.local) on top of the published image
build tag=tag:
    sudo podman build --pull=newer -f Containerfile.local \
        --build-arg BASE={{ remote }}:{{ tag }} -t {{ local }}:{{ tag }} .

# Build the local layer and switch to it via containers-storage
switch tag=tag: (build tag)
    sudo bootc switch --transport containers-storage {{ local }}:{{ tag }}

# Build the full image from Containerfile, without the remote (slow; for testing CI changes)
build-full:
    podman build --pull=newer -t localhost/goose-full .

# Apply dotfiles with chezmoi
dotfiles source="https://github.com/givensuman/goose":
    chezmoi init --apply {{ source }}

# Lint shell scripts
lint:
    find . -name '*.sh' -not -path './home/*' -exec shellcheck {} +

# Check Justfile formatting
check:
    just --unstable --fmt --check
