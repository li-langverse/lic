#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LIC="${LIC:-$ROOT/build/compiler/lic/lic}"
export LI_REPO_ROOT="$ROOT"

LIP="$ROOT/scripts/lip"
LIT="$ROOT/scripts/lit"
if [[ -x "$ROOT/../lip/scripts/lip" ]]; then
  LIP="$ROOT/../lip/scripts/lip"
fi
if [[ -x "$ROOT/../lit/scripts/lit" ]]; then
  LIT="$ROOT/../lit/scripts/lit"
fi
chmod +x "$LIP" "$LIT"

"$LIP" --version
"$LIT" --version

if [[ -d "$ROOT/../lip/fixtures/pkg_ok" ]]; then
  (cd "$ROOT/../lip/fixtures/pkg_ok" && "$LIT" test --coverage)
  (cd "$ROOT/../lip/fixtures/pkg_ok" && "$LIP" publish --dry-run)
else
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  "$LIP" init li-lip-smoke --kind library --out "$TMP/li-lip-smoke"
  test -f "$TMP/li-lip-smoke/li.toml"
  "$LIT" test modules >/dev/null
  "$LIP" lock --out "$TMP/li.lock"
  grep -q proof_digest "$TMP/li.lock"
fi
echo "lip_lit_smoke: ok"
