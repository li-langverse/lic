#!/usr/bin/env bash
# Stage 9: multi-layer transformer reference parity (Li vs Python reference + optional HF smoke).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
OUT="${PH_ML_TRANSFORMER_MULTILAYER_OUT:-$ROOT/benchmarks/results/ph-ml-transformer-multilayer-parity.json}"
# shellcheck source=lib/lic-bin-select.sh
source "$ROOT/scripts/lib/lic-bin-select.sh"
li_ensure_lic "$ROOT" || { echo "bench-ph-ml-llm-transformer-multilayer-parity: no lic"; exit 1; }

python3 "$ROOT/scripts/prepare_ph_ml_weights_fixture.py"
SMOKE="packages/li-llm/li-tests/smoke/llm_transformer_multilayer_parity.li"
BIN="/tmp/ph-ml-transformer-multilayer-$$"
COMPILE_OK=0
RUN_RC=1
LI_TOP=""
export CC="${CC:-clang-22}" CXX="${CXX:-clang++-22}"
if "$LIC" build --allow-open-vc "$SMOKE" -o "$BIN" >/dev/null 2>&1; then
  COMPILE_OK=1
fi
if [[ "$COMPILE_OK" == "1" && -x "$BIN" ]]; then
  if "$BIN" >/dev/null 2>&1; then
    RUN_RC=0
  fi
fi

if [[ "$COMPILE_OK" == "1" ]]; then
  PROBE="$ROOT/packages/li-llm/li-tests/smoke/llm_transformer_multilayer_top_probe.li"
  PROBE_BIN="/tmp/ph-ml-multilayer-top-probe-$$"
  if "$LIC" build --allow-open-vc "$PROBE" -o "$PROBE_BIN" >/dev/null 2>&1; then
    "$PROBE_BIN" >/dev/null 2>&1 || true
    LI_TOP="$?"
    rm -f "$PROBE_BIN"
  fi
fi

export PH_ML_STAGE9_ROOT="$ROOT" PH_ML_LI_MULTILAYER_TOP_ID="${LI_TOP:-}" \
  PH_ML_TRANSFORMER_MULTILAYER_OUT="$OUT" PH_ML_MULTILAYER_COMPILE_OK="$COMPILE_OK" \
  PH_ML_MULTILAYER_RUN_RC="$RUN_RC"
python3 "$ROOT/scripts/bench_ph_ml_transformer_multilayer_reference.py"
rm -f "$BIN"
echo "bench-ph-ml-llm-transformer-multilayer-parity: done"
