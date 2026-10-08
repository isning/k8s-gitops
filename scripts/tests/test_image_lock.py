"""Locked-image reuse must preserve immutable inputs and reject changed pins."""
import importlib.util
from pathlib import Path
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('gen_image_lock', ROOT / 'scripts/gen-image-lock.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class LockedImageTests(unittest.TestCase):
    def setUp(self):
        base = ROOT / '.cache/ccsn-migration/test-lock'
        base.mkdir(parents=True, exist_ok=True)
        self.tmp = tempfile.TemporaryDirectory(dir=base)
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        cluster = self.root / 'clusters/example'
        cluster.mkdir(parents=True)
        (cluster / 'images.lock.nix').write_text('''[
  {
    imageName = "busybox";
    imageDigest = "sha256:old";
    finalImageName = "docker.io/library/busybox";
    finalImageTag = "1.37";
    archiveHash = "sha256-old-archive";
    os = "linux";
    arch = "amd64";
  }
]
''')

    def generate(self, reference, arch='amd64'):
        args = SimpleNamespace(root=str(self.root),cluster='example',os='linux',arch=arch,
                               registry_mirror_map='',mirror_retries=1,verbose=False,
                               cache_dir=str(self.root/'cache'),reuse_locked_images=True,ignore_cache=False)
        generator = module.ImageLockGenerator(args)
        generator.image_map = {reference: {'sources': [], 'sourceChains': [], 'targets': []}}
        generator.total_images = 1
        with patch.object(module,'run_cmd',return_value='sha256:new') as digest, \
             patch.object(generator,'prefetch_archive_hash_via_nix',return_value='sha256-new-archive') as archive:
            generator.resolve_digests_and_archive_hash()
        return generator, digest, archive

    def test_alias_with_same_tag_and_platform_preserves_existing_digest(self):
        generator, digest, archive = self.generate('docker.io/library/busybox:1.37')
        digest.assert_not_called()
        archive.assert_not_called()
        self.assertIn('imageDigest = "sha256:old"',generator.final_nix)

    def test_changed_explicit_digest_is_never_reused(self):
        generator, digest, archive = self.generate('busybox:1.37@sha256:new')
        digest.assert_called_once()
        archive.assert_called_once()
        self.assertIn('imageDigest = "sha256:new"',generator.final_nix)

    def test_changed_platform_is_never_reused(self):
        _, digest, archive = self.generate('busybox:1.37',arch='arm64')
        digest.assert_called_once()
        archive.assert_called_once()

    def test_changed_tag_is_never_reused(self):
        _, digest, archive = self.generate('busybox:1.38')
        digest.assert_called_once()
        archive.assert_called_once()


if __name__ == '__main__':
    unittest.main()
