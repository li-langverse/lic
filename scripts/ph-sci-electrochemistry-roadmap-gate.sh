#!/usr/bin/env bash
# Combined echem + GPU chem roadmap gate — fails while any WP row is still open.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

LIC="${LIC:-./build-wsl/compiler/lic/lic}"
if [[ -x "$ROOT/build-wsl/compiler/lic/lic" ]]; then
  LIC="$ROOT/build-wsl/compiler/lic/lic"
elif [[ -x "$ROOT/build/compiler/lic/lic" ]]; then
  LIC="$ROOT/build/compiler/lic/lic"
fi

"$LIC" build packages/li-chem/src/lib.li --allow-open-vc
bash scripts/ph-sci-gpu-chem-gates.sh

if grep -E '\| \*\*open\*\* \|' data/goal-directed-sprints/ph-sci-electrochemistry-sim-plan.md; then
  echo "roadmap gate: open echem WPs remain"
  exit 1
fi

if grep -qi 'partial\|open' data/goal-directed-sprints/ph-sci-gpu-chem-dft.md 2>/dev/null; then
  if grep -E 'Status:.*partial|Status:.*open' data/goal-directed-sprints/ph-sci-gpu-chem-dft.md; then
    echo "roadmap gate: open GPU chem WPs remain"
    exit 1
  fi
fi

echo "ph-sci-electrochemistry-roadmap-gate OK"
