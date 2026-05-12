{
  pkgs,
  sourceImages,
  finalImageName,
  finalImageTag ? "latest",
  imageDigest,
  archiveHash,
  mirrorRetries ? 3,
}:
let
  lib = pkgs.lib;
  safeName = lib.replaceStrings [ "/" ":" "@" ] [ "-" "-" "-" ] finalImageName;
  safeTag = lib.replaceStrings [ "/" ":" ] [ "-" "-" ] finalImageTag;
  safeDigest = lib.replaceStrings [ ":" ] [ "-" ] imageDigest;
in
pkgs.runCommand "${safeName}-${safeTag}-${safeDigest}.tar"
  {
    outputHashMode = "flat";
    outputHashAlgo = null;
    outputHash = archiveHash;
    nativeBuildInputs = [
      pkgs.skopeo
      pkgs.gnutar
      pkgs.jq
    ];
  }
  ''
    success=0
    repackDir="$TMPDIR/repack-dir"
    ociArchive="$TMPDIR/image-oci-archive.tar"

    for sourceImage in ${lib.concatStringsSep " " (map lib.escapeShellArg sourceImages)}; do
      inspectErrFile="$TMPDIR/skopeo-inspect-err.log"
      inspectRaw=""
      inspectStd=""
      mediaType=""
      if inspectRaw="$(skopeo inspect --raw "docker://$sourceImage@${imageDigest}" 2>"$inspectErrFile")"; then
        mediaType="$(printf '%s' "$inspectRaw" | jq -r '.mediaType // empty' || true)"
      fi
      if [ -z "$mediaType" ]; then
        if inspectStd="$(skopeo inspect "docker://$sourceImage@${imageDigest}" 2>>"$inspectErrFile")"; then
          mediaType="$(printf '%s' "$inspectStd" | jq -r '.MediaType // empty' || true)"
        fi
      fi

      formatCandidates=""
      case "$mediaType" in
        application/vnd.oci.image.index.v1+json|application/vnd.oci.image.manifest.v1+json)
          formatCandidates="oci v2s2 v2s1"
          echo "[mkMultiArchImageArchive] detected mediaType=$mediaType source=docker://$sourceImage@${imageDigest} selectedFormats='$formatCandidates'" >&2
          ;;
        application/vnd.docker.distribution.manifest.list.v2+json|application/vnd.docker.distribution.manifest.v2+json)
          formatCandidates="v2s2 oci v2s1"
          echo "[mkMultiArchImageArchive] detected mediaType=$mediaType source=docker://$sourceImage@${imageDigest} selectedFormats='$formatCandidates'" >&2
          ;;
        application/vnd.docker.distribution.manifest.v1+json|application/vnd.docker.distribution.manifest.v1+prettyjws)
          formatCandidates="v2s1 v2s2 oci"
          echo "[mkMultiArchImageArchive] detected mediaType=$mediaType source=docker://$sourceImage@${imageDigest} selectedFormats='$formatCandidates'" >&2
          ;;
        *)
          inspectError="$(tr '\n' ' ' < "$inspectErrFile")"
          formatCandidates="v2s2 oci v2s1"
          echo "[mkMultiArchImageArchive] unknown mediaType='${mediaType:-empty}' source=docker://$sourceImage@${imageDigest} err='$inspectError' selectedFormats='$formatCandidates'" >&2
          ;;
      esac

      for manifestFormat in $formatCandidates; do
        archivePath="$ociArchive"
        dest="oci-archive:$archivePath:${finalImageName}:${finalImageTag}"

        attempt=1
        while [ "$attempt" -le ${toString mirrorRetries} ]; do
          rm -rf "$repackDir"
          rm -f "$ociArchive"

          echo "[mkMultiArchImageArchive] skopeo copy attempt=$attempt/${toString mirrorRetries} source=docker://$sourceImage@${imageDigest} mediaType=${mediaType:-unknown} format=$manifestFormat dest=$dest flags=--insecure-policy --multi-arch all --preserve-digests" >&2
          if skopeo --tmpdir "$TMPDIR" copy --insecure-policy --multi-arch all --preserve-digests --format "$manifestFormat" \
            "docker://$sourceImage@${imageDigest}" \
            "$dest"; then
            mkdir -p "$repackDir"
            tar -xf "$archivePath" -C "$repackDir"
            success=1
            break
          fi

          attempt=$((attempt + 1))
        done

        if [ "$success" -eq 1 ]; then
          break
        fi
      done

      if [ "$success" -eq 1 ]; then
        break
      fi
    done

    if [ "$success" -ne 1 ]; then
      echo "Failed to fetch ${finalImageName}@${imageDigest} from all sources after retries." >&2
      exit 1
    fi

    tar \
      --create \
      --file="$out" \
      --owner=0 \
      --group=0 \
      --numeric-owner \
      --format=gnu \
      --sort=name \
      --mtime="@$SOURCE_DATE_EPOCH" \
      -C "$repackDir" \
      .
  ''
