#!/usr/bin/env bash
# contracts_verify + Lean lake (2f); strict open-goal check optional.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
SAMPLE="$ROOT/li-tests/contracts_verify/sqrt_contract.li"
"$LIC" verify "$SAMPLE" 2>&1 | grep -q 'mir_fns='
rm -f "$ROOT/build/generated/AutoVC.lean"
LI_BUILD_VERIFY_LEAN=1 "$LIC" build "$SAMPLE" -o /dev/null
if command -v lake >/dev/null 2>&1; then
  (cd "$ROOT/docs/semantics" && lake build)
  echo "contracts_verify_lean: lake ok"
else
  echo "contracts_verify_lean: skipped lake (not installed)"
fi
echo "contracts_verify_lean: ok"
