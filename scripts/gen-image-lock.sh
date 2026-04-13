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

  hash="$(printf '%s\n' "$output" | jq -r '.sha256 // .hash // empty' 2>/dev/null | head -n1 || true)"
  if [[ -n "$hash" && "$hash" != "null" ]]; then
    printf '%s\n' "$hash"
    return 0
  fi

  return 1
}

log "[gen-image-lock] cluster=$CLUSTER root=$FLUX_ROOT"

# Step 1: Get cluster metadata (HelmReleases, Kustomizations, images lists) for source info
log "[gen-image-lock] step 1: fetch cluster metadata (sources)"
cluster_cmd=(
  uvx --from 'flux-local==8.2.0' flux-local get cluster
  --path "$FLUX_ROOT"
  --enable-images
  -o json
)

if ! cluster_metadata="$(retry_cmd 4 "${cluster_cmd[@]}")"; then
  echo "failed to fetch cluster metadata for: $FLUX_ROOT" >&2
  exit 1
fi

# Step 2: Render all manifests (Deployments, Pods, etc.) for target info
log "[gen-image-lock] step 2: render manifests (targets)"
build_cmd=(
  uvx --from 'flux-local==8.2.0' flux-local build all
  --enable-helm
  "$FLUX_ROOT"
)

if ! rendered_manifests="$(retry_cmd 4 "${build_cmd[@]}")"; then
  echo "failed to render cluster manifests for: $FLUX_ROOT" >&2
  exit 1
fi

if [[ -n "$NAMESPACES_RAW" ]]; then
  IFS=' ' read -r -a namespaces <<< "$NAMESPACES_RAW"
else
  namespaces=()
fi

# Step 3: Extract sources from cluster metadata
tmp_sources_file="$tmp_dir/sources.jsonl"
printf '%s\n' "$cluster_metadata" | jq -c '
  def norm_ref: tostring | gsub("^[[:space:]]+|[[:space:]]+$"; "");

  def parent_kustomizations($ks; $path):
    [
      $ks[]?
      | select(.path != $path)
      | .path as $parent_path
      | select($path | startswith($parent_path + "/"))
      | {
          kind: "Kustomization",
          namespace: (.namespace // "default"),
          name: (.name // ""),
          path: (.path // "")
        }
    ]
    | sort_by(.path | length)
    | reverse
    | map(del(.path));

  def direct_source($kind; $namespace; $name):
    {
      kind: $kind,
      namespace: ($namespace // "default"),
      name: ($name // "")
    };

  # Keep the original stable traversal: cluster -> kustomization -> images/helm releases.
  if (type == "object") and ((.clusters? | type) == "array") then
    .clusters[]? as $cluster
    | ($cluster.kustomizations // [ ]) as $kustomizations
    | $kustomizations[]? as $k
    | (
        ($k.images[]? | norm_ref as $img |
          {
            image: $img,
            source: direct_source("Kustomization"; $k.namespace; $k.name),
            sourceChains: [ [ direct_source("Kustomization"; $k.namespace; $k.name) ] + parent_kustomizations($kustomizations; ($k.path // "")) ]
          }
        ),
        ($k.helm_releases[]? as $hr
          | $hr.images[]? | norm_ref as $img |
          {
            image: $img,
            source: direct_source("HelmRelease"; ($hr.namespace // $k.namespace); $hr.name),
            sourceChains: [
              [
                direct_source("HelmRelease"; ($hr.namespace // $k.namespace); $hr.name),
                direct_source("Kustomization"; $k.namespace; $k.name)
              ] + parent_kustomizations($kustomizations; ($k.path // ""))
            ]
          }
        )
      )
    | select(.image != "" and .source.name != "")
  else
    empty
  end
' > "$tmp_sources_file"

# Step 4: Extract targets from rendered manifests
tmp_targets_file="$tmp_dir/targets.jsonl"
# flux-local build all outputs multi-document YAML; convert to JSON array first.
printf '%s\n' "$rendered_manifests" | yq -o=json '.' | jq -cs '.' | jq -c '
  def norm_ref: tostring | gsub("^[[:space:]]+|[[:space:]]+$"; "");

  def extract_images_from_object:
    .metadata.namespace as $ns
    | .metadata.name as $obj_name
    | .kind as $obj_kind
    | [
        .spec.containers[]?.image,
        .spec.initContainers[]?.image,
        .spec.ephemeralContainers[]?.image,
        .spec.template?.spec?.containers[]?.image,
        .spec.template?.spec?.initContainers[]?.image,
        .spec.template?.spec?.ephemeralContainers[]?.image,
        .spec.jobTemplate?.spec?.template?.spec?.containers[]?.image,
        .spec.jobTemplate?.spec?.template?.spec?.initContainers[]?.image,
        .spec.jobTemplate?.spec?.template?.spec?.ephemeralContainers[]?.image
      ]
    | map(select(. != null and . != ""))
    | .[] | {
        image: (. | norm_ref),
        target_kind: $obj_kind,
        target_namespace: ($ns // "default"),
        target_name: $obj_name
      };

  if type == "array" then
    .[]
    | select(
        (.kind == "Deployment" or .kind == "StatefulSet" or .kind == "DaemonSet" 
          or .kind == "Job" or .kind == "CronJob" or .kind == "Pod" 
          or .kind == "ReplicaSet" or .kind == "ReplicationController")
        and (.metadata.namespace // false)
      )
    | extract_images_from_object
  else empty end
' > "$tmp_targets_file"

# Step 5: Join sources and targets by image reference
tmp_joined_file="$tmp_dir/joined.json"
jq -n \
  --slurpfile sources "$tmp_sources_file" \
  --slurpfile targets "$tmp_targets_file" \
  '
  reduce $sources[] as $s ({}; 
    .[$s.image] |= . + [{
      kind: $s.source.kind,
      namespace: $s.source.namespace,
      name: $s.source.name
    }]
  ) as $source_map
  |
  reduce $sources[] as $s ({};
    .[$s.image] |= . + $s.sourceChains
  ) as $chain_map
  |
  reduce $targets[] as $t ({}; 
    .[$t.image] |= . + [{
      kind: $t.target_kind,
      namespace: $t.target_namespace,
      name: $t.target_name
    }]
  ) as $target_map
  |
  ([$source_map, $target_map] | add | keys[]) as $image
  | {
      image: $image,
      sources: ($source_map[$image] // []),
      sourceChains: ($chain_map[$image] // []),
      targets: ($target_map[$image] // [])
    }
  ' > "$tmp_joined_file"

jq -c '.' "$tmp_joined_file" >> "$tmp_records_file"

# Apply namespace filter if specified
if [[ "${#namespaces[@]}" -gt 0 ]]; then
  namespace_filter_json="$(printf '%s\n' "${namespaces[@]}" | jq -R . | jq -s .)"
  jq -c --argjson namespaces "$namespace_filter_json" '
    select(
      ((.sources[]? | .namespace) as $s | $namespaces | index($s)) or
      ((.targets[]? | .namespace) as $t | $namespaces | index($t))
    )
  ' "$tmp_records_file" > "$tmp_records_file.filtered"
  mv "$tmp_records_file.filtered" "$tmp_records_file"
fi

if [[ ! -s "$tmp_records_file" ]]; then
  printf '[]\n' > "$OUT_LOCK_FILE"
  echo "Generated $OUT_LOCK_FILE"
  exit 0
fi

grouped_records="$(jq -s '
  group_by(.image)
  | map({
      image: .[0].image,
      sources: ([.[].sources[]? ] | unique),
      sourceChains: ([.[].sourceChains[]? ] | unique),
      targets: ([.[].targets[]? ] | unique)
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

PREFETCH_TOOL_SIG="$({ nix-prefetch-docker --version 2>/dev/null || echo unknown; } | tr -cs '[:alnum:]._-' '_' | cut -c1-80)"

total_images="$(printf '%s\n' "$grouped_records" | jq 'length')"

process_image() {
  local image_record="$1"
  local image_index="$2"
  
  if ! (
    image="$(printf '%s\n' "$image_record" | jq -r '.image')"
    sources_json="$(printf '%s\n' "$image_record" | jq -c '.sources')"
    source_chains_json="$(printf '%s\n' "$image_record" | jq -c '.sourceChains')"
    targets_json="$(printf '%s\n' "$image_record" | jq -c '.targets')"

    log "[gen-image-lock] [$image_index/$total_images] resolve digest: $image"

    image_name="$image"
    tag="latest"
    if [[ "$image" == *@sha256:* ]]; then
      image_name="${image%%@sha256:*}"
    fi
    if [[ "$image_name" == *:* ]]; then
      tag="${image_name##*:}"
      image_name="${image_name%:*}"
    fi

    if ! digest="$(retry_cmd 4 crane digest "$image")"; then
      echo "failed to resolve digest for image: $image" >&2
      exit 1
    fi

    hash=""
    safedigest="${digest/:/-}"
    safename="${image_name//[\/:]/_}"
    cache_file="$CACHE_DIR/${safename}-${safedigest}-${PREFETCH_TOOL_SIG}.txt"
    if [[ -f "$cache_file" ]]; then
      hash="$(cat "$cache_file")"
    fi

    if [[ -z "$hash" ]]; then
      log "[gen-image-lock] [$image_index/$total_images] digest ok: $digest, prefetching hash..."
      if ! prefetch_out="$(retry_cmd 4 nix-prefetch-docker --json --quiet --image-name "$image_name" --image-tag "$tag" --arch "$ARCH" --os "$OS" --image-digest "$digest" )"; then
        echo "failed to prefetch image hash for: $image" >&2
        exit 1
      fi
      if ! hash="$(extract_prefetch_hash "$prefetch_out")"; then
        echo "failed to parse prefetch hash for: $image" >&2
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
      echo "    sources = ["
      printf '%s\n' "$sources_json" | jq -c '.[]' | while IFS= read -r source; do
        s_kind="$(printf '%s\n' "$source" | jq -r '.kind')"
        s_ns="$(printf '%s\n' "$source" | jq -r '.namespace')"
        s_name="$(printf '%s\n' "$source" | jq -r '.name')"
        echo "      {"
        echo "        kind = \"$s_kind\";"
        echo "        namespace = \"$s_ns\";"
        echo "        name = \"$s_name\";"
        echo "      }"
      done
      echo "    ];"
      echo "    sourceChains = ["
      printf '%s\n' "$source_chains_json" | jq -c '.[]' | while IFS= read -r chain; do
        echo "      ["
        printf '%s\n' "$chain" | jq -c '.[]' | while IFS= read -r source; do
          c_kind="$(printf '%s\n' "$source" | jq -r '.kind')"
          c_ns="$(printf '%s\n' "$source" | jq -r '.namespace')"
          c_name="$(printf '%s\n' "$source" | jq -r '.name')"
          echo "        {"
          echo "          kind = \"$c_kind\";"
          echo "          namespace = \"$c_ns\";"
          echo "          name = \"$c_name\";"
          echo "        }"
        done
        echo "      ]"
      done
      echo "    ];"
      echo "    targets = ["
      printf '%s\n' "$targets_json" | jq -c '.[]' | while IFS= read -r target; do
        t_kind="$(printf '%s\n' "$target" | jq -r '.kind')"
        t_ns="$(printf '%s\n' "$target" | jq -r '.namespace')"
        t_name="$(printf '%s\n' "$target" | jq -r '.name')"
        echo "      {"
        echo "        kind = \"$t_kind\";"
        echo "        namespace = \"$t_ns\";"
        echo "        name = \"$t_name\";"
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
