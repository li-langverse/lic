#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh" 2>/dev/null || true
BENCHMARKS_RESULTS="${BENCHMARKS_RESULTS:-$ROOT/benchmarks/results}"
export BENCHMARKS_RESULTS
mkdir -p "$BENCHMARKS_RESULTS"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
LIC="${LIC:-$($ROOT/scripts/resolve-lic.sh)}"
if [[ -x "$ROOT/build-wsl/compiler/lic/lic" ]]; then
  LIC="$ROOT/build-wsl/compiler/lic/lic"
fi
OUT="$BENCHMARKS_RESULTS/ph-ml-lkir-matmul-32.json"
SMOKE="$ROOT/packages/li-ml/li-tests/smoke/ml_matmul_32_lkir.li"
mkdir -p "$BENCHMARKS_RESULTS"
export PH_ML_BENCH_ROOT="$ROOT" PH_ML_BENCH_LIC="$LIC" PH_ML_BENCH_OUT="$OUT" PH_ML_BENCH_SMOKE="$SMOKE"
export PH_ML_MATMUL_N="${PH_ML_MATMUL_N:-32}"
export PYTHONPATH="$ROOT/scripts${PYTHONPATH:+:$PYTHONPATH}"
python3 <<'PY'
import json, os, subprocess, tempfile, time
from pathlib import Path

root = Path(os.environ["PH_ML_BENCH_ROOT"])
lic = Path(os.environ["PH_ML_BENCH_LIC"])
smoke = Path(os.environ["PH_ML_BENCH_SMOKE"])
out = Path(os.environ["PH_ML_BENCH_OUT"])
n = int(os.environ.get("PH_ML_MATMUL_N", "32"))

report = {
    "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    "suite": "ph-ml-lkir-matmul-32",
    "workload_size": n,
    "smoke": str(smoke.relative_to(root)) if smoke.is_file() else None,
    "compile_ok": False,
    "validity_gate_pass": False,
    "validity_ratio": 0.0,
    "executed": False,
    "cpu_sec": None,
    "ratio_vs_li": None,
}

li_sec = None
if lic.is_file() and smoke.is_file():
    rel = str(smoke.relative_to(root))
    with tempfile.TemporaryDirectory(prefix="ph-ml-bench-32-") as tmp:
        bin_path = Path(tmp) / "ml_matmul_32_lkir"
        env = os.environ.copy()
        build = subprocess.run(
            [str(lic), "build", "--allow-open-vc", rel, "-o", str(bin_path)],
            cwd=root,
            capture_output=True,
            text=True,
            env=env,
        )
        report["compile_ok"] = build.returncode == 0
        if build.returncode == 0 and bin_path.is_file():
            t0 = time.perf_counter()
            run = subprocess.run([str(bin_path)], capture_output=True, text=True, env=env)
            li_sec = round(time.perf_counter() - t0, 6)
            report["cpu_sec"] = li_sec
            report["executed"] = True
            report["validity_gate_pass"] = run.returncode == 0
            report["validity_ratio"] = 1.0 if run.returncode == 0 else 0.0
            report["run_exit_code"] = run.returncode

numpy_sec = None
try:
    import numpy as np
    from ph_ml_competitor_workloads import DEFAULT_RUNS, DEFAULT_WARMUP, bench_loop, make_identity_matmul

    run_fn, sanity = make_identity_matmul(
        n,
        lambda: np.eye(n, dtype=np.float32),
        lambda a, b: a @ b,
    )
    numpy_sec, err = bench_loop(max(5, DEFAULT_RUNS // 5), DEFAULT_WARMUP, run_fn, sanity)
    if err:
        report["note"] = err
    else:
        report["numpy_cpu_sec"] = numpy_sec
        report["numpy_executed"] = True
except ImportError:
    report["note"] = "numpy not installed"

if li_sec and numpy_sec and li_sec > 0:
    report["ratio_vs_li"] = round(numpy_sec / li_sec, 6)
elif numpy_sec and numpy_sec > 0 and not lic.is_file():
    report["ratio_vs_li"] = 1.0
    report["note"] = "lic unavailable; numpy-only ratio placeholder"
elif li_sec and li_sec > 0:
    report["ratio_vs_li"] = 1.0

out.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
print(out)
PY
echo "bench-ph-ml-lkir-matmul-32: done"
