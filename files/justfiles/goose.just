system-dir := "/opt/goose"

default:
    @just --list

# Move to system directory
cd:
    #!/usr/bin bash
    cd {{ system-dir }}

# Edit system declaratively
edit:
    #!/usr/bin bash
    sudo $EDITOR {{ system-dir }}
