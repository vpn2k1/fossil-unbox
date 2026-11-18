#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
: "${SYMBOL_DIR:?Chọn thư mục riêng để lưu symbol của build này}"
case "${1:-}" in appbundle|ipa) target=$1;; *) echo 'Chọn appbundle hoặc ipa';exit 2;; esac
flutter build "$target" --release --obfuscate --split-debug-info="$SYMBOL_DIR"
