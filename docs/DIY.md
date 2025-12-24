<div align="center">
  <img src="../assets/banner.png" />
</div>

This document aims to guide you through setting up your own spin of a Universal Blue OS. You can also consult Universal Blue's [image template](https://github.com/ublue-os/image-template) which does a pretty good job documenting this stuff.

## Repository Setup

First things first, go ahead and [fork](https://github.com/givensuman/goose-linux/fork) this repository.

Enable GitHub Actions in your repository settings, and create a variable `SIGNING_SECRET` which will hold the private end of your security key.

![Settings dashboard](./assets/dashboard.png)
_GitHub repository settings dashboard_

To obtain a key, use the [cosign](https://github.com/sigstore/cosign) tool. `cosign generate-key-pair` will dump a `cosign.pub` and `cosign.key` file; commit `cosign.pub` into git history and the contents of `cosign.key` go into the `SIGNING_SECRET` variable. Don't use a password during key generation or the CI won't be able to decrypt the key. See [this doc](https://github.blog/security/supply-chain-security/safeguard-container-signing-capability-actions/) for more information.

## Configuring

Your new OS gets built from its [Containerfile](./Containerfile), inside of which we run the contents of the `build_files` directory. Our scripts do most of the leg work, but we can also add content through the `system_files` directory. Universal Blue images will essentially flat-merge these files into the system.

During the build process the system is not yet set to read-only, so we can do anything outside of userland. That means `dnf` will suffice for installing packages.

System `flatpaks` can be designated using [flatpak-preinstall](https://www.mankier.com/1/flatpak-preinstall). This is a useful way of assigning "default apps" for the OS. In our case, this is basically [GNOME applications](./system_files/usr/share/flatpak/preinstall.d/gnome.preinstall).

To configure userland, you can edit `/usr/share/ublue-os/justfile` to define Justfile scripts users can choose to run on their own. You can also define `systemd` services to be called with the `--user` flag over in the [/usr/lib/systemd](./system_files/usr/lib/systemd/system/) folder.

And that's about it! Go nuts.

## Things You Probably Want To Change

This list is not comprehensive and in my experience building your own OS will take time and trial-and-error.

- Run a `grep` search on "goose", "goose-linux", etc. and replace with your new OS's name.

- Revise [`packages.sh`](./build_files/01-packages.sh) and [`desktop.sh`](./build_files/02-desktop.sh) to your liking.

- Revise `systemd` services in [`/usr/lib/systemd/system/`](./system_files/usr/lib/systemd/system/), and their enabling in [`systemd.sh`](./build_files/51-systemd.sh).

- Place a file called "watermark.png" in `system_files/usr/share/plymouth/themes/spinner` to customize the boot splash image.

## I Broke It

No you didn't, it's virtually impossible to break an atomic OS. If you're locked out, your GRUB will hold the entry of the last working version to boot to. Once you're back in, run `rpm-ostree rollback` to undo broken changes.

If you're not locked out but you broke something else (e.g. WiFi), run `rpm-ostree usroverlay` to create a read-write layer over your system and work from there.

<div align="center">
  <img src="../assets/banner.png" />
</div>
