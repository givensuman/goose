import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class RepoMetadataTest(unittest.TestCase):
    def test_image_template_env(self):
        text = (ROOT / "image-template.env").read_text()
        for expected in [
            "IMAGE_NAME=nixos",
            'REPO_ORGANIZATION="givensuman"',
            'DEFAULT_TAG="latest"',
            "BIB_IMAGE=",
        ]:
            self.assertIn(expected, text)

    def test_justfile_has_required_recipes(self):
        text = (ROOT / "Justfile").read_text()
        for recipe in [
            "check:",
            "build",
            "ostree-rechunk",
            "apply-config",
            "list-packages",
            "smoke",
            "generate-default-tag",
            "generate-build-tags",
            "tag-images",
        ]:
            self.assertIn(recipe, text)
        for forbidden in ["nixos-rebuild", "stow", "hosts/"]:
            self.assertNotIn(forbidden, text)

    def test_gitignore_ignores_build_artifacts(self):
        lines = {
            line.strip()
            for line in (ROOT / ".gitignore").read_text().splitlines()
            if line.strip()
        }
        for expected in [
            "cosign.key",
            "_build_*",
            "_build-*/**",
            "output",
            "*_chunkah_*",
            "*_rpm-ostree_*",
        ]:
            self.assertIn(expected, lines)
        for forbidden in ["result", "**/.nixos-test-history", "stow/"]:
            self.assertNotIn(forbidden, lines)
