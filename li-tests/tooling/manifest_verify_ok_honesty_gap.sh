#!/usr/bin/env bash
# G-test-verify: manifest outcome verify_ok runs lic build only (no --strict-lean);
# True-stub certificates (index_refinement) pass verify_ok AND --strict-lean — outcome name overclaims proof.
# Passes while the gap is open; fails when prove_lean_ok lands or verify_ok gains --strict-lean.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
RUN_ALL="$ROOT/li-tests/run_all.sh"
MANIFEST="$ROOT/li-tests/manifest.toml"
STUB="$ROOT/li-tests/contracts_verify/index_refinement.li"
OPEN_STUB="$ROOT/li-tests/contracts_verify/sqrt_open_bound.li"
AUTOVC="$ROOT/build/generated/AutoVC.lean"

# run_all verify_ok must map to plain lic build (no --strict-lean).
if ! grep -q 'compile_ok|verify_ok)' "$RUN_ALL"; then
  echo "manifest_verify_ok_honesty_gap: expected verify_ok branch in run_all.sh"
  exit 1
fi
if grep -A6 'compile_ok|verify_ok)' "$RUN_ALL" | grep -q 'strict-lean'; then
  echo "manifest_verify_ok_honesty_gap: verify_ok now passes --strict-lean — update script (gap may be closed)"
  exit 1
fi

# prove_lean_ok outcome not wired yet (proof-corpus-roadmap G-test-verify).
if grep -q 'prove_lean_ok' "$MANIFEST"; then
  echo "manifest_verify_ok_honesty_gap: prove_lean_ok found in manifest — update script for split outcomes"
  exit 1
fi
if ! grep -A2 'index_refinement.li' "$MANIFEST" | grep -q 'verify_ok'; then
  echo "manifest_verify_ok_honesty_gap: index_refinement.li must stay verify_ok until P-refine closes"
  exit 1
fi
if ! grep -A2 'sqrt_open_bound.li' "$MANIFEST" | grep -q 'verify_open_ok'; then
  echo "manifest_verify_ok_honesty_gap: sqrt_open_bound.li must stay verify_open_ok (open VC tier)"
  exit 1
fi

# verify_ok path: plain lic build passes for True-stub refinement specimen.
if ! "$LIC" build "$STUB" -o /dev/null 2>/dev/null; then
  echo "manifest_verify_ok_honesty_gap: index_refinement must pass lic build (verify_ok path)"
  exit 1
fi
test -f "$AUTOVC"
if ! grep -q 'def vc_get_requires_0 (a : LiArray Int 10) (i : Int) : Prop := True' "$AUTOVC"; then
  echo "manifest_verify_ok_honesty_gap: expected True stub vc_get_requires_0 — P-refine may have closed"
  exit 1
fi

# --strict-lean also passes today (trivial proofs on True Props) — semantic gap not caught by strict flag alone.
if ! "$LIC" build "$STUB" -o /dev/null --strict-lean 2>/dev/null; then
  echo "manifest_verify_ok_honesty_gap: index_refinement unexpectedly fails --strict-lean"
  exit 1
fi

# Open VC specimen must not be verify_ok (build fails without downgrade).
if "$LIC" build "$OPEN_STUB" -o /dev/null 2>/dev/null; then
  echo "manifest_verify_ok_honesty_gap: sqrt_open_bound must fail default lic build (open VC)"
  exit 1
fi

echo "manifest_verify_ok_honesty_gap: ok (documented G-test-verify manifest honesty hole)"
