#!/usr/bin/env bash
# PH-SCI — run Phase 0–3 completion gates (native or WSL lic via resolve-lic.sh).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
cd "$ROOT"

bash scripts/ph-sci-phase0-gates.sh
bash scripts/ph-sci-phase1-gates.sh
bash scripts/ph-sci-phase2-gates.sh
bash scripts/ph-sci-phase3-gates.sh

echo "ph-sci-all-gates: Phase 0–3 OK"
