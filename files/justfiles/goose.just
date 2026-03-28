set system-dir := "/opt/goose"

default:
  @just --list

# Move to system directory
cd:
  #!/usr/bin/env bash
  cd {{ system-dir }}

# Edit system declaratively
edit:
    #!/usr/bin/env bash
    sudo $EDITOR {{ system-dir }}
