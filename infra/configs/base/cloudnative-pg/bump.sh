#!/usr/bin/env bash
set -e

# --- Configuration ---
REMOTE_REPO="https://github.com/cloudnative-pg/artifacts"
SOURCE_SUBDIR="image-catalogs"
TARGET_DIR="official-image-catalogs"
TEMP_DIR=".temp_sync_$(date +%s)"

# 1. Clone remote repository
echo "Cloning remote repository..."
rm -rf "$TEMP_DIR"
git clone --depth 1 "$REMOTE_REPO" "$TEMP_DIR" --quiet

# 2. Extract metadata
pushd "$TEMP_DIR" > /dev/null
LATEST_SHA=$(git rev-parse --short HEAD)
COMMIT_MSG_RAW=$(git log -1 --format=%s)
COMMIT_DATE=$(git log -1 --format=%cd --date=format:'%Y-%m-%d %H:%M')
popd > /dev/null

# 3. Update local files
echo "Updating local artifacts..."
mkdir -p "$TARGET_DIR"

# Copy Legal files silently (only if they exist)
cp "$TEMP_DIR/LICENSE" "$TARGET_DIR/" 2>/dev/null
# cp "$TEMP_DIR/NOTICE" "$TARGET_DIR/" 2>/dev/null

# Copy content (files only from the specific subdir)
cp -r "$TEMP_DIR/$SOURCE_SUBDIR/." "$TARGET_DIR/"

# 4. Commit changes
echo "Committing changes..."
git add "$TARGET_DIR"

COMMIT_MSG="chore: sync from cnpg/artifacts@$LATEST_SHA

Origin-Repo: $REMOTE_REPO
Origin-Commit: $LATEST_SHA
Origin-Date: $COMMIT_DATE
Origin-Msg: $COMMIT_MSG_RAW"

if git diff-index --quiet HEAD --; then
    echo "No changes detected. Skipping commit."
else
    git commit -m "$COMMIT_MSG"
    echo "Sync completed successfully."
fi

# 5. Cleanup
rm -rf "$TEMP_DIR"