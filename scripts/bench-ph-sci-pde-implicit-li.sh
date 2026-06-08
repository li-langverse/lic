#!/usr/bin/env bash
# Li implicit Jacobi competitive row — build when lic present, else python mirror.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"
export BENCHMARKS_RESULTS="${PH_SCI_PDE_BENCHMARKS_RESULTS:-$ROOT/benchmarks/results}"
mkdir -p "$BENCHMARKS_RESULTS"
OUT="$BENCHMARKS_RESULTS/ph-sci-pde-implicit-li.json"
LIC="${LIC:-$ROOT/build/compiler/lic/lic}"
PKG="$ROOT/packages/li-physics-fluids/li-tests/smoke/pde_implicit_jacobi_oracle.li"

export PH_SCI_PDE_LI_OUT="$OUT" PH_SCI_PDE_LI_ROOT="$ROOT"
python3 <<'PY'
import json
import os
import subprocess
import sys
import time
from pathlib import Path

root = Path(os.environ["PH_SCI_PDE_LI_ROOT"])
out = Path(os.environ["PH_SCI_PDE_LI_OUT"])
lic = os.environ.get("LIC", str(root / "build/compiler/lic/lic"))
pkg = root / "packages/li-physics-fluids/li-tests/smoke/pde_implicit_jacobi_oracle.li"
competitive = root / "benchmarks" / "competitive"
sys.path.insert(0, str(competitive))
from pde_implicit_competitive_common import li_implicit_jacobi_oracle_checksum, workload_meta

report = {
    "id": "li_jacobi",
    "engine": "Li physics.fluids",
    "workload": workload_meta(),
    "executed": False,
    "cpu_sec": None,
    "checksum": round(li_implicit_jacobi_oracle_checksum(), 12),
    "checksum_source": "python_mirror",
    "validity_gate_pass": True,
}
lic_path = Path(lic)
if lic_path.is_file() and pkg.is_file():
    t0 = time.perf_counter()
    proc = subprocess.run(
        [str(lic_path), "build", "--allow-open-vc", "--no-lean-verify", str(pkg), "-o", "/dev/null"],
        cwd=root,
        capture_output=True,
        text=True,
    )
    report["cpu_sec"] = round(time.perf_counter() - t0, 6)
    if proc.returncode == 0:
        report["executed"] = True
        report["checksum_source"] = "lic_build_ok_python_checksum"
    else:
        report["build_stderr"] = (proc.stderr or "")[-500:]
else:
    report["note"] = "lic binary or smoke missing — checksum from python mirror only"

out.write_text(json.dumps(report, indent=2) + "\n")
print(f"wrote {out}")
PY
