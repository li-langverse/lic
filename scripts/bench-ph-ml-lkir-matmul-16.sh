#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/scripts/lib/benchmarks-env.sh"
source "$ROOT/scripts/lib/li-ui.sh"
LIC="${LIC:-$($ROOT/scripts/resolve-lic.sh)}"
[[ -x "$ROOT/build-wsl/compiler/lic/lic" ]] && LIC="$ROOT/build-wsl/compiler/lic/lic"
OUT="$BENCHMARKS_RESULTS/ph-ml-lkir-matmul-16.json"
SMOKE="$ROOT/packages/li-ml/li-tests/smoke/ml_matmul_16_lkir.li"
mkdir -p "$BENCHMARKS_RESULTS"
export PH_ML_BENCH_ROOT="$ROOT" PH_ML_BENCH_LIC="$LIC" PH_ML_BENCH_OUT="$OUT" PH_ML_BENCH_SMOKE="$SMOKE"
python3 "$ROOT/scripts/bench-ph-ml-lkir-matmul.sh" 2>/dev/null || true
PH_ML_BENCH_OUT="$OUT" PH_ML_BENCH_SMOKE="$SMOKE" python3 - <<'PY'
import json, os, subprocess, tempfile, time
from pathlib import Path
root = Path(os.environ["PH_ML_BENCH_ROOT"])
lic = Path(os.environ["PH_ML_BENCH_LIC"])
smoke = Path(os.environ["PH_ML_BENCH_SMOKE"])
out = Path(os.environ["PH_ML_BENCH_OUT"])
report = {"suite": "ph-ml-lkir-matmul-16", "workload_size": 16, "compile_ok": False, "executed": False, "validity_gate_pass": False, "validity_ratio": 0.0, "cpu_sec": None}
if lic.is_file() and smoke.is_file():
    rel = str(smoke.relative_to(root))
    with tempfile.TemporaryDirectory() as tmp:
        bin_path = Path(tmp) / "ml_matmul_16_lkir"
        build = subprocess.run([str(lic), "build", "--allow-open-vc", rel, "-o", str(bin_path)], cwd=root, capture_output=True, text=True)
        report["compile_ok"] = build.returncode == 0
        if build.returncode == 0 and bin_path.is_file():
            t0 = time.perf_counter()
            run = subprocess.run([str(bin_path)], capture_output=True, text=True)
            report["cpu_sec"] = round(time.perf_counter() - t0, 6)
            report["executed"] = True
            report["validity_gate_pass"] = run.returncode == 0
            report["validity_ratio"] = 1.0 if run.returncode == 0 else 0.0
out.write_text(json.dumps(report, indent=2) + "\n")
print(out)
PY
