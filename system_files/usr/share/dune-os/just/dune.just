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
    distrobox assemble create --replace --file /usr/share/distrobox/distrobox.ini
    distrobox assemble create --yes
