default:
  @just --list

# Build the image
build:
  bluebuild build ./recipes/recipe.yml -B podman

# Build the image and rebase to it
switch:
  bluebuild switch ./recipes/recipe.yml -B podman

# Validate the recipe file
validate:
  bluebuild validate ./recipes/recipe.yml -B podman
