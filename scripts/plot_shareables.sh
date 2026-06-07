#!/usr/bin/env bash
# Generate all X-ready PNGs: li-tests suites + benchmark CSV.
set -euo pipefail
export MPLBACKEND=Agg
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"

VENV="${ROOT}/.venv-plot"
SHARE="$BENCHMARKS_RESULTS/share"

if [[ ! -d "$VENV" ]]; then
  python3 -m venv "$VENV"
fi
# shellcheck disable=SC1091
source "$VENV/bin/activate"
pip install -q -r "$HARNESS/requirements.txt"

python3 "$HARNESS/bench.py" --tier 12 --runs 3 --skip-verify --out "$BENCHMARKS_RESULTS/latest.csv" || \
  python3 "$HARNESS/bench.py" --sample
python3 "$HARNESS/stability.py" --out "$BENCHMARKS_RESULTS/stability.csv" || true
python3 "$HARNESS/trace_energy.py" --out "$BENCHMARKS_RESULTS/md_lennard_jones" || true
python3 "$HARNESS/verify.py" --write-csv "$BENCHMARKS_RESULTS/verify.csv" || true
python3 "$HARNESS/plot.py" --tier all --out "$SHARE" \
  --energy-dir "$BENCHMARKS_RESULTS/md_lennard_jones" \
  --stability-csv "$BENCHMARKS_RESULTS/stability.csv" \
  --csv "$BENCHMARKS_RESULTS/latest.csv"
python3 "$HARNESS/animate_md.py" --out "$SHARE" --lang all --view all --fps 30 --hold-init 1.25 --skip-export || \
  python3 "$HARNESS/animate_md.py" --out "$SHARE" --lang all --view all --fps 30 --hold-init 1.25 || true
python3 "$HARNESS/animate_md.py" --out "$SHARE" --view temp-grid --fps 30 --hold-init 1.25 --skip-export || \
  python3 "$HARNESS/animate_md.py" --out "$SHARE" --view temp-grid --fps 30 --hold-init 1.25 || true
python3 "$HARNESS/animate_md.py" --out "$SHARE" --view temp-x --temp-hold 20 --steps 9000 --stride 16 --fps 30 --hold-init 1.25 --skip-export || \
  python3 "$HARNESS/animate_md.py" --out "$SHARE" --view temp-x --temp-hold 20 --steps 9000 --stride 16 --fps 30 --hold-init 1.25 || true
python3 "${ROOT}/li-tests/harness/plot_suites.py" --out "$SHARE"

echo "Shareable plots:"
ls -la "$SHARE"/*.png
echo "MD animations (per-lang + 2x2 grid):"
ls -la "$SHARE"/md_lennard_jones*.gif 2>/dev/null || true
