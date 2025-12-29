<div align="center">
  <img src="../assets/goose.png" width="250" />
</div>

# Toolboxes

Dune OS leverages [Distrobox](https://distrobox.it/) to provide containerized development environments, allowing you to run different Linux distributions alongside your immutable base system. This enables you to install and experiment with software without affecting the host system.

<div align="center">
  <img src="../assets/moebius-05.jpg" />
</div>

The default toolbox for `goose` is `goose-toolbox`, which is based on a custom image designed specifically for this distribution. It includes essential development tools and is configured to share certain directories with the host for seamless integration.

Using it is simple:

```bash
distrobox create # to, y'know, create
distrobox enter  # to, y'know, enter
```

The default configuration uses the image `ghcr.io/givensuman/goose-toolbox` and mounts the following volumes read-only:

- `/usr:/usr/local:ro`
- `/etc/localtime:/etc/localtime:ro`
- `/etc/machine-id:/etc/machine-id:ro`
- `/home/linuxbrew/.linuxbrew:/home/linuxbrew/.linuxbrew:ro`

<div align="center">
  <img src="../assets/horizontalrule.png" />
</div>

## Pre-configured Toolboxes

Additionally, there are pre-configured toolboxes based on popular Linux distributions, all sourced from Universal Blue's repository. These are defined in `/usr/share/distrobox/distrobox.ini` and can be created directly by name.

### Available Toolboxes

- **arch-toolbox**: Based on Arch Linux
- **debian-toolbox**: Based on Debian
- **fedora-toolbox**: Based on Fedora
- **ubuntu-toolbox**: Based on Ubuntu

To create any of these toolboxes:

```bash
distrobox create <toolbox-name>
```

For example:

```bash
distrobox create arch-toolbox
distrobox enter arch-toolbox
```

<div align="center">
  <img src="../assets/horizontalrule.png" />
</div>

## Usage Tips

- Use `distrobox list` to see all your created containers.
- Export applications from a toolbox to your host desktop with `distrobox-export --app <app-name>`.
- Install software inside the toolbox as you would on a normal system.
- Remember, changes to the host system are limited to avoid breaking the immutable nature of Dune OS.

## Just Recipes

Dune OS provides several Just recipes for managing toolboxes and system maintenance. Run `ujust` to see all available recipes.

| Recipe               | Description                                                        | Command                           |
| -------------------- | ------------------------------------------------------------------ | --------------------------------- |
| dune-build-toolboxes | Builds all pre-configured toolboxes (arch, debian, fedora, ubuntu) | `ujust dune-build-toolboxes`      |
| dune-pull-toolboxes  | Pulls the latest images for the pre-configured toolboxes           | `ujust dune-pull-toolboxes`       |
| dune-enter-toolbox   | Enters a specified toolbox (defaults to fedora-toolbox)            | `ujust dune-enter-toolbox <name>` |


For more advanced usage and troubleshooting, consult the [Distrobox documentation](https://distrobox.it/).
