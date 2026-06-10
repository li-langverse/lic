#!/usr/bin/env bash
# Phase 7: publish metadata + gap register updated.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
bash "$ROOT/scripts/container-separate-repos-phase6-gate.sh"

grep -q 'li-oci' "$ROOT/docs/libernetes/package-gap-register.md"
grep -q 'li-container' "$ROOT/docs/libernetes/package-gap-register.md"

for pkg in li-oci li-container li-container-run; do
  grep -q 'github_repo' "$ROOT/packages/$pkg/li.toml"
  test -f "$ROOT/packages/$pkg/PUBLISH.md"
done

echo "container-separate-repos phase7 gate: OK"
