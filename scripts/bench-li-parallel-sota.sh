#!/usr/bin/env bash
# Run dual-mode lipar suite and emit li_parallel vs all registry SOTAs report.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export LIC_ROOT="$ROOT"
export LI_REPO_ROOT="$ROOT"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"

PROFILE="${LIPAR_SOTA_PROFILE:-full}"
CORES="${LIPAR_CORES:-8}"
CSV="${BENCHMARKS_CSV:-$BENCHMARKS_RESULTS/latest.csv}"
REGISTRY="${LI_HPC_COMPETITIVE_REGISTRY:-$ROOT/benchmarks/competitive/registry.toml}"
OUT_JSON="${LI_LIPAR_SOTA_JSON:-$ROOT/benchmarks/results/li-parallel-sota-report.json}"
OUT_MD="${LI_LIPAR_SOTA_MD:-$ROOT/packages/li-parallel/docs/sota-report.md}"
PH_ML="${LI_PH_ML_COMPETITIVE_JSON:-$BENCHMARKS_RESULTS/ph-ml-competitive.json}"

echo "==> bench-li-parallel-sota: profile=$PROFILE cores=$CORES"
bash "$ROOT/packages/li-parallel/scripts/lipar-suite.sh" \
  --profile "$PROFILE" \
  --dual-mode \
  --cores "$CORES"

if [[ ! -f "$CSV" ]]; then
  echo "ERROR: missing benchmark CSV at $CSV" >&2
  exit 1
fi

PH_ARG=()
if [[ -f "$PH_ML" ]]; then
  PH_ARG=(--ph-ml "$PH_ML")
fi

python3 "$ROOT/scripts/report-li-parallel-sota.py" \
  --csv "$CSV" \
  --registry "$REGISTRY" \
  --out-json "$OUT_JSON" \
  --out-md "$OUT_MD" \
  "${PH_ARG[@]}"

echo "==> bench-li-parallel-sota: done"
echo "    JSON: $OUT_JSON"
echo "    MD:   $OUT_MD"
