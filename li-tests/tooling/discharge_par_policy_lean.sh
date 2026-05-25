#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
if ! command -v lake >/dev/null 2>&1; then echo "discharge_par_policy_lean: skip"; exit 0; fi
cd "$ROOT/docs/semantics" && lake build Discharge
grep -q disjoint_par_policy_witness "$ROOT/docs/semantics/Discharge.lean"
echo "discharge_par_policy_lean: ok"
