#!/usr/bin/env bash
# G-test-verify: manifest verify_ok only runs `lic build` (run_all.sh) — not discharge_linalg_int_lean.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RUN_ALL="$ROOT/li-tests/run_all.sh"
if ! grep -q 'compile_ok|verify_ok)' "$RUN_ALL"; then
  echo "verify_ok_manifest_tier_gap: run_all.sh verify_ok branch missing"
  exit 1
fi
if grep -A6 'compile_ok|verify_ok)' "$RUN_ALL" | grep -q 'discharge_linalg'; then
  echo "verify_ok_manifest_tier_gap: unexpected discharge_linalg in verify_ok path"
  exit 1
fi
if ! test -x "$ROOT/li-tests/tooling/discharge_linalg_int_lean.sh"; then
  echo "verify_ok_manifest_tier_gap: discharge_linalg_int_lean.sh missing"
  exit 1
fi
# Corpus scripts are separate from per-file verify_ok (proof-corpus-roadmap.md).
echo "verify_ok_manifest_tier_gap: ok (verify_ok = lic build only; P-linalg discharge is tooling/)"
