#!/usr/bin/env python3
"""Restrict flux-local's core Secret/ConfigMap parsing to apiVersion v1.

Crossplane also has a kind Secret. Apply to the pinned checkout before installing
it; repeated runs leave an already patched checkout unchanged.
"""
import argparse
from pathlib import Path


def patch(root: Path) -> None:
    for name in ('manifest.py', 'git_repo.py'):
        path = root / 'flux_local' / name
        source = path.read_text()
        for kind in ('CONFIG_MAP_KIND', 'SECRET_KIND'):
            old = f'if kind == {kind}:' if name == 'manifest.py' else f'if doc.get("kind") == {kind}'
            new = (f'if kind == {kind} and api_version == "v1":' if name == 'manifest.py'
                   else f'if doc.get("kind") == {kind} and doc.get("apiVersion") == "v1"')
            if new in source:
                continue
            if old not in source:
                raise ValueError(f'{path}: expected parser condition missing: {old}')
            source = source.replace(old, new)
        path.write_text(source)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('checkout', type=Path)
    patch(parser.parse_args().checkout)
