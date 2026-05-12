[group('goose')]
setup-rootless-docker:
    #!/usr/bin/bash
    sudo groupadd docker
    sudo usermod -aG docker $USER

[group('goose')]
setup-nix:
    #!/usr/bin/bash
    curl --proto '=https' --tlsv1.2 -sSf -L \
      https://install.determinate.systems/nix | sh -s -- install

[group('goose')]
setup-fish:
    #!/usr/bin/bash
    rpm-ostree install --apply-live fish
    sudo usermod -s $(which fish) $USER
