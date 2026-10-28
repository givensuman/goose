import configparser
import os
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SYS = ROOT / "system_files"


class SystemFilesTest(unittest.TestCase):
    def test_localtime_is_new_york(self):
        self.assertEqual(
            os.readlink(SYS / "etc/localtime"),
            "/usr/share/zoneinfo/America/New_York",
        )

    def test_locale_and_cosmic_environment(self):
        self.assertIn("LANG=en_US.UTF-8", (SYS / "etc/locale.conf").read_text())
        env = (SYS / "etc/environment.d/90-cosmic.conf").read_text()
        self.assertIn("COSMIC_DATA_CONTROL_ENABLED=1", env)
        self.assertIn("PUPPETEER_SKIP_DOWNLOAD=1", env)
        self.assertIn("PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable", env)

    def test_gitconfig_has_aliases_and_no_identity(self):
        text = (SYS / "etc/gitconfig").read_text()
        self.assertIn("gh auth git-credential", text)
        self.assertIn("[alias]", text)
        self.assertIn("autoSetupRemote = true", text)
        self.assertNotIn("[user]", text)

    def test_git_aliases_are_valid(self):
        text = (SYS / "etc/gitconfig").read_text()
        config = configparser.ConfigParser(interpolation=None)
        config.read(str(SYS / "etc/gitconfig"))
        expected = {
            "c": "commit --verbose",
            "ca": "commit -a --verbose",
            "m": "commit --amend --verbose",
            "d": "diff",
            "ds": "diff --stat",
            "dc": "diff --cached",
            "co": "checkout",
        }
        for alias, value in expected.items():
            self.assertEqual(config.get("alias", alias), value)
        for broken in [
            "    c = commit --v\n",
            "    ca = commit -a --v\n",
            "    m = commit --amend --v\n",
            "    d = d\n",
            "    ds = diff --s\n",
            "    dc = diff --c\n",
            "    co = c\n",
        ]:
            self.assertNotIn(broken, text)

    def test_audio_limits(self):
        text = (SYS / "etc/security/limits.d/95-audio.conf").read_text()
        self.assertIn("@audio", text)
        self.assertIn("memlock", text)
        self.assertIn("rtprio", text)
        self.assertIn("nofile", text)

    def test_flatpak_preinstall_list(self):
        config = configparser.ConfigParser(interpolation=None)
        config.read(str(SYS / "etc/flatpak/preinstall.d/given.preinstall"))
        apps = [
            "io.podman_desktop.PodmanDesktop",
            "com.spotify.Client",
            "io.github.milkshiift.GoofCord",
            "de.haeckerfelix.Fragments",
            "org.nickvision.tubeconverter",
            "com.obsproject.Studio",
            "org.kde.kdenlive",
            "org.blender.Blender",
            "org.inkscape.Inkscape",
            "org.gimp.GIMP",
            "org.localsend.localsend_app",
            "org.freecad.FreeCAD",
            "com.github.tchx84.Flatseal",
            "io.github.flattool.Warehouse",
            "io.github.flattool.Ignition",
            "org.gnome.baobab",
            "org.gnome.Boxes",
            "org.gnome.Calendar",
            "org.gnome.Characters",
            "org.gnome.clocks",
            "org.gnome.Contacts",
            "org.gnome.Firmware",
            "org.gnome.font-viewer",
            "org.gnome.Logs",
            "org.gnome.Loupe",
            "org.gnome.Maps",
            "org.gnome.Papers",
            "org.gnome.Showtime",
            "org.gnome.Snapshot",
            "org.gnome.TextEditor",
            "org.gnome.Weather",
        ]
        self.assertEqual(len(config.sections()), len(apps))
        for app in apps:
            section = f"Flatpak Preinstall {app}"
            self.assertIn(section, config.sections())
            self.assertEqual(config.get(section, "Branch"), "stable")

    def test_flatpak_service_stamps_only_after_success(self):
        text = (SYS / "etc/systemd/system/flatpak-preinstall.service").read_text()
        self.assertIn("ConditionPathExists=!/var/lib/flatpak/.given-preinstall-done", text)
        self.assertIn("flatpak preinstall -y --system", text)
        self.assertIn("flatpak override --system", text)
        self.assertIn("touch /var/lib/flatpak/.given-preinstall-done", text)
        self.assertLess(
            text.index("flatpak preinstall"),
            text.index("touch /var/lib/flatpak/.given-preinstall-done"),
        )

    def test_service_is_enabled(self):
        link = SYS / "etc/systemd/system/multi-user.target.wants/flatpak-preinstall.service"
        self.assertEqual(
            os.readlink(link),
            "../flatpak-preinstall.service",
        )

    def test_localsend_firewall_service(self):
        text = (SYS / "etc/firewalld/services/localsend.xml").read_text()
        self.assertIn('port="53317"', text)
        self.assertIn('protocol="tcp"', text)
        self.assertIn('protocol="udp"', text)

    def test_flathub_remote_file_is_real(self):
        text = (SYS / "etc/flatpak/remotes.d/flathub.flatpakrepo").read_text()
        self.assertIn("GPGKey=", text)
        self.assertNotIn("...", text)

    def test_bootc_kargs(self):
        text = (SYS / "usr/lib/bootc/kargs.d/10-given.toml").read_text()
        self.assertIn("quiet", text)
