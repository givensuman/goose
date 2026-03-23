# Display help with common tasks
help:
    #!/usr/bin/env bash
    set -euo pipefail

    cat << 'EOF'
    Development:
    - Create dev container:    distrobox create --image <image> --name <name>
    - Enter dev container:     distrobox enter <name>

    Package Management:
    - Layer package:           rpm-ostree install <package>
    - List layered packages:   rpm-ostree status
    - Install flatpak:         flatpak install <app>
    - Install CLI tool:        brew install <tool>

    Troubleshooting:
    - Rollback changes:        rpm-ostree rollback
    - Check logs:              journalctl -b
    - Reset flatpak:           flatpak repair

    Documentation: https://github.com/givensuman/goose-linux
    Issues: https://github.com/givensuman/goose-linux/issues
    EOF

# Show system status and health
status:
    #!/usr/bin/env bash
    set -euo pipefail

    @echo "System status``:"
    rpm-ostree status | head -n 20
    @echo ""
    @echo "Container services:"
    systemctl --user is-active podman.socket docker.socket 2>/dev/null || echo "  Not running"
    @echo ""
    @echo "Flatpak updates available:"
    flatpak remote-ls --updates --columns=application 2>/dev/null | wc -l | xargs echo "  "
    @echo ""
    @echo "Disk usage:"
    df -h / | tail -1 | awk '{print "  Root: " $3 " used of " $2 " (" $5 ")"}'
    @echo ""
    @echo "Memory:"
    free -h | grep Mem | awk '{print "  " $3 " used of " $2}'
    @echo ""
    @echo "Uptime:"
    uptime -p | sed 's/up /  /'

# Edit declarative package list
packages:
    #!/usr/bin/env bash
    sudo $EDITOR /etc/goose-linux/modules/dnf.yml
