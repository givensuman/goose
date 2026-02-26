# goose.just – custom ujust recipes for the Goose OS image.
# Available via `ujust` on any installed Goose system.

# Rebuild the OS image locally from the recipe in bootstrapped directory.
[group('goose')]
rebuild:
    #!/bin/bash
    set -euo pipefail
    if ! command -v bluebuild &>/dev/null; then
        echo "ERROR: 'bluebuild' CLI not found." >&2
        exit 1
    fi
    if ! command -v chezmoi &>/dev/null; then
        echo "ERROR: 'chezmoi' CLI not found." >&2
        exit 1
    fi
    echo "==> Rebuilding Goose from ${GOOSE_DIR}/recipes/recipe.yml ..."
    chezmoi cd
    sudo bluebuild build recipes/recipe.yml

# Rebase the system. If --upstream is passed, the rebase is performed against
# the remote image reference.
[group('goose')]
[arg("upstream", long="upstream", value="true")]
rebase upstream="false":
    #!/bin/bash
    set -euo pipefail

    if [[ "${{ upstream }}" == "false" ]]; then
      echo "==> Rebasing locally ..."
      chezmoi cd
      bluebuild switch recipes/recipe.yml

      return
    fi

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

# Apply a mutable overlay to the system.
[group('goose')]
overlay:
  #!/bin/bash
  sudo rpm-ostree usroverlay
