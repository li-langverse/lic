#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
chmod +x "$ROOT/scripts/lip" "$ROOT/scripts/lit"
"$ROOT/scripts/lip" --version | grep -q stub
"$ROOT/scripts/lit" --version | grep -q stub
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
"$ROOT/scripts/lip" init li-lip-smoke --kind library --out "$TMP/li-lip-smoke"
test -f "$TMP/li-lip-smoke/li.toml"
"$ROOT/scripts/lit" test math_syntax >/dev/null
"$ROOT/scripts/lip" lock --out "$TMP/li.lock"
grep -q proof_digest "$TMP/li.lock"
echo "lip_lit_smoke: ok"
