#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
# Generate native shells in isolation so Flutter templates cannot replace the game.
tempdir=$(mktemp -d)
trap 'rm -rf "$tempdir"' EXIT
flutter create --no-pub --platforms=android,ios --org dev.fossilworkshop --project-name fossil_unbox "$tempdir/fossil_unbox"
for platform in android ios; do
  if [[ ! -e "$platform" ]]; then cp -R "$tempdir/fossil_unbox/$platform" .; fi
done
flutter pub get
