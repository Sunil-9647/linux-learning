#!/usr/bin/env bash
set -e

ARTIFACT_DIR="ci-artifacts"

# clean old artifacts (VERY IMPORTANT)
rm -rf "$ARTIFACT_DIR"
mkdir -p "$ARTIFACT_DIR"

ZIP_NAME="app-build-${GITHUB_SHA}.zip"

echo "Packaging started..."
zip -r "$ARTIFACT_DIR/$ZIP_NAME" dist
echo "Packaging completed: $ARTIFACT_DIR/$ZIP_NAME"

ls -la "$ARTIFACT_DIR"

