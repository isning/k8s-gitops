{
  pkgs,
  sourceImages,
  finalImageName,
  finalImageTag ? "latest",
  imageDigest,
  archiveHash ? null,
  mirrorRetries ? 3,
}:
let
  lib = pkgs.lib;
  safeName = lib.replaceStrings [ "/" ":" "@" ] [ "-" "-" "-" ] finalImageName;
  safeTag = lib.replaceStrings [ "/" ":" ] [ "-" "-" ] finalImageTag;
  safeDigest = lib.replaceStrings [ ":" ] [ "-" ] imageDigest;
in
pkgs.runCommand "${safeName}-${safeTag}-${safeDigest}.tar"
  ({
    nativeBuildInputs = [
      pkgs.skopeo
    ];
  }
  // lib.optionalAttrs (archiveHash != null) {
    outputHashMode = "flat";
    outputHashAlgo = null;
    outputHash = archiveHash;
  })
  ''
    success=0
    for sourceImage in ${lib.concatStringsSep " " (map lib.escapeShellArg sourceImages)}; do
      attempt=1
      while [ "$attempt" -le ${toString mirrorRetries} ]; do
        if skopeo --tmpdir "$TMPDIR" copy --insecure-policy --multi-arch all \
          "docker://$sourceImage@${imageDigest}" \
          "oci-archive:$out:${finalImageName}:${finalImageTag}"; then
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
  ''
