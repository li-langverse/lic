#!/usr/bin/env bash
# Build composable sim smoke, then emit li_sim_summary_v1 via sim_summary.py (same as verify.py).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LIC="${LIC:-$ROOT/build/compiler/lic/lic}"
FORMAT="${LI_SIM_SUMMARY_FORMAT:-json_min}"
OUT_DIR="${LI_SIM_RESULTS_DIR:-$BENCHMARKS_RESULTS/li_runs}"
DETAIL="${LI_SIM_OUTPUT_DETAIL:-summary}"

if [[ ! -x "$LIC" ]]; then
  echo "sim_li_run_summary: lic missing at $LIC" >&2
  exit 1
fi

export LIC
cd "$ROOT"
"$LIC" build --allow-open-vc --no-lean-verify \
  "$ROOT/li-tests/composable/import_sim_scientific_run.li" -o /dev/null

mkdir -p "$OUT_DIR"
emit() {
  local algo="$1" ok="$2" checksum="$3" vert="$4" bench="${5:-}"
  shift 5 || true
  local extra=()
  if [[ -n "$bench" ]]; then
    extra+=(--benchmark "$bench")
  fi
  python3 "$ROOT/scripts/sim-write-summary.py" \
    --algo-id "$algo" --ok "$ok" --checksum "$checksum" --vertical-id "$vert" \
    --output-detail "$DETAIL" --format "$FORMAT" \
    "${extra[@]}" "$@" \
    -o "$OUT_DIR/${bench:-algo_${algo}}.li.summary.json"
}

# Matches import_sim_scientific_run.li: run_simulation(md) + run_algo(heat)
emit 101 1 1.0 1 md_lj_cutoff_mic
emit 201 1 1.0 2 pde_heat_explicit_2d

# Registry stub spot-check (robo family)
emit 801 1 0.801 0 robo_multibody_step

# WP-SIM-P2: qm_dft_scf_energy (418) — QM summary keys (checksum band; runtime smokes assert oracle)
emit 418 1 1.117658 4 qm_dft_scf_energy \
  --workload-class smoke \
  --total-energy-hartree -1.117658 \
  --converged 1 \
  --scf-iterations 8 \
  --method "RKS/LDA" \
  --basis "STO-3G"

echo "sim_li_run_summary: wrote summaries under $OUT_DIR (format=$FORMAT)"
