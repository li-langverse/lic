#!/usr/bin/env bash
# Print native --verify checksums for num_* tier1 smoke benches.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BENCH="${BENCHMARKS_ROOT:-$ROOT/benchmarks}"
cd "$BENCH"
python3 - <<'PY'
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, "harness")
from bench import TIER1_BENCHES, build_native

REPO = Path(".").resolve()
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
build_dir = REPO / ".build" / "num-checksums"
build_dir.mkdir(parents=True, exist_ok=True)
for name in specs:
    spec = next(s for s in TIER1_BENCHES if s.name == name)
    native = build_dir / f"{name}_native"
    build_native(spec, native)
    out = subprocess.check_output([str(native), "--verify"], text=True).strip()
    print(f"{name}\t{out}")
PY
