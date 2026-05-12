#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

IMAGE_NAME="docker.io/goharbor/nginx-photon"
IMAGE_TAG="v2.15.0"
IMAGE_DIGEST="sha256:4fcfe831b1d99e3193a586e59ba4984ca2587a9b2998ccd433f8e9425beaabdc"

SOURCES=(
  "dockerproxy.net/goharbor/nginx-photon"
  "docker.io/goharbor/nginx-photon"
)

build_archive_with_hash() {
  local source_image="$1"
  local archive_hash="$2"

  nix build --impure --no-link --print-out-paths --expr "
    let
      flake = builtins.getFlake (toString ${ROOT_DIR});
      pkgs = import flake.inputs.nixpkgs { system = builtins.currentSystem; };
    in
    flake.lib.mkMultiArchImageArchive {
      inherit pkgs;
      sourceImages = [ \"${source_image}\" ];
      finalImageName = \"${IMAGE_NAME}\";
      finalImageTag = \"${IMAGE_TAG}\";
      imageDigest = \"${IMAGE_DIGEST}\";
      archiveHash = \"${archive_hash}\";
      mirrorRetries = 2;
    }
  "
}

run_skopeo() {
  nix shell --impure --expr "
    let
      flake = builtins.getFlake (toString ${ROOT_DIR});
      pkgs = import flake.inputs.nixpkgs { system = builtins.currentSystem; };
    in
    [ pkgs.skopeo ]
  " -c skopeo "$@"
}

build_with_fake_hash() {
  local source_image="$1"
  nix build --impure --no-link --print-out-paths --expr "
    let
      flake = builtins.getFlake (toString ${ROOT_DIR});
      pkgs = import flake.inputs.nixpkgs { system = builtins.currentSystem; };
    in
    flake.lib.mkMultiArchImageArchive {
      inherit pkgs;
      sourceImages = [ \"${source_image}\" ];
      finalImageName = \"${IMAGE_NAME}\";
      finalImageTag = \"${IMAGE_TAG}\";
      imageDigest = \"${IMAGE_DIGEST}\";
      archiveHash = pkgs.lib.fakeHash;
      mirrorRetries = 2;
    }
  " 2>&1 || true
}

extract_got_hash() {
  sed -n 's/.*got:[[:space:]]*\(sha256-[A-Za-z0-9+/=]*\).*/\1/p' | tail -n 1
}

verify_archive_contents() {
  local archive_hash="$1"
  local source_image="$2"

  local out_path
  out_path="$(build_archive_with_hash "${source_image}" "${archive_hash}")"

  local tmpdir
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "${tmpdir}"' RETURN

  tar -xf "${out_path}" -C "${tmpdir}"

  python3 - "$tmpdir" <<'PY'
import hashlib
import json
import pathlib
import sys

tmpdir = pathlib.Path(sys.argv[1])


def sha256_hex(path: pathlib.Path) -> str:
    hasher = hashlib.sha256()
    with path.open("rb") as handle:
        while True:
            chunk = handle.read(1024 * 1024)
            if not chunk:
                break
            hasher.update(chunk)
    return hasher.hexdigest()


def verify_oci_archive(root: pathlib.Path) -> None:
    index_path = root / "index.json"
    index = json.loads(index_path.read_text(encoding="utf-8"))

    manifests = index.get("manifests", [])
    if not manifests:
        raise SystemExit("oci archive index.json contains no manifests")

    for descriptor in manifests:
        digest = descriptor.get("digest")
        if not digest:
            raise SystemExit("oci descriptor missing digest")

        media_type = descriptor.get("mediaType")
        if not media_type:
            raise SystemExit("oci descriptor missing mediaType")

        algo, hex_value = digest.split(":", 1)
        if algo != "sha256":
            raise SystemExit(f"unexpected digest algo: {digest}")

        blob_path = root / "blobs" / algo / hex_value
        if not blob_path.exists():
            raise SystemExit(f"missing blob file for digest: {digest}")

        descriptor_size = descriptor.get("size")
        if not isinstance(descriptor_size, int) or descriptor_size < 0:
            raise SystemExit(f"invalid descriptor size for digest: {digest}")
        actual_size = blob_path.stat().st_size
        if actual_size != descriptor_size:
            raise SystemExit(
                f"blob size mismatch: {digest} expected {descriptor_size} got {actual_size}"
            )

        file_hash = sha256_hex(blob_path)
        if file_hash != hex_value:
            raise SystemExit(f"blob digest mismatch: {digest} got sha256:{file_hash}")

        if media_type in {
            "application/vnd.oci.image.manifest.v1+json",
            "application/vnd.docker.distribution.manifest.v2+json",
        }:
            manifest = json.loads(blob_path.read_text(encoding="utf-8"))
            referenced = []
            config = manifest.get("config")
            if config and "digest" in config:
                referenced.append((config["digest"], config.get("size")))
            for layer in manifest.get("layers", []):
                if "digest" in layer:
                    referenced.append((layer["digest"], layer.get("size")))

            for child_digest, child_size in referenced:
                child_algo, child_hex = child_digest.split(":", 1)
                if child_algo != "sha256":
                    raise SystemExit(f"unexpected digest algo: {child_digest}")
                child_blob = root / "blobs" / child_algo / child_hex
                if not child_blob.exists():
                    raise SystemExit(f"missing blob file for digest: {child_digest}")
                if not isinstance(child_size, int) or child_size < 0:
                    raise SystemExit(f"invalid descriptor size for digest: {child_digest}")
                actual_child_size = child_blob.stat().st_size
                if actual_child_size != child_size:
                    raise SystemExit(
                        f"blob size mismatch: {child_digest} expected {child_size} got {actual_child_size}"
                    )
                child_hash = sha256_hex(child_blob)
                if child_hash != child_hex:
                    raise SystemExit(
                        f"blob digest mismatch: {child_digest} got sha256:{child_hash}"
                    )


def verify_docker_archive(root: pathlib.Path) -> None:
    manifest_path = root / "manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    if not isinstance(manifest, list) or not manifest:
        raise SystemExit("docker archive manifest.json is empty or invalid")

    for image_entry in manifest:
        config_path = image_entry.get("Config")
        if not config_path:
            raise SystemExit("docker archive entry missing Config")
        config_file = root / config_path
        if not config_file.exists():
            raise SystemExit(f"missing config file: {config_path}")

        layers = image_entry.get("Layers", [])
        if not isinstance(layers, list):
            raise SystemExit("docker archive entry Layers is not a list")
        for layer_path in layers:
            layer_file = root / layer_path
            if not layer_file.exists():
                raise SystemExit(f"missing layer file: {layer_path}")


if (tmpdir / "index.json").exists() and (tmpdir / "oci-layout").exists():
    verify_oci_archive(tmpdir)
elif (tmpdir / "manifest.json").exists():
    verify_docker_archive(tmpdir)
else:
    raise SystemExit("unknown archive layout: neither OCI nor Docker archive detected")
PY
}

verify_archive_import() {
  local archive_hash="$1"
  local source_image="$2"

  local out_path
  out_path="$(build_archive_with_hash "${source_image}" "${archive_hash}")"

  local tmpdir
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "${tmpdir}"' RETURN

  local imported=0
  local transport
  for transport in oci-archive docker-archive; do
    local import_dir="${tmpdir}/imported-${transport}"
    rm -rf "${import_dir}"
    mkdir -p "${import_dir}"

    if run_skopeo copy --insecure-policy --multi-arch all --preserve-digests \
      "${transport}:${out_path}:${IMAGE_NAME}:${IMAGE_TAG}" \
      "dir:${import_dir}" >/dev/null 2>&1; then
      imported=1
      break
    fi

    if run_skopeo copy --insecure-policy --multi-arch all --preserve-digests \
      "${transport}:${out_path}" \
      "dir:${import_dir}" >/dev/null 2>&1; then
      imported=1
      break
    fi
  done

  if [[ "${imported}" -ne 1 ]]; then
    echo "archive import verification failed for ${out_path}" >&2
    exit 1
  fi
}

verify_reproducible_build() {
  local archive_hash="$1"
  local source_image="$2"

  local out_path_a
  local out_path_b

  out_path_a="$(build_archive_with_hash "${source_image}" "${archive_hash}")"
  out_path_b="$(build_archive_with_hash "${source_image}" "${archive_hash}")"

  local path_hash_a
  local path_hash_b
  path_hash_a="$(nix hash path "${out_path_a}")"
  path_hash_b="$(nix hash path "${out_path_b}")"

  if [[ "${path_hash_a}" != "${path_hash_b}" ]]; then
    echo "reproducibility check failed for source ${source_image}" >&2
    echo "first output:  ${out_path_a} (${path_hash_a})" >&2
    echo "second output: ${out_path_b} (${path_hash_b})" >&2
    exit 1
  fi
}

echo "checking mirror consistency"

declare -A HASH_BY_SOURCE=()
for source_image in "${SOURCES[@]}"; do
  echo "prefetch from ${source_image}"
  prefetch_output="$(build_with_fake_hash "${source_image}")"
  got_hash="$(printf '%s\n' "${prefetch_output}" | extract_got_hash)"
  if [[ -z "${got_hash}" ]]; then
    echo "failed to extract got hash for source ${source_image}" >&2
    printf '%s\n' "${prefetch_output}" >&2
    exit 1
  fi
  HASH_BY_SOURCE["${source_image}"]="${got_hash}"
  echo "got ${got_hash}"
done

reference_hash="${HASH_BY_SOURCE[${SOURCES[0]}]}"
for source_image in "${SOURCES[@]}"; do
  if [[ "${HASH_BY_SOURCE[${source_image}]}" != "${reference_hash}" ]]; then
    echo "mirror inconsistency: ${source_image} -> ${HASH_BY_SOURCE[${source_image}]}, expected ${reference_hash}" >&2
    exit 1
  fi
done

echo "mirror consistency passed: ${reference_hash}"

echo "verifying reproducible build"
verify_reproducible_build "${reference_hash}" "${SOURCES[0]}"
echo "reproducible build check passed"

echo "verifying archive import"
verify_archive_import "${reference_hash}" "${SOURCES[0]}"
echo "archive import check passed"

echo "verifying archive contents"
verify_archive_contents "${reference_hash}" "${SOURCES[0]}"
echo "archive content digest verification passed"
