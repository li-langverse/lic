#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
[[ -x "$LIC" ]] || { echo "resource_flags_smoke: skip (no lic)" >&2; exit 0; }
SAMPLE="$ROOT/li-tests/modules/greeter/greeter.li"
BUILD_DIR="$ROOT/build/li-test-resource-smoke-$$"
trap 'rm -rf "$BUILD_DIR"' EXIT
mkdir -p "$BUILD_DIR/generated"

"$LIC" build "$SAMPLE" -o /dev/null --build-dir="$BUILD_DIR" 2>/dev/null
[[ -f "$BUILD_DIR/generated/AutoVC.lean" ]]

warn_file="$(mktemp)"
export LI_COMPILE_JOBS=99
"$LIC" build "$SAMPLE" -o /dev/null --jobs=2 2>"$warn_file" >/dev/null
grep -q 'LI_COMPILE_JOBS' "$warn_file"

note_file="$(mktemp)"
"$LIC" build "$SAMPLE" -o /dev/null --jobs=2 2>"$note_file" >/dev/null
grep -q 'Phase 8p-c' "$note_file"
echo "resource_flags_smoke: ok"
