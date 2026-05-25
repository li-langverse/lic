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

# lip@main pkg_ok fixture may still use proc; lic requires def (see lip#10).
fix_pkg_ok_def_syntax() {
  local d="$ROOT/../lip/fixtures/pkg_ok"
  [[ -d "$d" ]] || return 0
  local f
  for f in "$d/src/lib.li" "$d"/li-tests/smoke/*.li; do
    [[ -f "$f" ]] || continue
    sed 's/^proc /def /g' "$f" > "${f}.tmp" && mv "${f}.tmp" "$f"
  done
}
fix_pkg_ok_def_syntax

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
