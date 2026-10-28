import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HOME = ROOT / "home"


class ChezmoiLayoutTest(unittest.TestCase):
    def test_root_file_selects_home(self):
        self.assertEqual((ROOT / ".chezmoiroot").read_text().strip(), "home")

    def test_source_root_files_live_under_home(self):
        expected = [
            ".chezmoi.toml.tmpl",
            "dot_gitconfig.tmpl",
            "dot_config/fish/config.fish",
            "dot_config/cosmic",
            "dot_config/gh/config.yml",
            "dot_config/helix/config.toml",
            "dot_config/nvim/init.lua",
            "dot_config/opencode/opencode.json",
            "dot_config/ghostty/config",
            "dot_config/lazygit/config.yml",
            "dot_config/bottom/bottom.toml",
            "dot_config/zellij/config.kdl",
            "dot_config/bat/config",
            "dot_config/distrobox/distrobox.conf",
            "dot_config/gtk-3.0/settings.ini",
            "dot_config/gtk-4.0/settings.ini",
            "dot_config/Code/User/settings.json",
        ]
        for rel in expected:
            self.assertTrue((HOME / rel).exists(), rel)

    def test_hidden_sources_are_renamed(self):
        self.assertTrue((HOME / "dot_config/fish/conf.d/dot_gitnow").is_file())
        self.assertTrue((HOME / "dot_config/nvim/dot_env.example").is_file())
        self.assertTrue((HOME / "dot_config/nvim/dot_gitignore").is_file())
        for name in [".gitnow", ".env.example", ".gitignore"]:
            self.assertEqual(list(HOME.rglob(name)), [], name)

    def test_bottom_uses_catppuccin(self):
        text = (HOME / "dot_config/bottom/bottom.toml").read_text()
        self.assertIn("[styles.cpu]", text)
        self.assertNotIn("gruvbox", text)

    def test_gtk_settings_exist(self):
        for version in ["gtk-3.0", "gtk-4.0"]:
            text = (HOME / f"dot_config/{version}/settings.ini").read_text()
            self.assertIn("gtk-theme-name=catppuccin-mocha-lavender-standard+default", text)
            self.assertIn("gtk-cursor-theme-name=catppuccin-mocha-lavender-cursors", text)

    def test_stow_and_mutable_fish_state_are_gone(self):
        self.assertFalse((ROOT / "stow").exists())
        self.assertEqual(list(HOME.rglob("fish_variables*")), [])
        self.assertFalse((HOME / "dot_config/fish/fish_plugins").exists())
        self.assertFalse((HOME / "dot_config/opencode/package-lock.json").exists())

    def test_no_nix_runtime_references(self):
        offenders = []
        for path in HOME.rglob("*"):
            if path.is_file():
                text = path.read_text(errors="ignore")
                if any(
                    needle in text
                    for needle in ["/nix/store", "nixos.wiki", "fish-flake"]
                ):
                    offenders.append(str(path))
        self.assertEqual(offenders, [])

    def test_wallpapers_are_system_owned(self):
        self.assertTrue((ROOT / "system_files/usr/share/backgrounds/given/monterey.jpg").exists())

    def test_cosmic_has_no_user_wallpaper_paths(self):
        offenders = []
        for path in HOME.rglob("*"):
            if path.is_file():
                text = path.read_text(errors="ignore")
                if "/home/given/.config/wallpapers" in text:
                    offenders.append(str(path))
        self.assertEqual(offenders, [])

    def test_identity_is_templated(self):
        template = (HOME / ".chezmoi.toml.tmpl").read_text()
        self.assertIn('promptString "name" "givensuman"', template)
        self.assertIn('promptString "email" "givensuman@duck.com"', template)
        gitconfig = (HOME / "dot_gitconfig.tmpl").read_text()
        self.assertIn("{{ .name }}", gitconfig)
        self.assertIn("{{ .email }}", gitconfig)
