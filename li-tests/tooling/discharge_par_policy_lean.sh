#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
if ! command -v lake >/dev/null 2>&1; then
  echo "discharge_par_policy_lean: skip (lake not installed)"
  exit 0
fi
grep -q disjoint_par_policy_witness "$ROOT/docs/semantics/Discharge.lean"
(cd "$ROOT/docs/semantics" && lake build Discharge)
echo "discharge_par_policy_lean: ok"
