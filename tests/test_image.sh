#!/bin/bash
set -euo pipefail

IMAGE="${1:-localhost/nixos:test}"
REPO="$(cd "$(dirname "$0")/.." && pwd)"

run() {
  podman run --rm "$IMAGE" "$@"
}

run rpm -q \
  cosmic-session \
  cosmic-greeter \
  cosmic-term \
  ghostty \
  bottom \
  lazygit \
  zellij \
  code \
  google-chrome-stable \
  chezmoi \
  cosmic-ext-applet-privacy-indicator

run bash -c 'for p in cosmic-edit cosmic-player cosmic-reader; do if rpm -q "$p" >/dev/null 2>&1; then exit 1; fi; done'

run test -x /usr/bin/cosmic-ext-applet-weather
run test -x /usr/bin/steel
run test -x /usr/bin/steel-language-server
run test -x /usr/bin/steelix
run test -x /usr/bin/tectonic
run test -x /usr/bin/devbox
run test -x /usr/bin/nixfmt
run test -x /usr/bin/rust-analyzer

run bash -c 'for e in mkhl.direnv jnoortheen.nix-ide tamasfe.even-better-toml rust-lang.rust-analyzer golang.go ms-python.python ms-python.vscode-pylance ms-python.debugpy ms-python.vscode-python-envs catppuccin.catppuccin-vsc; do test -f "/usr/share/code/resources/app/extensions/$e/package.json" || exit 1; done'

run test -f /usr/share/applications/io.github.cosmic_utils.weather-applet.desktop
run test -f /etc/flatpak/preinstall.d/given.preinstall
run test -L /etc/systemd/system/multi-user.target.wants/flatpak-preinstall.service
run grep -q localsend /etc/firewalld/zones/public.xml
run grep -q 'protocol="tcp" port="53317"' /etc/firewalld/services/localsend.xml
run grep -q 'protocol="udp" port="53317"' /etc/firewalld/services/localsend.xml
run bash -c '! grep -Eq "^[[:space:]]*enabled[[:space:]]*=[[:space:]]*1" /etc/yum.repos.d/_copr_ublue-os-akmods.repo 2>/dev/null'

run systemctl --root=/ is-enabled cosmic-greeter.service
run systemctl --root=/ is-enabled firewalld.service
run systemctl --root=/ is-enabled akmods.service
run systemctl --root=/ is-enabled flatpak-preinstall.service
run test ! -e /home/given

podman run --rm \
  --security-opt label=disable \
  -v "$REPO:/repo:ro" \
  "$IMAGE" \
  bash -c '
    tmp="$(mktemp -d)"
    HOME="$tmp" XDG_CONFIG_HOME="$tmp/.config" \
      chezmoi --source /repo init --apply --promptDefaults --no-tty
    test -f "$tmp/.config/fish/config.fish"
    test -d "$tmp/.config/cosmic"
    test -f "$tmp/.gitconfig"
  '

run bootc container lint
