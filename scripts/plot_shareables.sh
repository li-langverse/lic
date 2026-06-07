#!/usr/bin/env bash
# Generate all X-ready PNGs: li-tests suites + benchmark CSV.
set -euo pipefail
export MPLBACKEND=Agg
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"

VENV="${ROOT}/.venv-plot"
SHARE="$BENCHMARKS_RESULTS/share"
MIN_PNGS="${PLOT_SHAREABLES_MIN_PNGS:-4}"

if [[ -z "${HARNESS:-}" || ! -f "${HARNESS}/bench.py" ]]; then
  echo "plot_shareables: HARNESS missing (need li-langverse/benchmarks checkout)" >&2
  exit 1
fi

_ensure_plot_deps() {
  if python3 -c "import matplotlib, pandas" 2>/dev/null; then
    return 0
  fi
  if [[ ! -d "$VENV" ]]; then
    python3 -m venv "$VENV"
  fi
  # shellcheck disable=SC1091
  source "$VENV/bin/activate"
  pip install -q -r "$HARNESS/requirements.txt"
}

_ensure_plot_deps

# Tier 0: li-tests + verify.csv for correctness_tier0.png (falls back to verify.py only).
python3 "$HARNESS/bench.py" --tier 0 --out "$BENCHMARKS_RESULTS/latest.csv" || \
  python3 "$HARNESS/verify.py" --write-csv "$BENCHMARKS_RESULTS/verify.csv" --tier0-only || true

python3 "$HARNESS/bench.py" --tier 12 --runs 3 --skip-verify --out "$BENCHMARKS_RESULTS/latest.csv" || \
  python3 "$HARNESS/bench.py" --sample --out "$BENCHMARKS_RESULTS/latest.csv"
python3 "$HARNESS/stability.py" --out "$BENCHMARKS_RESULTS/stability.csv" || true
python3 "$HARNESS/trace_energy.py" --out "$BENCHMARKS_RESULTS/md_lennard_jones" || true
if [[ ! -f "$BENCHMARKS_RESULTS/verify.csv" ]]; then
  python3 "$HARNESS/verify.py" --write-csv "$BENCHMARKS_RESULTS/verify.csv" || true
fi
# plot.py resolves RESULTS as HARNESS/../benchmarks/results (legacy lic layout under .cache/).
_plot_data="$ROOT/.cache/benchmarks/results"
mkdir -p "$_plot_data"
for _f in verify.csv stability.csv latest.csv; do
  if [[ -f "$BENCHMARKS_RESULTS/$_f" ]]; then
    cp -f "$BENCHMARKS_RESULTS/$_f" "$_plot_data/$_f"
  fi
done
if [[ -d "$BENCHMARKS_RESULTS/md_lennard_jones" ]]; then
  rm -rf "$_plot_data/md_lennard_jones"
  cp -r "$BENCHMARKS_RESULTS/md_lennard_jones" "$_plot_data/"
fi
python3 "$HARNESS/plot.py" --tier all --out "$SHARE" \
  --energy-dir "$_plot_data/md_lennard_jones" \
  --stability-csv "$_plot_data/stability.csv" \
  --csv "$BENCHMARKS_RESULTS/latest.csv"
python3 "$HARNESS/animate_md.py" --out "$SHARE" --lang all --view all --fps 30 --hold-init 1.25 --skip-export || \
  python3 "$HARNESS/animate_md.py" --out "$SHARE" --lang all --view all --fps 30 --hold-init 1.25 || true
python3 "$HARNESS/animate_md.py" --out "$SHARE" --view temp-grid --fps 30 --hold-init 1.25 --skip-export || \
  python3 "$HARNESS/animate_md.py" --out "$SHARE" --view temp-grid --fps 30 --hold-init 1.25 || true
python3 "$HARNESS/animate_md.py" --out "$SHARE" --view temp-x --temp-hold 20 --steps 9000 --stride 16 --fps 30 --hold-init 1.25 --skip-export || \
  python3 "$HARNESS/animate_md.py" --out "$SHARE" --view temp-x --temp-hold 20 --steps 9000 --stride 16 --fps 30 --hold-init 1.25 || true
python3 "${ROOT}/li-tests/harness/plot_suites.py" --out "$SHARE" || true

png_count="$(find "$SHARE" -maxdepth 1 -name '*.png' 2>/dev/null | wc -l | tr -d ' ')"
if [[ "$png_count" -lt "$MIN_PNGS" ]]; then
  echo "plot_shareables: expected >= ${MIN_PNGS} PNGs in $SHARE, got ${png_count}" >&2
  exit 1
fi

echo "Shareable plots (${png_count} PNGs):"
ls -la "$SHARE"/*.png
echo "MD animations (per-lang + 2x2 grid):"
ls -la "$SHARE"/md_lennard_jones*.gif 2>/dev/null || true
