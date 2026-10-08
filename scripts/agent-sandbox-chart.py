"""Package and publish the pinned upstream chart without replacing existing tags."""

import argparse
import copy
import gzip
import hashlib
import io
import json
from pathlib import Path
import subprocess
import tarfile

import yaml


def run(*args):
    result = subprocess.run(args, text=True, capture_output=True)
    if result.stderr:
        print(result.stderr, end="")
    result.check_returncode()
    return result.stdout


def canonical_archive(path):
    """Remove build timestamps and host ownership from Helm's archive."""
    raw = io.BytesIO()
    with tarfile.open(path, "r:gz") as source:
        with tarfile.open(fileobj=raw, mode="w", format=tarfile.USTAR_FORMAT) as target:
            for entry in sorted(source.getmembers(), key=lambda item: item.name):
                if not entry.isfile() or not entry.name.startswith("agent-sandbox/"):
                    raise ValueError(f"Unexpected chart entry: {entry.name}")
                item = copy.copy(entry)
                item.uid = item.gid = item.mtime = 0
                item.uname = item.gname = ""
                item.mode = 0o644
                target.addfile(item, source.extractfile(entry))
    return gzip.compress(raw.getvalue(), mtime=0)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("stage", choices=["prepare", "publish"])
    parser.add_argument("--source", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    config = json.loads(Path(".github/agent-sandbox-chart.json").read_text())
    args.output.mkdir(parents=True, exist_ok=True)
    package = args.output / f"agent-sandbox-{config['chart_version']}.tgz"
    release = yaml.safe_load(Path("infra/controllers/general/base/agent-sandbox/helm-release.yaml").read_text())
    values = args.output / "values.yaml"
    values.write_text(yaml.safe_dump(release["spec"]["values"]))
    if args.stage == "prepare":
        if args.source is None:
            parser.error("prepare requires --source")
        checkout = run("git", "-C", str(args.source.parent), "rev-parse", "HEAD").strip()
        if checkout != config["upstream_commit"]:
            raise ValueError("Upstream checkout does not match the pinned commit")
        run("helm", "lint", str(args.source), "--values", str(values))
        run("helm", "package", str(args.source), "--version", config["chart_version"],
            "--app-version", config["upstream_version"], "--destination", str(args.output))
        package.write_bytes(canonical_archive(package))
        rendered = run("helm", "template", "agent-sandbox", str(package),
                       "--namespace", "agent-sandbox-system", "--include-crds", "--values", str(values))
        (args.output / "rendered.yaml").write_text(rendered)
        print(f"Prepared {package}; sha256:{hashlib.sha256(package.read_bytes()).hexdigest()}")
        return

    # Only a genuinely absent tag permits publishing. Auth/transport failures stop the job.
    reference = config["registry"] + "/agent-sandbox"
    downloaded = args.output / "registry-check"
    downloaded.mkdir(exist_ok=True)
    pull = ["helm", "pull", reference, "--version", config["chart_version"], "--destination", str(downloaded)]
    existing = subprocess.run(pull, capture_output=True, text=True)
    if existing.returncode:
        error = existing.stderr.lower()
        if not any(message in error for message in ("not found", "manifest_unknown", "manifest unknown")):
            raise RuntimeError(existing.stderr)
        print(run("helm", "push", str(package), config["registry"]))
        subprocess.run(pull, check=True)
    remote_package = downloaded / package.name
    if remote_package.read_bytes() != package.read_bytes():
        raise ValueError("Published tag has different content; increment chart_version instead of replacing it")
    digest = run("helm", "show", "chart", reference, "--version", config["chart_version"])
    print(digest)
    print(f"Verified {reference}:{config['chart_version']} against the local package")


if __name__ == "__main__":
    main()
