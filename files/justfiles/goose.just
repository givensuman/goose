# goose.just – custom ujust recipes for the Goose OS image.
# Available via `ujust` on any installed Goose system.

# Bootstrap the Goose source repository into /etc/goose.
# After bootstrapping, local rebuilds and git pushes are possible from there.
[group('goose')]
bootstrap-goose:
    #!/usr/bin/env bash
    set -euo pipefail
    sudo /usr/libexec/goose/bootstrap-goose.sh

# Rebuild the OS image locally from the recipe in /etc/goose.
# Requires 'bluebuild' CLI to be installed and /etc/goose bootstrapped.
[group('goose')]
rebuild:
    #!/usr/bin/env bash
    set -euo pipefail
    GOOSE_DIR="/etc/goose"
    if [[ ! -d "${GOOSE_DIR}" ]]; then
        echo "ERROR: ${GOOSE_DIR} not found. Run 'ujust bootstrap-goose' first." >&2
        exit 1
    fi
    if ! command -v bluebuild &>/dev/null; then
        echo "ERROR: 'bluebuild' CLI not found. Install it from https://blue-build.org/install/" >&2
        exit 1
    fi
    echo "==> Rebuilding Goose from ${GOOSE_DIR}/recipes/recipe.yml ..."
    cd "${GOOSE_DIR}"
    sudo bluebuild build recipes/recipe.yml

# Rebase the running system to the latest published Goose image from GHCR.
# The target image is detected from the current deployment's image reference.
[group('goose')]
rebase:
    #!/usr/bin/env bash
    set -euo pipefail
    # Detect the image name from the current deployment so forks work automatically
    CURRENT_IMAGE=$(rpm-ostree status --json 2>/dev/null \
        | jq -r '.deployments[0]."container-image-reference" // empty' \
        | sed 's|ostree-image-signed:docker://||' \
        | sed 's|ostree-unverified-registry:||')
    if [[ -z "${CURRENT_IMAGE}" ]]; then
        echo "Could not detect current image reference; defaulting to ghcr.io/givensuman/goose:latest"
        CURRENT_IMAGE="ghcr.io/givensuman/goose:latest"
    fi
    # Always target the :latest tag of the same image
    IMAGE="ostree-image-signed:docker://${CURRENT_IMAGE%%:*}:latest"
    echo "==> Rebasing to ${IMAGE} ..."
    rpm-ostree rebase "${IMAGE}"
    echo ""
    echo "Rebase staged. Reboot to apply:"
    echo "  systemctl reboot"

# Apply pending system updates (rpm-ostree + flatpak).
[group('goose')]
update:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "==> Checking for rpm-ostree updates..."
    rpm-ostree upgrade --check && rpm-ostree upgrade || true
    echo "==> Updating Flatpaks..."
    flatpak update --noninteractive || true
