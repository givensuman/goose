image_name := "localhost/my-atomic-pc"
recipe_file := "recipe.yml"

default:
    @just --list

# Build the image locally without applying it
build:
    bluebuild build --locally --recipe {{ recipe_file }}

# Build and rebase
rebuild: build
    @echo "--- Applying new image to system ---"
    sudo rpm-ostree rebase ostree-unverified-image:container-storage:{{ image_name }}
    @echo "--- Done! Reboot to enter your new generation ---"

# Check the current status of your deployments
status:
    rpm-ostree status

# View diff of pending deployment with current deployment
diff:
    rpm-ostree db diff

# Clean up local podman images to save disk space
clean:
    podman rmi {{ image_name }}
    podman image prune -f

# View logs of the last build
logs:
    journalctl -u bluebuild --since "1 hour ago"
