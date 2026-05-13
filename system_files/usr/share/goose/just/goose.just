[group('goose')]
setup-rootless-docker:
    #!/usr/bin/bash
    sudo groupadd docker
    sudo usermod -aG docker $USER

[group('goose')]
setup-nix:
    #!/usr/bin/bash
    curl --proto '=https' --tlsv1.2 -sSf -L \
      https://install.determinate.systems/nix | sh -s -- install --no-confirm

    sudo systemctl daemon-reload
    sudo systemctl enable --now nix-daemon

    nix-channel --add \
      https://nixos.org/channels/nixpkgs-unstable \
      nixpkgs
    nix-channel --add \
      https://github.com/nix-community/home-manager/archive/master.tar.gz \
      home-manager
    nix-channel --update

    nix-shell '<home-manager>' -A install

    nix-collect-garbage -d

[group('goose')]
setup-fish:
    #!/usr/bin/bash
    rpm-ostree install --apply-live fish
    sudo usermod -s $(which fish) $USER
