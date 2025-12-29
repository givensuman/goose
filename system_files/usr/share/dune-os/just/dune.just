# Clean up old packages and Docker/Podman images and volumes
dune-clean:
    #!/usr/bin/env bash
    set -euox pipefail

    echo "Cleaning up system..."
    docker system prune -af
    podman system prune -af
    flatpak uninstall --unused
    rpm-ostree cleanup -bm
    sudo docker system prune -af
    sudo podman system prune -af

# Build various Distrobox toolboxes with pre-defined volumes
dune-build-toolboxes:
    #!/usr/bin/env bash
    set -euox pipefail

    toolbox_names="arch-toolbox debian-toolbox fedora-toolbox ubuntu-toolbox"

    echo "Checking for existing toolboxes..."
    existing_toolboxes=$(distrobox list --format json | jq -r '.[] | select(.Name | test("arch-toolbox|debian-toolbox|fedora-toolbox|ubuntu-toolbox")) | .Name' | tr '\n' ' ' || true)

    replace=false
    if [ -n "$existing_toolboxes" ]; then
        echo "Existing toolboxes found: $existing_toolboxes"
        read -p "Replace existing toolboxes? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            replace=true
        fi
    fi

    if [ "$replace" = true ]; then
        echo "Stopping existing toolboxes..."
        distrobox stop $toolbox_names || true

        echo "Building toolboxes with replacement..."
        distrobox assemble create --replace --yes --file /usr/share/distrobox/distrobox.ini
    else
        echo "Building toolboxes..."
        distrobox assemble create --yes --file /usr/share/distrobox/distrobox.ini
    fi

# Upgrade the system
dune-upgrade:
    #!/usr/bin/env bash
    set -euox pipefail

    echo "Upgrading system..."
    rpm-ostree upgrade

# Pull latest toolbox images
dune-pull-toolboxes:
    #!/usr/bin/env bash
    set -euox pipefail

    echo "Pulling latest toolbox images..."
    podman pull ghcr.io/ublue-os/arch-toolbox:latest
    podman pull ghcr.io/ublue-os/debian-toolbox:latest
    podman pull ghcr.io/ublue-os/fedora-toolbox:latest
    podman pull ghcr.io/ublue-os/ubuntu-toolbox:latest

# Enter a specific toolbox
dune-enter-toolbox name='fedora-toolbox':
    #!/usr/bin/env bash
    set -euox pipefail

    echo "Entering toolbox {{name}}..."
    distrobox enter {{name}}
