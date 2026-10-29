#!/usr/bin/env bash

set -euo pipefail

cp -avf /ctx/system_files/. /

dnf5 install -y \
  "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
  "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

dnf5 install -y --nogpgcheck \
  --repofrompath "terra,https://repos.fyralabs.com/terra\$releasever" \
  terra-release

dnf5 -y copr enable awood/bat-extras
dnf5 -y copr enable boobaa/lazygit
dnf5 -y copr enable boobaa/zellij

dnf5 config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
# Google removed the published google-chrome.repo file; the repository itself is still valid.
cat > /etc/yum.repos.d/google-chrome.repo <<'EOF'
[google-chrome]
name=google-chrome
baseurl=https://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub
EOF

rpm --import https://packages.microsoft.com/keys/microsoft.asc
# Microsoft also removed the published vscode.repo file; the repository is still valid.
cat > /etc/yum.repos.d/vscode.repo <<'EOF'
[vscode]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
autorefresh=1
type=rpm-md
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

dnf5 install -y $(grep -vE '^\s*(#|$)' /ctx/build_files/packages/fedora.txt | grep -vx framework-laptop-kmod)
# Docker CE replaces Fedora's moby/compose packages. Scope --allowerasing to
# only the Docker packages so it cannot drop unrelated tools.
third_party="$(grep -vE '^\s*(#|$)' /ctx/build_files/packages/third-party.txt)"
docker_pkgs='^(docker-ce|docker-ce-cli|docker-ce-rootless-extras|containerd.io|docker-buildx-plugin|docker-compose-plugin)$'
dnf5 install -y --allowerasing $(printf '%s\n' "$third_party" | grep -xE "$docker_pkgs")
dnf5 install -y $(printf '%s\n' "$third_party" | grep -vxE "$docker_pkgs")

# akmods' %post refuses to build as root; install its user first, then the
# Framework kmod source without scripts. akmods.service builds it on first boot.
dnf5 install -y akmods
dnf5 install -y --setopt=tsflags=noscripts framework-laptop-kmod
# The akmods COPR is only needed to fetch the kmod; disable it in the image.
sed -i -e 's/^enabled=1$/enabled=0/' -e 's/^enabled_metadata=1$/enabled_metadata=0/' \
  /etc/yum.repos.d/_copr_ublue-os-akmods.repo

dnf5 -y copr disable awood/bat-extras
dnf5 -y copr disable boobaa/lazygit
dnf5 -y copr disable boobaa/zellij

dnf5 install -y cargo rust gcc gcc-c++ make cmake pkgconf-pkg-config \
  libxkbcommon-devel pipewire-devel openssl-devel perl clang llvm git \
  wayland-devel wayland-protocols-devel mesa-libEGL-devel mesa-libGL-devel \
  fontconfig-devel freetype-devel expat-devel dbus-devel

dnf5 install -y --nogpgcheck \
  "https://github.com/D-Brox/cosmic-ext-applet-privacy-indicator/releases/download/v0.3.1/cosmic-ext-applet-privacy-indicator-0.3.1-1.x86_64.rpm"

git clone https://github.com/cosmic-utils/cosmic-ext-applet-weather /tmp/weather
cd /tmp/weather
git checkout 9c295eec5850e39f5c652db7a1e412eb723750c3
cargo build --release --locked
install -Dm755 target/release/cosmic-ext-applet-weather /usr/bin/cosmic-ext-applet-weather
install -Dm644 data/io.github.cosmic_utils.weather-applet.desktop \
  /usr/share/applications/io.github.cosmic_utils.weather-applet.desktop
install -Dm644 data/io.github.cosmic_utils.weather-applet-symbolic.svg \
  /usr/share/icons/hicolor/scalable/apps/io.github.cosmic_utils.weather-applet-symbolic.svg
install -Dm644 data/io.github.cosmic_utils.weather-applet.metainfo.xml \
  /usr/share/metainfo/io.github.cosmic_utils.weather-applet.metainfo.xml
cd /

# Tectonic
curl -fsSL -o /tmp/tectonic.tar.gz \
  https://github.com/tectonic-typesetting/tectonic/releases/download/tectonic%400.17.0/tectonic-0.17.0-x86_64-unknown-linux-gnu.tar.gz
tar -xzf /tmp/tectonic.tar.gz -C /tmp
install -Dm755 /tmp/tectonic /usr/bin/tectonic

# Dive
dnf5 install -y https://github.com/wagoodman/dive/releases/download/v0.13.1/dive_0.13.1_linux_amd64.rpm

# Devbox
curl -fsSL -o /tmp/devbox.tar.gz \
  https://github.com/jetify-com/devbox/releases/download/0.18.5/devbox_0.18.5_linux_amd64.tar.gz
tar -xzf /tmp/devbox.tar.gz -C /tmp
install -Dm755 /tmp/devbox /usr/bin/devbox

# Steel
curl -fsSL -o /tmp/steel.tar.xz \
  https://github.com/mattwparas/steel/releases/download/v0.8.2/steel-interpreter-x86_64-unknown-linux-gnu.tar.xz
curl -fsSL -o /tmp/steel-lsp.tar.xz \
  https://github.com/mattwparas/steel/releases/download/v0.8.2/steel-language-server-x86_64-unknown-linux-gnu.tar.xz
tar -xJf /tmp/steel.tar.xz -C /tmp
tar -xJf /tmp/steel-lsp.tar.xz -C /tmp
install -Dm755 /tmp/steel-interpreter-x86_64-unknown-linux-gnu/steel /usr/bin/steel
install -Dm755 /tmp/steel-language-server-x86_64-unknown-linux-gnu/steel-language-server /usr/bin/steel-language-server

# Steelix
git clone https://github.com/mattwparas/helix /tmp/steelix
cd /tmp/steelix
git checkout ee451df4ff6b0f6416a128f26affc2052b0669c6
cargo build --release --locked --package helix-term --features steel,git
mkdir -p /usr/lib/steelix
install -Dm755 target/release/hx /usr/lib/steelix/hx
cp -a runtime /usr/lib/steelix/runtime
mkdir -p /usr/lib/steelix/runtime/grammars
cp -a /usr/lib64/helix/runtime/grammars/. /usr/lib/steelix/runtime/grammars/
cat > /usr/bin/steelix <<'EOF'
#!/bin/sh
export HELIX_RUNTIME=/usr/lib/steelix/runtime
exec /usr/lib/steelix/hx "$@"
EOF
chmod 755 /usr/bin/steelix
cd /

# OrcaSlicer
curl -fsSL -o /tmp/OrcaSlicer.AppImage \
  https://github.com/OrcaSlicer/OrcaSlicer/releases/download/v2.4.0/OrcaSlicer_Linux_AppImage_Ubuntu2404_V2.4.0.AppImage
chmod +x /tmp/OrcaSlicer.AppImage
cd /tmp
/tmp/OrcaSlicer.AppImage --appimage-extract
mv squashfs-root /opt/orca-slicer
ln -s /opt/orca-slicer/AppRun /usr/bin/orca-slicer
cat > /usr/share/applications/orca-slicer.desktop <<'EOF'
[Desktop Entry]
Name=OrcaSlicer
Exec=/usr/bin/orca-slicer %F
Icon=/opt/orca-slicer/orca-slicer.png
Type=Application
Categories=Graphics;3DGraphics;
EOF
cd /

# npm tools (install under /usr; /usr/local is a symlink to /var/usrlocal)
PUPPETEER_SKIP_DOWNLOAD=1 npm install -g --prefix /usr prettier@3.9.10 markdown-toc@1.2.0 \
  @mermaid-js/mermaid-cli@12.0.0 @github/copilot-language-server@1.562.0

# nixfmt
curl -fsSL -o /usr/bin/nixfmt \
  https://github.com/NixOS/nixfmt/releases/download/v1.5.0/nixfmt
chmod 755 /usr/bin/nixfmt

# Catppuccin GTK and cursors
curl -fsSL -o /tmp/catppuccin-gtk.zip \
  https://github.com/catppuccin/gtk/releases/download/v1.0.3/catppuccin-mocha-lavender-standard+default.zip
unzip -q /tmp/catppuccin-gtk.zip -d /tmp/catppuccin-gtk
mkdir -p /usr/share/themes
cp -a /tmp/catppuccin-gtk/. /usr/share/themes/
curl -fsSL -o /tmp/catppuccin-cursors.zip \
  https://github.com/catppuccin/cursors/releases/download/v2.0.0/catppuccin-mocha-lavender-cursors.zip
unzip -q /tmp/catppuccin-cursors.zip -d /usr/share/icons

# JetBrainsMono Nerd Font (Ghostty, COSMIC, and VS Code use the Nerd Font family)
mkdir -p /usr/share/fonts/nerd-fonts/JetBrainsMono
curl -fsSL -o /tmp/JetBrainsMono.tar.xz \
  https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/JetBrainsMono.tar.xz
tar -xJf /tmp/JetBrainsMono.tar.xz -C /usr/share/fonts/nerd-fonts/JetBrainsMono

# Fira Sans and Ubuntu Sans
curl -fsSL -o /tmp/fira.tar.gz https://github.com/mozilla/Fira/archive/refs/tags/4.202.tar.gz
tar -xzf /tmp/fira.tar.gz -C /tmp
mkdir -p /usr/share/fonts/fira-sans
find /tmp/Fira-4.202 -name '*.otf' -exec cp {} /usr/share/fonts/fira-sans/ \;
curl -fsSL -o /tmp/ubuntu-sans.zip \
  https://github.com/canonical/Ubuntu-Sans-fonts/releases/download/v1.006/UbuntuSans-fonts-1.006.zip
unzip -q /tmp/ubuntu-sans.zip -d /tmp/ubuntu-sans
mkdir -p /usr/share/fonts/ubuntu-sans
find /tmp/ubuntu-sans -name '*.ttf' -exec cp {} /usr/share/fonts/ubuntu-sans/ \;
fc-cache -f

# VS Code extensions. The CLI refuses to run as root in the build container, so
# install pinned VSIXs directly into the bundled extensions directory.
install_vsix() {
  local id="$1" publisher="$2" name="$3" version="$4" target="${5:-}"
  local url="https://marketplace.visualstudio.com/_apis/public/gallery/publishers/$publisher/vsextensions/$name/$version/vspackage"
  if [ -n "$target" ]; then
    url="$url?targetPlatform=$target"
  fi
  local tmp
  tmp="$(mktemp -d)"
  curl -fsSL -o "$tmp/extension.gz" "$url"
  gunzip -c "$tmp/extension.gz" > "$tmp/extension.vsix"
  unzip -q "$tmp/extension.vsix" 'extension/*' -d "$tmp/unpacked"
  grep -q "\"version\"[[:space:]]*:[[:space:]]*\"$version\"" "$tmp/unpacked/extension/package.json"
  mkdir -p "/usr/share/code/resources/app/extensions/$id"
  cp -a "$tmp/unpacked/extension/." "/usr/share/code/resources/app/extensions/$id/"
  rm -rf "$tmp"
}

install_vsix mkhl.direnv mkhl direnv 0.17.0
install_vsix jnoortheen.nix-ide jnoortheen nix-ide 0.5.13
install_vsix tamasfe.even-better-toml tamasfe even-better-toml 0.21.2
install_vsix rust-lang.rust-analyzer rust-lang rust-analyzer 0.4.3098 linux-x64
install_vsix golang.go golang go 0.59.0
install_vsix ms-python.python ms-python python 2026.11.2026102101 linux-x64
install_vsix ms-python.vscode-pylance ms-python vscode-pylance 2026.4.101
install_vsix ms-python.debugpy ms-python debugpy 2026.7.12991008 linux-x64
install_vsix ms-python.vscode-python-envs ms-python vscode-python-envs 1.41.2026102301 linux-x64
install_vsix catppuccin.catppuccin-vsc catppuccin catppuccin-vsc 3.19.0

systemctl enable cosmic-greeter.service \
  bluetooth.service \
  cups.service \
  power-profiles-daemon.service \
  upower.service \
  udisks2.service \
  NetworkManager.service \
  firewalld.service \
  rtkit-daemon.service \
  akmods.service \
  podman.socket \
  flatpak-preinstall.service

systemctl set-default --root=/ graphical.target
firewall-offline-cmd --add-service=localsend

# Keep rust/rust-std-static: rust-analyzer depends on them at runtime.
dnf5 remove -y cargo libxkbcommon-devel pipewire-devel clang llvm
dnf5 clean all
rm -rf /tmp/* /var/cache/* /var/log/* /root/.cargo /root/.npm /root/.cache
