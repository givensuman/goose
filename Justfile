default:
    @just --list

# sudoif bash function
[group('Utility')]
[private]
sudoif command *args:
    #!/usr/bin/bash
    function sudoif(){
        if [[ "${UID}" -eq 0 ]]; then
            "$@"
        elif [[ "$(command -v sudo)" && -n "${SSH_ASKPASS:-}" ]] && [[ -n "${DISPLAY:-}" || -n "${WAYLAND_DISPLAY:-}" ]]; then
            /usr/bin/sudo --askpass "$@" || exit 1
        elif [[ "$(command -v sudo)" ]]; then
            /usr/bin/sudo "$@" || exit 1
        else
            exit 1
        fi
    }
    sudoif {{ command }} {{ args }}

# Runs shell check on all Bash scripts
lint:
    #!/usr/bin/env bash
    set -eoux pipefail
    # Check if shellcheck is installed
    if ! command -v shellcheck &> /dev/null; then
        echo "shellcheck could not be found. Please install it."
        exit 1
    fi
    # Run shellcheck on all Bash scripts
    /usr/bin/find . -iname "*.sh" -type f -exec shellcheck "{}" ';'

# Runs shfmt on all Bash scripts
format:
    #!/usr/bin/env bash
    set -eoux pipefail
    # Check if shfmt is installed
    if ! command -v shfmt &> /dev/null; then
        echo "shellcheck could not be found. Please install it."
        exit 1
    fi
    # Run shfmt on all Bash scripts
    /usr/bin/find . -iname "*.sh" -type f -exec shfmt --write "{}" ';'

# Validate main recipe file
[group('Utility')]
validate:
    bluebuild validate --all-errors ./recipes/recipe.yml

# Remove build artifacts
[group('Utility')]
clean:
    @sudo rm -rf Containerfile .bluebuild-scripts_*

# Build image
[group('BlueBuild')]
build flags="": clean
    bluebuild build ./recipes/recipe.yml {{ flags }}

# Generate Containerfile output
[group('BlueBuild')]
generate flags="": clean
    bluebuild generate -o Containerfile ./recipes/recipe.yml {{ flags }}

# Attempt to build and rebase into image
[group('BlueBuild')]
switch flags="": clean
    @sudo bluebuild switch -r ./recipes/recipe.yml {{ flags }}
