#!/usr/bin/env bash
# P-par: build parallel specimen; AutoVC _par* VCs use Li.Discharge disjoint specs.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
SAMPLE="$ROOT/li-tests/race_shared_memory/good_disjoint_parallel.li"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
cp "$SAMPLE" "$TMP/good_disjoint_parallel.li"
(
  cd "$TMP"
  unset LI_REPO_ROOT
  "$LIC" build good_disjoint_parallel.li -o /dev/null --no-lean-verify
)
AUTOVC="$TMP/build/generated/AutoVC.lean"
test -f "$AUTOVC"
grep -q 'disjoint_row_spec' "$AUTOVC"
grep -q 'disjoint_row_policy_witness' "$AUTOVC"
grep -q '_par0_requires' "$AUTOVC"
chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
"$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC"
(cd "$ROOT/docs/semantics" && lake env lean "$AUTOVC")
echo "discharge_par_parallel_lean: ok"
