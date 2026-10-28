import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def packages(path):
    return {
        line.strip()
        for line in (ROOT / path).read_text().splitlines()
        if line.strip() and not line.lstrip().startswith("#")
    }


class BuildFilesTest(unittest.TestCase):
    def test_containerfile_uses_base_main_and_lints(self):
        text = (ROOT / "Containerfile").read_text()
        self.assertIn("FROM ghcr.io/ublue-os/base-main:latest", text)
        self.assertIn("RUN rm /opt && mkdir /opt", text)
        self.assertIn("RUN bootc container lint", text)
        self.assertIn("COPY build_files /build_files", text)
        self.assertNotIn("COPY home", text)

    def test_fedora_packages(self):
        fedora = packages("build_files/packages/fedora.txt")
        for pkg in [
            "chezmoi",
            "cosmic-session",
            "cosmic-greeter",
            "cosmic-term",
            "framework-laptop-kmod",
            "nodejs22",
            "nodejs22-npm-bin",
            "7zip",
            "tar",
            "make",
            "firewalld",
            "gnome-keyring-pam",
            "gtk-murrine-engine",
            "rsms-inter-fonts",
            "jetbrains-mono-fonts-all",
            "google-noto-color-emoji-fonts",
            "ShellCheck",
            "ripgrep",
            "zoxide",
            "fzf",
        ]:
            self.assertIn(pkg, fedora)
        for forbidden in [
            "cosmic-edit",
            "cosmic-player",
            "cosmic-reader",
            "p7zip",
            "gnutar",
            "gnumake",
            "nodejs",
            "npm",
            "stow",
        ]:
            self.assertNotIn(forbidden, fedora)

    def test_third_party_packages(self):
        third = packages("build_files/packages/third-party.txt")
        for pkg in [
            "steam",
            "ghostty",
            "bottom",
            "opencode",
            "bat-extras",
            "lazygit",
            "zellij",
            "google-chrome-stable",
            "code",
            "docker-ce",
            "docker-ce-cli",
            "containerd.io",
            "docker-buildx-plugin",
            "docker-compose-plugin",
        ]:
            self.assertIn(pkg, third)

    def test_build_script_pins_and_services(self):
        text = (ROOT / "build_files/build.sh").read_text()
        for pinned in [
            "cosmic-ext-applet-privacy-indicator-0.3.1-1.x86_64.rpm",
            "9c295eec5850e39f5c652db7a1e412eb723750c3",
            "ee451df4ff6b0f6416a128f26affc2052b0669c6",
            "prettier@3.9.10",
            "markdown-toc@1.2.0",
            "@mermaid-js/mermaid-cli@12.0.0",
            "@github/copilot-language-server@1.562.0",
            "catppuccin-mocha-lavender-standard+default.zip",
            "catppuccin-mocha-lavender-cursors.zip",
            "wayland-devel",
            "mesa-libEGL-devel",
            "nerd-fonts",
            "v3.5.1",
        ]:
            self.assertIn(pinned, text)
        self.assertIn("firewall-offline-cmd --add-service=localsend", text)
        self.assertIn("systemctl enable cosmic-greeter.service", text)
        self.assertIn("systemctl set-default --root=/ graphical.target", text)

    def test_build_script_copies_system_files(self):
        text = (ROOT / "build_files/build.sh").read_text()
        self.assertIn("cp -avf /ctx/system_files/. /", text)
        self.assertIn("set -euxo pipefail", text)
