image-name := "localhost/goose"
recipe-file := "recipe.yml"

default:
    @just --list

# Build the image locally without applying it
build:
    bluebuild build --locally --recipe {{ recipe-file }}

# Build and rebase
rebuild: build
    sudo rpm-ostree rebase ostree-unverified-image:container-storage:{{ image-name }}

# Check the current status of your deployments
status:
    rpm-ostree status

# View diff of pending deployment with current deployment
diff:
    rpm-ostree db diff

# Clean up locally saved system images
clean:
    podman rmi {{ image-name }}
    podman image prune -f

# View logs of the last system build
logs:
    journalctl -u bluebuild --since "1 hour ago"
