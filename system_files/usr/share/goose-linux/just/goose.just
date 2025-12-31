# Clean up old packages and Docker/Podman images and volumes
goose-clean:
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
goose-build-toolboxes:
    #!/usr/bin/env bash
    set -euox pipefail

    toolbox_names=$(grep '^\[' /usr/share/distrobox/distrobox.ini | sed 's/^\[\(.*\)\]$/\1/' | tr '\n' ' ' | sed 's/ $//')
    toolbox_regex=$(echo "$toolbox_names" | tr ' ' '|')

    echo "Checking for existing toolboxes..."
    existing_toolboxes=$(distrobox list --format json | jq -r '.[] | select(.Name | test("'$toolbox_regex'")) | .Name' | tr '\n' ' ' || true)

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
        distrobox assemble create --replace --file /usr/share/distrobox/distrobox.ini
    else
        echo "Building toolboxes..."
        distrobox assemble create --file /usr/share/distrobox/distrobox.ini
    fi

# Enter a specific toolbox
dune-enter-toolbox name='fedora-toolbox':
    #!/usr/bin/env bash
    set -euox pipefail

    echo "Entering toolbox {{ name }}..."
    distrobox enter {{ name }}
