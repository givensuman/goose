#!/bin/bash

tee /etc/ostree/prepare-root.conf <<'EOF'
[composefs]
enabled = yes
[root]
transient = true
EOF

rpm-ostree initramfs-etc --reboot --track=/etc/ostree/prepare-root.conf

curl -sSfL https://artifacts.nixos.org/nix-installer | \
    sh -s -- install ostree --explain --add-channel --persistence=/var/lib/nix

nix-channel --add \
	https://nixos.org/channels/nixpkgs-unstable \
	nixpkgs
nix-channel --add \
	https://github.com/nix-community/home-manager/archive/master.tar.gz \
      	home-manager
nix-channel --update

nix-shell '<home-manager>' -A install

nix-collect-garbage -d

echo "Defaults  secure_path = /nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin:$(sudo printenv PATH)" | sudo tee /etc/sudoers.d/nix-sudo-env
