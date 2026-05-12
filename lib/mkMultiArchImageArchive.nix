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
    ];
  }
  ''
    success=0
    imageDir="$TMPDIR/image-dir"

    for sourceImage in ${lib.concatStringsSep " " (map lib.escapeShellArg sourceImages)}; do
      attempt=1
      while [ "$attempt" -le ${toString mirrorRetries} ]; do
        rm -rf "$imageDir"
        echo "[mkMultiArchImageArchive] skopeo copy attempt=$attempt/${toString mirrorRetries} source=docker://$sourceImage@${imageDigest} dest=dir:$imageDir flags=--insecure-policy --multi-arch all --preserve-digests" >&2
        if skopeo --tmpdir "$TMPDIR" copy --insecure-policy --multi-arch all --preserve-digests \
          "docker://$sourceImage@${imageDigest}" \
          "dir:$imageDir"; then
          success=1
          break
        fi
        attempt=$((attempt + 1))
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
      -C "$imageDir" \
      .
  ''
