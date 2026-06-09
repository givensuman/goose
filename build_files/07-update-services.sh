#!/usr/bin/bash

source "$(dirname "$0")/00-functions.sh"

echo "::group:: $(basename "$0")"

set -euo pipefail
trap 'log_error "Script failed at line $LINENO"' ERR

log_info "Creating bootc auto-update timer..."
cat >/usr/lib/systemd/system/bootc-auto-update.timer <<'TIMER'
[Unit]
Description=Periodic bootc upgrade timer
ConditionPathExists=/usr/bin/bootc

[Timer]
OnCalendar=daily
RandomizedDelaySec=1h
Persistent=true

[Install]
WantedBy=timers.target
TIMER

cat >/usr/lib/systemd/system/bootc-auto-update.service <<'SERVICE'
[Unit]
Description=Bootc upgrade service
ConditionPathExists=/usr/bin/bootc

[Service]
Type=oneshot
ExecStart=/usr/bin/bootc upgrade
SERVICE

log_info "Creating flatpak auto-update timer..."
cat >/usr/lib/systemd/system/flatpak-auto-update.timer <<'TIMER'
[Unit]
Description=Periodic flatpak update timer
ConditionPathExists=/usr/bin/flatpak

[Timer]
OnCalendar=weekly
RandomizedDelaySec=2h
Persistent=true

[Install]
WantedBy=timers.target
TIMER

cat >/usr/lib/systemd/system/flatpak-auto-update.service <<'SERVICE'
[Unit]
Description=Flatpak update service
ConditionPathExists=/usr/bin/flatpak

[Service]
Type=oneshot
ExecStart=/usr/bin/flatpak update -y --system
SERVICE

log_info "Enabling update timers..."
enable_service bootc-auto-update.timer
enable_service flatpak-auto-update.timer

echo "::endgroup::"
