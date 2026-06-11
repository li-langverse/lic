#!/usr/bin/env bash
# Phase 1: li-oci pure format layer (no Container effect).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
bash "$ROOT/scripts/container-separate-repos-phase0-gate.sh"

test -f "$ROOT/packages/li-oci/src/spec.li"
test -f "$ROOT/packages/li-oci/src/image.li"
grep -q 'github_repo = "li-oci"' "$ROOT/packages/li-oci/li.toml"
grep -q 'import_name = "oci"' "$ROOT/packages/li-oci/li.toml"

echo "container-separate-repos phase1 gate: OK"
