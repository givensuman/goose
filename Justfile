[private]
default:
    @just --list

# Check Just Syntax
[group('Just')]
just_check:
    #!/usr/bin/bash
    set -euo pipefail

    find . -type f -name "*.just" | while read -r file; do
    	just --unstable --fmt --check -f $file
    done

    just --unstable --fmt --check -f Justfile

# Fix Just Syntax
[group('Just')]
just_fix:
    #!/usr/bin/bash
    set -euo pipefail

    find . -type f -name "*.just" | while read -r file; do
    	just --unstable --fmt -f $file
    done

    just --unstable --fmt -f Justfile || { exit 1; }

# Clean Repo
[group('Maintenance')]
repo_clean:
    #!/usr/bin/bash
    set -eou pipefail

    touch _build
    find *_build* -exec rm -rf {} \;
    rm -f previous.manifest.json
    rm -f changelog.md
    rm -f output.env
    rm -f output/

# Runs shfmt on all Bash scripts
[group('Maintenance')]
repo_format:
    #!/usr/bin/env bash
    set -eou pipefail

    # Check if shfmt is installed
    if ! command -v shfmt &> /dev/null; then
        echo "shellcheck could not be found. Please install it."
        exit 1
    fi
    # Run shfmt on all Bash scripts
    /usr/bin/find . -iname "*.sh" -type f -exec shfmt --write "{}" ';'

# Runs shell check on all Bash scripts
[group('Maintenance')]
repo_lint:
    #!/usr/bin/env bash
    set -eou pipefail

    # Check if shellcheck is installed
    if ! command -v shellcheck &> /dev/null; then
        echo "shellcheck could not be found. Please install it."
        exit 1
    fi
    # Run shellcheck on all Bash scripts
    /usr/bin/find . -iname "*.sh" -type f -exec shellcheck "{}" ';'

# Fix maintenance and just scripts, all at once
[group('Utility')]
fix: just_fix repo_clean repo_format repo_lint

# Build image locally
[group('Utility')]
build $tag="dev":
    #!/usr/bin/bash
    set -eou pipefail

    buildah build --tag "goose:{{ tag }}" .
