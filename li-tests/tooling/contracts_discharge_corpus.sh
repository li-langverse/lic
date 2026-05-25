#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
for s in discharge_trivial_lean discharge_const_lean discharge_caller_requires_lean \
  discharge_caller_requires_local_lean discharge_linalg_int_lean discharge_witnessed_ensures_lean \
  discharge_refinement_lean discharge_identity_lean discharge_import_requires_lean; do
  chmod +x "$ROOT/li-tests/tooling/$s.sh"
  "$ROOT/li-tests/tooling/$s.sh"
done
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
"$LIC" build "$ROOT/li-tests/contracts_verify/index_refinement.li" -o /dev/null
chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
"$ROOT/scripts/check-autovc-open-goals.sh" "$ROOT/build/generated/AutoVC.lean"
rm -f "$ROOT/build/generated/AutoVC.lean"
"$LIC" build --allow-open-vc "$ROOT/li-tests/contracts_verify/sqrt_open_bound.li" -o /dev/null
if "$ROOT/scripts/check-autovc-open-goals.sh" "$ROOT/build/generated/AutoVC.lean"; then
  echo "contracts_discharge_corpus: sqrt_open_bound should stay open"
  exit 1
fi
echo "contracts_discharge_corpus: ok"
