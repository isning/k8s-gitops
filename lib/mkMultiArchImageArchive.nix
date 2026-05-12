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
    dockerArchive="$TMPDIR/image-docker-archive.tar"
    ociArchive="$TMPDIR/image-oci-archive.tar"

    for sourceImage in ${lib.concatStringsSep " " (map lib.escapeShellArg sourceImages)}; do
      inspectErrFile="$TMPDIR/skopeo-inspect-err.log"
      inspectRaw=""
      inspectError=""
      if inspectRaw="$(skopeo inspect --raw "docker://$sourceImage@${imageDigest}" 2>"$inspectErrFile")"; then
        mediaType="$(printf '%s' "$inspectRaw" | jq -r '.mediaType // empty' || true)"
      else
        mediaType=""
        inspectError="$(tr '\n' ' ' < "$inspectErrFile")"
      fi
      transportCandidates=""
      case "$mediaType" in
        application/vnd.oci.image.index.v1+json|application/vnd.oci.image.manifest.v1+json)
          transportCandidates="oci-archive docker-archive"
          ;;
        application/vnd.docker.distribution.manifest.list.v2+json|application/vnd.docker.distribution.manifest.v2+json)
          transportCandidates="docker-archive oci-archive"
          ;;
        "")
          if [ -n "$inspectError" ]; then
            case "$inspectError" in
              *"TLS handshake timeout"*|*"context deadline exceeded"*|*"i/o timeout"*|*"connection refused"*|*"connection reset"*|*"Temporary failure in name resolution"*|*"no such host"*|*"EOF"*)
                echo "[mkMultiArchImageArchive] mediaType inspect failed due to network/transport issue for docker://$sourceImage@${imageDigest}; err='$inspectError'; falling back to transport probing" >&2
                ;;
              *)
                echo "[mkMultiArchImageArchive] mediaType inspect failed for docker://$sourceImage@${imageDigest}; err='$inspectError'; falling back to transport probing" >&2
                ;;
            esac
          else
            echo "[mkMultiArchImageArchive] unable to inspect mediaType for docker://$sourceImage@${imageDigest}, falling back to transport probing" >&2
          fi
          transportCandidates="oci-archive docker-archive"
          ;;
        *)
          echo "[mkMultiArchImageArchive] unsupported mediaType=$mediaType for docker://$sourceImage@${imageDigest}, falling back to transport probing" >&2
          transportCandidates="oci-archive docker-archive"
          ;;
      esac

      for transport in $transportCandidates; do
        case "$transport" in
          oci-archive)
            archivePath="$ociArchive"
            dest="oci-archive:$archivePath:${finalImageName}:${finalImageTag}"
            ;;
          docker-archive)
            archivePath="$dockerArchive"
            dest="docker-archive:$archivePath:${finalImageName}:${finalImageTag}"
            ;;
        esac

        attempt=1
        while [ "$attempt" -le ${toString mirrorRetries} ]; do
          rm -rf "$repackDir"
          rm -f "$dockerArchive" "$ociArchive"

          echo "[mkMultiArchImageArchive] skopeo copy attempt=$attempt/${toString mirrorRetries} source=docker://$sourceImage@${imageDigest} mediaType=${mediaType:-unknown} transport=$transport dest=$dest flags=--insecure-policy --multi-arch all --preserve-digests" >&2
          if skopeo --tmpdir "$TMPDIR" copy --insecure-policy --multi-arch all --preserve-digests \
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
