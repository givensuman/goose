[group('goose')]
setup-rootless-docker:
    #!/usr/bin/bash
    @echo TODO

[group('goose')]
setup-nix:
    #!/usr/bin/bash
    curl --proto '=https' --tlsv1.2 -sSf -L \
      https://install.determinate.systems/nix | sh -s -- install
