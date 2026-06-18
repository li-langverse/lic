#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"
mkdir -p "$ROOT/benchmarks/results"
export BENCHMARKS_RESULTS="$ROOT/benchmarks/results"

# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
LIC="${LIC:-$($ROOT/scripts/resolve-lic.sh)}"
OUT="$BENCHMARKS_RESULTS/ph-ml-li-array-matmul.json"
SMOKE="$ROOT/packages/li-array/li-tests/smoke/array_matmul_4.li"
mkdir -p "$BENCHMARKS_RESULTS"
export PH_ML_BENCH_ROOT="$ROOT" PH_ML_BENCH_LIC="$LIC" PH_ML_BENCH_OUT="$OUT" PH_ML_BENCH_SMOKE="$SMOKE"
python3 <<'PY'
import json, os, subprocess, tempfile, time
from pathlib import Path

root = Path(os.environ["PH_ML_BENCH_ROOT"])
lic = Path(os.environ["PH_ML_BENCH_LIC"])
smoke = Path(os.environ["PH_ML_BENCH_SMOKE"])
out = Path(os.environ["PH_ML_BENCH_OUT"])

report = {
    "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    "suite": "ph-ml-li-array-matmul",
    "id": "li_array_matmul_4x4",
    "smoke": str(smoke.relative_to(root)) if smoke.is_file() else None,
    "workload_class": "tier3_cpu",
    "compile_ok": False,
    "validity_gate_pass": False,
    "validity_ratio": 0.0,
    "executed": False,
    "cpu_sec": None,
    "build_cpu_sec": None,
}

if lic.is_file() and smoke.is_file():
    smoke_rel = str(smoke.relative_to(root))
    with tempfile.TemporaryDirectory(prefix="ph-ml-li-array-") as tmp:
        bin_path = Path(tmp) / "array_matmul_4"
        t0 = time.perf_counter()
        env = os.environ.copy()
        for cc in ("clang-22", "clang", "gcc"):
            if subprocess.run(["which", cc], capture_output=True).returncode == 0:
                env["CC"] = cc
                env["CXX"] = f"{cc}++" if cc != "clang-22" else "clang++-22"
                break
        build = subprocess.run(
            [str(lic), "build", "--allow-open-vc", smoke_rel, "-o", str(bin_path)],
            cwd=root,
            capture_output=True,
            text=True,
            env=env,
        )
        report["compile_ok"] = build.returncode == 0
        report["build_cpu_sec"] = round(time.perf_counter() - t0, 6)
        if not report["compile_ok"]:
            report["stderr_tail"] = (build.stderr or "")[-500:]
        elif bin_path.is_file():
            run_t0 = time.perf_counter()
            run = subprocess.run([str(bin_path)], capture_output=True, text=True, env=env)
            report["cpu_sec"] = round(time.perf_counter() - run_t0, 6)
            report["executed"] = True
            report["run_exit_code"] = run.returncode
            report["validity_gate_pass"] = run.returncode == 0
            report["validity_ratio"] = 1.0 if run.returncode == 0 else 0.0
            if run.returncode != 0:
                report["stderr_tail"] = (run.stderr or "")[-500:]

out.write_text(json.dumps(report, indent=2) + "\n")
print(f"bench-ph-ml-li-array-matmul: wrote {out} executed={report['executed']} cpu_sec={report['cpu_sec']}")
PY
