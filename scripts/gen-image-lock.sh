#!/usr/bin/env bash
set -euo pipefail

ROOT="."
CLUSTER=""
ARCH="amd64"
OS="linux"
INCLUDE_HELM="1"
AUTO_DISCOVER="1"
NAMESPACES_RAW=""
KUSTOMIZATIONS_RAW=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      ROOT="$2"; shift 2 ;;
    --cluster)
      CLUSTER="$2"; shift 2 ;;
    --arch)
      ARCH="$2"; shift 2 ;;
    --os)
      OS="$2"; shift 2 ;;
    --include-helm)
      INCLUDE_HELM="$2"; shift 2 ;;
    --auto-discover)
      AUTO_DISCOVER="$2"; shift 2 ;;
    --namespaces)
      NAMESPACES_RAW="$2"; shift 2 ;;
    --kustomizations)
      KUSTOMIZATIONS_RAW="$2"; shift 2 ;;
    *)
      echo "unknown arg: $1" >&2
      exit 1 ;;
  esac
done

: "${INCLUDE_HELM:=1}"
: "${AUTO_DISCOVER:=1}"
: "${NAMESPACES_RAW:=}"
: "${KUSTOMIZATIONS_RAW:=}"

if [[ -z "$CLUSTER" ]]; then
  echo "--cluster is required" >&2
  exit 1
fi

FLUX_ROOT="$ROOT/clusters/$CLUSTER"
OUT_LOCK_FILE="$FLUX_ROOT/images.lock.nix"

if [[ ! -d "$FLUX_ROOT" ]]; then
  echo "cluster path does not exist: $FLUX_ROOT" >&2
  exit 1
fi

tmp_dir="$(mktemp -d)"
tmp_records_file="$tmp_dir/images.jsonl"
tmp_lock="$tmp_dir/images.lock.nix"
trap 'rm -rf "$tmp_dir" || true' EXIT

log() {
  printf '%s\n' "$*" >&2
}

retry_cmd() {
  local max_attempts="$1"
  shift

  local attempt=1
  while true; do
    if "$@"; then
      return 0
    fi

    if [[ "$attempt" -ge "$max_attempts" ]]; then
      return 1
    fi

    sleep $((attempt * 2))
    attempt=$((attempt + 1))
  done
}

extract_prefetch_hash() {
  local output="$1"
  local hash=""

  # Preferred path: nix-prefetch-docker JSON output.
  hash="$(printf '%s\n' "$output" | jq -r '.sha256 // .hash // empty' 2>/dev/null | head -n1 || true)"
  if [[ -n "$hash" && "$hash" != "null" ]]; then
    printf '%s\n' "$hash"
    return 0
  fi

  # Fallback for human-readable output: "-> ImageHash: ..."
  hash="$(printf '%s\n' "$output" | sed -n 's/.*ImageHash:[[:space:]]*\([^[:space:]]\+\).*/\1/p' | tail -n1)"
  if [[ -n "$hash" ]]; then
    printf '%s\n' "$hash"
    return 0
  fi

  # Fallback for Nix attrset output: sha256 = "...";
  hash="$(printf '%s\n' "$output" | sed -n 's/^[[:space:]]*sha256[[:space:]]*=[[:space:]]*"\([^"]\+\)".*/\1/p' | tail -n1)"
  if [[ -n "$hash" ]]; then
    printf '%s\n' "$hash"
    return 0
  fi

  return 1
}

log "[gen-image-lock] cluster=$CLUSTER root=$FLUX_ROOT"
log "[gen-image-lock] render: flux-local get cluster -> json"

flux_local_cmd=(
  uvx --from 'flux-local==8.2.0' flux-local get cluster
  --path "$FLUX_ROOT"
  -o json
  --enable-images
  --no-skip-secrets
)

if [[ "$INCLUDE_HELM" != "1" ]]; then
  flux_local_cmd+=(--skip-kinds HelmRelease)
fi

if ! flux_local_json="$(retry_cmd 4 "${flux_local_cmd[@]}")"; then
  if [[ "$INCLUDE_HELM" == "1" ]]; then
    log "[gen-image-lock] flux-local failed with HelmRelease; retrying with --skip-kinds HelmRelease"
    if ! flux_local_json="$(retry_cmd 4 uvx --from 'flux-local==8.2.0' flux-local get cluster --path "$FLUX_ROOT" -o json --enable-images --no-skip-secrets --skip-kinds HelmRelease)"; then
      echo "failed to render cluster images with flux-local for: $FLUX_ROOT" >&2
      exit 1
    fi
  else
    echo "failed to render cluster images with flux-local for: $FLUX_ROOT" >&2
    exit 1
  fi
fi

if [[ -n "$NAMESPACES_RAW" ]]; then
  IFS=' ' read -r -a namespaces <<< "$NAMESPACES_RAW"
else
  namespaces=()
fi

printf '%s\n' "$flux_local_json" | jq -c '
  def norm_ref:
    tostring
    | gsub("^[[:space:]]+|[[:space:]]+$"; "");

  # flux-local v8 emits a model under .clusters[].kustomizations[] where
  # image ownership context is explicit (kustomization / helm release).
  if (type == "object") and ((.clusters? | type) == "array") then
    .clusters[]? as $cluster
    | $cluster.kustomizations[]? as $k
    | (
        ($k.images[]?
          | {
              namespace: ($k.namespace // "default"),
              kind: "Kustomization",
              name: ($k.name // ""),
              imageRef: (. | norm_ref)
            }
        ),
        ($k.helm_releases[]? as $hr
          | $hr.images[]?
          | {
              namespace: ($hr.namespace // $k.namespace // "default"),
              kind: "HelmRelease",
              name: ($hr.name // ""),
              imageRef: (. | norm_ref)
            }
        )
      )
    | select(.imageRef != "" and .name != "")
  # Backward-compatible fallback for flat output modes.
  elif type == "string" then
    { namespace: "default", kind: "", name: "", imageRef: (. | norm_ref) }
  elif type == "array" then
    .[]
    | if type == "string" then
        { namespace: "default", kind: "", name: "", imageRef: (. | norm_ref) }
      else
        empty
      end
  else
    empty
  end
' >> "$tmp_records_file"

if [[ -n "$KUSTOMIZATIONS_RAW" || "$AUTO_DISCOVER" != "1" ]]; then
  log "[gen-image-lock] note: --kustomizations/--auto-discover are ignored in flux-local-only mode"
fi

if [[ "${#namespaces[@]}" -gt 0 ]]; then
  namespace_filter_json="$(printf '%s\n' "${namespaces[@]}" | jq -R . | jq -s .)"
  jq -c --argjson namespaces "$namespace_filter_json" '
    select(.namespace as $ns | $namespaces | index($ns))
  ' "$tmp_records_file" > "$tmp_records_file.filtered"
  mv "$tmp_records_file.filtered" "$tmp_records_file"
fi

if [[ ! -s "$tmp_records_file" ]]; then
  printf '[]\n' > "$OUT_LOCK_FILE"
  echo "Generated $OUT_LOCK_FILE"
  exit 0
fi

grouped_records="$(jq -s '
  sort_by(.imageRef)
  | group_by(.imageRef)
  | map({
      imageRef: .[0].imageRef,
      namespaces: ([.[].namespace] | unique),
      sources: ([.[] | {namespace, kind, name}] | unique | map(select(.kind != "" and .name != "")))
    })
' "$tmp_records_file")"

if [[ "$grouped_records" == "[]" ]]; then
  printf '[]\n' > "$OUT_LOCK_FILE"
  echo "Generated $OUT_LOCK_FILE"
  exit 0
fi

log "[gen-image-lock] render complete: $(printf '%s\n' "$grouped_records" | jq 'length') images"

CACHE_DIR="$HOME/.cache/nixos-image-lock/${ARCH}-${OS}"
mkdir -p "$CACHE_DIR"

total_images="$(printf '%s\n' "$grouped_records" | jq 'length')"

process_image() {
  local image_record="$1"
  local image_index="$2"
  
  if ! (
    image_ref="$(printf '%s\n' "$image_record" | jq -r '.imageRef')"
    namespaces_json="$(printf '%s\n' "$image_record" | jq -c '.namespaces')"
    sources_json="$(printf '%s\n' "$image_record" | jq -c '.sources')"

    log "[gen-image-lock] [$image_index/$total_images] resolve digest: $image_ref"

    image_name="$image_ref"
    tag="latest"
    if [[ "$image_ref" == *@sha256:* ]]; then
      image_name="${image_ref%%@sha256:*}"
    fi
    if [[ "$image_name" == *:* ]]; then
      tag="${image_name##*:}"
      image_name="${image_name%:*}"
    fi

    # Resolve digest from registry, then prefetch Nix hash for pullImage.
    if ! digest="$(retry_cmd 4 crane digest "$image_ref")"; then
      echo "failed to resolve digest for image: $image_ref" >&2
      exit 1
    fi

    hash=""
    safedigest="${digest/:/-}"
    safename="${image_name//[\/:]/_}"
    cache_file="$CACHE_DIR/${safename}-${safedigest}.txt"
    if [[ -f "$cache_file" ]]; then
      hash="$(cat "$cache_file")"
    fi

    if [[ -z "$hash" ]]; then
      log "[gen-image-lock] [$image_index/$total_images] digest ok: $digest, prefetching hash..."
      if ! prefetch_out="$(retry_cmd 4 nix-prefetch-docker --json --quiet --image-name "$image_name" --image-tag "$tag" --arch "$ARCH" --os "$OS" --image-digest "$digest" )"; then
        echo "failed to prefetch image hash for: $image_ref" >&2
        exit 1
      fi
      if ! hash="$(extract_prefetch_hash "$prefetch_out")"; then
        echo "failed to parse prefetch hash for: $image_ref" >&2
        echo "$prefetch_out" >&2
        exit 1
      fi
      echo "$hash" > "$cache_file"
      log "[gen-image-lock] [$image_index/$total_images] prefetch ok: $hash"
    else
      log "[gen-image-lock] [$image_index/$total_images] cache hit ok: $hash"
    fi

    {
      echo "  {"
      echo "    imageName = \"$image_name\";"
      echo "    imageDigest = \"$digest\";"
      echo "    finalImageName = \"$image_name\";"
      echo "    finalImageTag = \"$tag\";"
      echo "    hash = \"$hash\";"
      echo "    os = \"$OS\";"
      echo "    arch = \"$ARCH\";"
      echo "    namespaces = ["
      printf '%s\n' "$namespaces_json" | jq -r '.[]' | while IFS= read -r namespace; do
        echo "      \"$namespace\";"
      done
      echo "    ];"
      echo "    sources = ["
      printf '%s\n' "$sources_json" | jq -c '.[]' | while IFS= read -r source; do
        source_namespace="$(printf '%s\n' "$source" | jq -r '.namespace')"
        source_kind="$(printf '%s\n' "$source" | jq -r '.kind')"
        source_name="$(printf '%s\n' "$source" | jq -r '.name')"
        echo "      {"
        echo "        namespace = \"$source_namespace\";"
        echo "        kind = \"$source_kind\";"
        echo "        name = \"$source_name\";"
        echo "      }"
      done
      echo "    ];"
      echo "  }"
    } > "$tmp_dir/block_$image_index.nix"
  ); then
    touch "$tmp_dir/err_$image_index.failed"
    exit 1
  fi
}

image_index=0
active_jobs=0
max_jobs=16

while IFS= read -r image_record; do
  [[ -n "$image_record" ]] || continue
  image_index=$((image_index + 1))
  
  process_image "$image_record" "$image_index" &
  active_jobs=$((active_jobs + 1))

  if [[ "$active_jobs" -ge "$max_jobs" ]]; then
    wait -n || true
    active_jobs=$((active_jobs - 1))
  fi
done < <(printf '%s\n' "$grouped_records" | jq -c '.[]')

wait

if ls "$tmp_dir"/err_*.failed >/dev/null 2>&1; then
  echo "gen-image-lock: one or more jobs failed in parallel execution" >&2
  exit 1
fi

{
  echo "["
  for ((i=1; i<=total_images; i++)); do
    if [[ -f "$tmp_dir/block_$i.nix" ]]; then
      cat "$tmp_dir/block_$i.nix"
    fi
  done
  echo "]"
} > "$tmp_lock"

mkdir -p "$(dirname "$OUT_LOCK_FILE")"
mv "$tmp_lock" "$OUT_LOCK_FILE"
log "[gen-image-lock] wrote $OUT_LOCK_FILE"
echo "Generated $OUT_LOCK_FILE"