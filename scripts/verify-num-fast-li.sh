#!/usr/bin/env bash
# Build + verify pure-Li num_* fast paths match native oracles.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export LIC_ROOT="$ROOT"
export LI_REPO_ROOT="$ROOT"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"
# shellcheck source=lib/lic-bin-select.sh
source "$ROOT/scripts/lib/lic-bin-select.sh"

li_export_lic "$ROOT" || {
  echo "verify-num-fast-li: build lic first" >&2
  exit 1
}

chmod +x "$ROOT/scripts/lipar-apply-num-fast.sh"
"$ROOT/scripts/lipar-apply-num-fast.sh"

cd "$BENCHMARKS_ROOT"
BUILD_DIR="${NUM_FAST_BUILD_DIR:-/tmp/li-num-fast-verify}"
mkdir -p "$BUILD_DIR" || BUILD_DIR="$ROOT/.cache/li-num-fast-verify"
mkdir -p "$BUILD_DIR"
export NUM_FAST_BUILD_DIR="$BUILD_DIR"
python3 - <<'PY'
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, "harness")
from bench import TIER1_BENCHES, build_li, build_native, li_result_checksum, native_result_checksum, verify_benchmark_results

specs = [
    "num_cg",
    "num_eig_symmetric",
    "num_integ_euler",
    "num_integ_rk4",
    "num_integ_semi_implicit",
    "num_integ_symplectic",
    "num_integ_verlet",
    "num_opt_bfgs",
    "num_quadrature_gauss",
    "num_root_newton",
]
import os

build_dir = Path(os.environ["NUM_FAST_BUILD_DIR"])
build_dir.mkdir(parents=True, exist_ok=True)
failures = []
for name in specs:
    spec = next(s for s in TIER1_BENCHES if s.name == name)
    try:
        verify_benchmark_results(spec, build_dir)
        print(f"PASS {name}")
    except Exception as exc:
        failures.append((name, str(exc)))
        print(f"FAIL {name}: {exc}", file=sys.stderr)

if failures:
    raise SystemExit(1)
print("verify-num-fast-li: all ok")
PY
